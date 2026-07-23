package com.fpoly.stripe;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.view.RedirectView;

import com.fpoly.model.Order;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.service.OrderService;
import com.stripe.exception.SignatureVerificationException;
import com.stripe.exception.StripeException;
import com.stripe.model.Event;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import com.stripe.param.checkout.SessionCreateParams;

/** Khởi tạo Stripe Checkout Session và xử lý kết quả trả về thanh toán đơn hàng. Stripe
 * Checkout luôn dùng redirect toàn trang (không nhúng iframe). VND là zero-decimal currency
 * với Stripe (không nhân 100 như USD) — xem https://docs.stripe.com/currencies#zero-decimal. */
@Controller
public class StripeController {

    @Autowired
    private StripeConfig stripeConfig;

    @Autowired
    private PaymentRepository paymentRepo;

    @Autowired
    private OrderStatusLogRepository statusLogRepo;

    @Autowired
    private OrderService orderService;

    @GetMapping("/payment/stripe/pay")
    public RedirectView pay(@RequestParam Integer paymentId) {
        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán"));

        if (!"pending".equals(payment.getStatus())) {
            return redirectToOrderResult(payment.getOrder().getId(), "already-processed");
        }

        long amount = payment.getAmount().longValueExact();
        String successUrl = stripeConfig.returnUrl + "?paymentId=" + paymentId + "&session_id={CHECKOUT_SESSION_ID}";
        String cancelUrl = stripeConfig.frontendUrl + "/?orderId=" + payment.getOrder().getId() + "&payment=failed";
        Map<String, String> metadata = new HashMap<>();
        metadata.put("paymentId", String.valueOf(paymentId));

        Session session = taoCheckoutSession(amount, "Thanh toan don hang " + payment.getOrder().getMaDonHang(),
                successUrl, cancelUrl, metadata);
        if (session == null) {
            return redirectToOrderResult(payment.getOrder().getId(), "gateway-not-configured");
        }

        payment.setTransactionRef(session.getId());
        paymentRepo.save(payment);

        return new RedirectView(session.getUrl());
    }

    /** Trình duyệt quay lại đây ngay sau khi thanh toán xong trên trang Stripe — xác thực
     * lại session qua API Stripe (không tin trực tiếp query string) rồi mới chốt đơn. Đây là
     * đường xác nhận "nhanh" cho UX; webhook bên dưới mới là nguồn xác nhận đáng tin cậy nếu
     * khách đóng tab giữa chừng trước khi quay lại được trang này. */
    @GetMapping("/payment/stripe/return")
    public RedirectView returnFromStripe(@RequestParam Integer paymentId,
                                          @RequestParam("session_id") String sessionId) {
        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán"));
        Order order = payment.getOrder();

        if (!"pending".equals(payment.getStatus())) {
            return redirectToOrderResult(order.getId(), "paid".equals(payment.getStatus()) ? "success" : "failed");
        }
        if (!sessionId.equals(payment.getTransactionRef())) {
            return redirectToOrderResult(order.getId(), "invalid-signature");
        }

        Session session = laySessionAnToan(sessionId);
        if (session != null && "paid".equals(session.getPaymentStatus())) {
            xacNhanThanhToanDonHang(payment, order);
            return redirectToOrderResult(order.getId(), "success");
        }
        return redirectToOrderResult(order.getId(), "failed");
    }

    /** Stripe gọi server-to-server ngay khi thanh toán hoàn tất — đây là cách hệ thống tự
     * động hoá thật sự (không phụ thuộc khách có quay lại trang return ở trên hay không).
     * Cần cấu hình endpoint này + stripe.webhookSecret trên dashboard Stripe (hoặc `stripe
     * listen --forward-to localhost:8080/payment/stripe/webhook` khi chạy local). */
    @PostMapping("/payment/stripe/webhook")
    @ResponseBody
    public ResponseEntity<String> webhook(@RequestBody String payload,
                                           @RequestHeader("Stripe-Signature") String sigHeader) {
        Event event;
        try {
            event = Webhook.constructEvent(payload, sigHeader, stripeConfig.webhookSecret);
        } catch (SignatureVerificationException | RuntimeException e) {
            return ResponseEntity.badRequest().body("invalid signature");
        }

        if ("checkout.session.completed".equals(event.getType())) {
            event.getDataObjectDeserializer().getObject().ifPresent(obj -> {
                if (!(obj instanceof Session session)) return;
                if (!"paid".equals(session.getPaymentStatus())) return;
                if (session.getMetadata() == null) return;

                String paymentIdStr = session.getMetadata().get("paymentId");
                if (paymentIdStr == null) return;
                Optional<Payment> maybePayment = paymentRepo.findById(Integer.valueOf(paymentIdStr));
                maybePayment.filter(p -> "pending".equals(p.getStatus()))
                        .ifPresent(p -> xacNhanThanhToanDonHang(p, p.getOrder()));
            });
        }

        return ResponseEntity.ok("ok");
    }

    /** Tạo Checkout Session — trả về null (thay vì ném StripeException ra ngoài) nếu Stripe từ
     * chối request (VD chưa cấu hình secretKey thật): request lỗi sẽ bị dispatch sang "/error",
     * đường dẫn đó không nằm trong permitAll nào nên rơi xuống webSecurityChain và bị redirect
     * nhầm sang trang đăng nhập admin Thymeleaf thay vì quay lại kết quả. */
    private Session taoCheckoutSession(long amount, String tenSanPham, String successUrl, String cancelUrl,
                                        Map<String, String> metadata) {
        SessionCreateParams.Builder builder = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(successUrl)
                .setCancelUrl(cancelUrl)
                .addLineItem(
                        SessionCreateParams.LineItem.builder()
                                .setQuantity(1L)
                                .setPriceData(
                                        SessionCreateParams.LineItem.PriceData.builder()
                                                .setCurrency("vnd")
                                                .setUnitAmount(amount)
                                                .setProductData(
                                                        SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                                                .setName(tenSanPham)
                                                                .build())
                                                .build())
                                .build());
        metadata.forEach(builder::putMetadata);

        try {
            return Session.create(builder.build());
        } catch (StripeException e) {
            return null;
        }
    }

    /** Không để StripeException rơi ra ngoài (xem taoCheckoutSession) — mọi lỗi gọi Stripe đều
     * coi như thanh toán chưa xác nhận được, để webhook có cơ hội xác nhận sau. */
    private Session laySessionAnToan(String sessionId) {
        try {
            return Session.retrieve(sessionId);
        } catch (StripeException e) {
            return null;
        }
    }

    private void xacNhanThanhToanDonHang(Payment payment, Order order) {
        payment.setStatus("paid");
        payment.setPaidAt(LocalDateTime.now());
        paymentRepo.save(payment);

        order.setTrangThai("confirmed");

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai("confirmed");
        log.setGhiChu("Thanh toán Stripe thành công");
        statusLogRepo.save(log);

        // Chỉ tới giờ mới thật sự trừ kho + xoá giỏ hàng + gửi thông báo/mail "đã thanh toán"
        // + cộng xu (xem OrderService để hiểu vì sao phải hoãn tới lúc này thay vì làm ngay
        // khi tạo đơn).
        orderService.xacNhanThanhToanGatewayThanhCong(order);
    }

    private RedirectView redirectToOrderResult(Integer orderId, String paymentStatus) {
        return new RedirectView(stripeConfig.frontendUrl + "/?orderId=" + orderId + "&payment=" + paymentStatus);
    }
}
