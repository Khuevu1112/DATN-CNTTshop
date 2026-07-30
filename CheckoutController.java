package com.fpoly.controller.cilent;

import com.fpoly.dto.ShippingFeeResponse;
import com.fpoly.service.ShippingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CheckoutController {

    @Autowired
    private ShippingService shippingService;

    @GetMapping("/checkout")
    public String showCheckoutPage(Model model) {
        // Dữ liệu test (Sau này bạn thay bằng dữ liệu khách hàng nhập trên form)
        String pickProvince = "Hà Nội";
        String pickWard = "Phường Dịch Vọng Hậu";
        String province = "Hồ Chí Minh";
        String ward = "Phường Bến Nghé";
        int weight = 1000; // 1kg

        // Gọi service để tính phí
        ShippingFeeResponse response = shippingService.calculateShippingFee(
                pickProvince, pickWard, province, ward, weight);

        // Kiểm tra và đẩy giá trị ra view
        if (response != null && response.isSuccess() && response.getFee().isDelivery()) {
            int shippingFee = response.getFee().getFee();
            model.addAttribute("shippingFee", shippingFee);
        } else {
            model.addAttribute("shippingFee", 0);
            model.addAttribute("error", "Không thể tính phí vận chuyển cho tuyến đường này.");
        }

        return "checkout"; 
    }
}