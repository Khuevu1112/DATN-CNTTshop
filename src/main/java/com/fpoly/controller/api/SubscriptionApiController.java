package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.SubscriptionDtos.BuyRequest;
import com.fpoly.dto.SubscriptionDtos.BuyResultDto;
import com.fpoly.dto.SubscriptionDtos.MySubscriptionDto;
import com.fpoly.dto.SubscriptionDtos.PlanDto;
import com.fpoly.dto.SubscriptionDtos.QuotaDto;
import com.fpoly.model.Payment;
import com.fpoly.model.UserSubscription;
import com.fpoly.service.OrderService;
import com.fpoly.service.SubscriptionService;

/** API gói hội viên trả phí "CNTT Care" — dùng cho cnttshop-vue. Bảng 3 gói công khai; xem/mua
 * gói cần đăng nhập. */
@RestController
@RequestMapping("/api/subscription")
public class SubscriptionApiController {

    @Autowired private SubscriptionService subscriptionService;
    @Autowired private OrderService orderService;

    /** Bảng 3 gói + quyền lợi — công khai (permitAll trong SecurityConfig). */
    @GetMapping("/plans")
    public List<PlanDto> plans() {
        return subscriptionService.danhSachGoi().stream().map(SubscriptionService::toPlanDto).toList();
    }

    /** Trạng thái gói của khách đang đăng nhập. */
    @GetMapping("/me")
    public MySubscriptionDto me(Authentication auth) {
        UserSubscription sub = subscriptionService.goiConHieuLuc(auth.getName());
        if (sub == null) {
            return new MySubscriptionDto(false, null, null, null, List.of());
        }
        List<QuotaDto> quotas = subscriptionService.quotasCuaGoi(sub);

        return new MySubscriptionDto(true, SubscriptionService.toPlanDto(sub.getPlan()),
                sub.getStartedAt(), sub.getExpiresAt(), quotas);
    }

    /** Mua/gia hạn gói — tạo giao dịch chờ thanh toán rồi trả URL cổng thanh toán để chuyển
     * hướng, giống luồng đặt đơn qua VNPay (xem OrderApiController.place). Mặc định VNPay. */
    @PostMapping("/buy")
    public BuyResultDto buy(@RequestBody BuyRequest req, Authentication auth) {
        String methodCode = req.paymentMethodCode() == null ? "vnpay" : req.paymentMethodCode();
        Payment payment = subscriptionService.muaGoi(auth.getName(), req.planCode(), methodCode);

        String redirectUrl = null;
        if (orderService.laCongThanhToanRedirect(methodCode)) {
            String duongDan = methodCode.startsWith("vnpay") ? "/payment/vnpay/pay" : "/payment/stripe/pay";
            redirectUrl = "http://localhost:8080" + duongDan + "?paymentId=" + payment.getId();
        }
        return new BuyResultDto(payment.getId(), redirectUrl);
    }
}
