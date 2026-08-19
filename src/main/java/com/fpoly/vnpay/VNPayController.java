package com.fpoly.vnpay;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.view.RedirectView;

import com.fpoly.model.Order;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.UserSubscription;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.service.OrderService;
import com.fpoly.service.SubscriptionService;
import jakarta.servlet.http.HttpServletRequest;

/** Khởi tạo thanh toán VNPay và xử lý callback trả về — chuyển hướng trình duyệt thuần (không
 * qua JWT), giống StripeController. VNPay chặn hiển thị trong iframe khác gốc
 * (X-Frame-Options: SAMEORIGIN) nên trang thanh toán phải chuyển hướng toàn trang.
 *
 * Một Payment thuộc VỀ đơn hàng HOẶC gói hội viên (xem Payment.order/subscription) — controller
 * rẽ nhánh theo cột nào khác null: đơn hàng thì chốt đơn như cũ, gói hội viên thì kích hoạt gói. */
@Controller
public class VNPayController {

    @Autowired
    private VNPayConfig vnPayConfig;

    @Autowired
    private PaymentRepository paymentRepo;

    @Autowired
    private OrderStatusLogRepository statusLogRepo;

    @Autowired
    private OrderService orderService;

    @Autowired
    private SubscriptionService subscriptionService;

    @Autowired
    private com.fpoly.service.PosService posService;

    @GetMapping("/payment/vnpay/pay")
    public RedirectView pay(@RequestParam Integer paymentId) {
        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán"));

        if (!"pending".equals(payment.getStatus())) {
            return redirectToResult(payment, "already-processed");
        }

        boolean laMuaGoi = payment.getSubscription() != null;
        String orderInfo = laMuaGoi
                ? "Mua goi hoi vien CNTT Care"
                : "Thanh toan don hang " + payment.getOrder().getMaDonHang();

        String amount = payment.getAmount()
                .multiply(BigDecimal.valueOf(100))
                .toBigInteger()
                .toString();

        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", vnPayConfig.vnp_TmnCode);
        params.put("vnp_Amount", amount);
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", String.valueOf(payment.getId()));
        params.put("vnp_OrderInfo", orderInfo);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", vnPayConfig.vnp_ReturnUrl);
        params.put("vnp_IpAddr", "127.0.0.1");
        params.put("vnp_CreateDate", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")));

        String queryUrl = VNPayUtil.getPaymentURL(params, vnPayConfig.secretKey);
        return new RedirectView(vnPayConfig.vnp_PayUrl + "?" + queryUrl);
    }

    @GetMapping("/payment/vnpay/return")
    public RedirectView paymentReturn(HttpServletRequest request,
                                       @RequestParam("vnp_TxnRef") Integer paymentId,
                                       @RequestParam("vnp_ResponseCode") String responseCode,
                                       @RequestParam("vnp_SecureHash") String secureHash) {

        Map<String, String> fields = VNPayUtil.getAllRequestParams(request);
        boolean hopLe = VNPayUtil.verifySignature(fields, secureHash, vnPayConfig.secretKey);

        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán"));

        if (!hopLe) {
            return redirectToResult(payment, "invalid-signature");
        }

        if (!"pending".equals(payment.getStatus())) {
            // Đã xử lý trước đó (VNPay có thể gọi callback nhiều lần) — không xử lý lại.
            return redirectToResult(payment, "paid".equals(payment.getStatus()) ? "success" : "failed");
        }

        if (!"00".equals(responseCode)) {
            payment.setStatus("failed");
            paymentRepo.save(payment);
            return redirectToResult(payment, "failed");
        }

        payment.setStatus("paid");
        payment.setPaidAt(LocalDateTime.now());
        payment.setTransactionRef(fields.getOrDefault("vnp_TransactionNo", String.valueOf(paymentId)));
        paymentRepo.save(payment);

        if (payment.getSubscription() != null) {
            // Mua gói hội viên: kích hoạt gói + phát voucher + báo cho khách (xem
            // SubscriptionService.kichHoatSauThanhToan). Không đụng tới kho/giỏ hàng.
            subscriptionService.kichHoatSauThanhToan(payment);
            return redirectToResult(payment, "success");
        }

        Order order = payment.getOrder();

        // Đơn bán tại quầy: hàng đã trao tay lúc chốt đơn và kho đã trừ ngay từ đầu, nên KHÔNG đi
        // qua luồng "confirmed -> trừ kho -> xoá giỏ" của bán online. Ở đây chỉ còn việc cộng Xu
        // và tạo phiếu bảo hành — hai thứ vốn hoãn lại vì lúc chốt đơn khách chưa trả tiền.
        if (order.laDonTaiQuay()) {
            posService.xacNhanThanhToanPos(order);

            OrderStatusLog logPos = new OrderStatusLog();
            logPos.setOrder(order);
            logPos.setTrangThai(order.getTrangThai());
            logPos.setGhiChu("Khách thanh toán VNPay tại quầy thành công");
            statusLogRepo.save(logPos);

            return redirectToResult(payment, "success");
        }

        // Thanh toán đơn hàng online: chốt đơn + xoá giỏ + thông báo/mail + cộng Xu CT. Dùng
        // chung hàm với StripeController; hàm này cũng xử lý trường hợp tiền về SAU khi đơn đã
        // tự huỷ vì hết 5 phút giữ hàng — xem OrderService.chotDonSauThanhToanGateway.
        orderService.chotDonSauThanhToanGateway(order, "Thanh toán VNPay thành công");

        return redirectToResult(payment, "success");
    }

    /** Điểm quay về frontend sau thanh toán — khác nhau giữa mua gói (về trang tài khoản) và
     * thanh toán đơn hàng (về trang chủ kèm orderId để hiện kết quả đơn). */
    private RedirectView redirectToResult(Payment payment, String status) {
        if (payment.getSubscription() != null) {
            return new RedirectView(vnPayConfig.frontendUrl + "/tai-khoan?subscription=" + status);
        }
        Integer orderId = payment.getOrder() != null ? payment.getOrder().getId() : null;
        return new RedirectView(vnPayConfig.frontendUrl + "/?orderId=" + orderId + "&payment=" + status);
    }
}
