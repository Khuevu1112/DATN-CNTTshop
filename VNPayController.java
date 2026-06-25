/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.fpoly.vnpay;

/**
 *
 * @author Asus
 */

import com.fpoly.model.Order;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.view.RedirectView;

import com.fpoly.model.Payment;
import com.fpoly.repository.PaymentRepository;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class VNPayController {

    @Autowired
    private VNPayConfig vnPayConfig;

    @Autowired
    private PaymentRepository paymentRepo;

    @GetMapping("/vnpay/pay")
    public RedirectView pay(
            @RequestParam Integer paymentId) {

        Payment payment = paymentRepo.findById(paymentId)
                .orElseThrow();

        String orderInfo =
                "Thanh toan don hang "
                        + payment.getOrder().getMaDonHang();

        String amount =
                payment.getAmount()
                        .multiply(java.math.BigDecimal.valueOf(100))
                        .toBigInteger()
                        .toString();

        Map<String, String> params = new HashMap<>();

        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");

        params.put("vnp_TmnCode",
                vnPayConfig.vnp_TmnCode);

        params.put("vnp_Amount",
                amount);

        params.put("vnp_CurrCode",
                "VND");

        params.put("vnp_TxnRef",
                String.valueOf(payment.getId()));

        params.put("vnp_OrderInfo",
                orderInfo);

        params.put("vnp_OrderType",
                "other");

        params.put("vnp_Locale",
                "vn");

        params.put("vnp_ReturnUrl",
                vnPayConfig.vnp_ReturnUrl);

        params.put("vnp_IpAddr",
                "127.0.0.1");

        params.put(
                "vnp_CreateDate",
                LocalDateTime.now()
                        .format(
                                DateTimeFormatter.ofPattern(
                                        "yyyyMMddHHmmss")));

        String queryUrl =
                VNPayUtil.getPaymentURL(
                        params,
                        vnPayConfig.secretKey);

        String paymentUrl =
                vnPayConfig.vnp_PayUrl
                        + "?"
                        + queryUrl;

        return new RedirectView(paymentUrl);
    }
    
    @GetMapping("/vnpay/return")
    public String paymentReturn(

        @RequestParam("vnp_TxnRef")
        Integer paymentId,

        @RequestParam("vnp_ResponseCode")
        String responseCode,

        RedirectAttributes ra
) {

    Payment payment =
            paymentRepo
                    .findById(paymentId)
                    .orElseThrow();

    Order order =
            payment.getOrder();

    if ("00".equals(responseCode)) {

        payment.setStatus("paid");

        payment.setPaidAt(
                LocalDateTime.now());

        order.setTrangThai(
                "confirmed");

        paymentRepo.save(payment);

        ra.addFlashAttribute(
                "success",
                "Thanh toán thành công");

    } else {

        payment.setStatus(
                "failed");

        paymentRepo.save(payment);

        ra.addFlashAttribute(
                "error",
                "Thanh toán thất bại");
    }

    return "redirect:/orders/"
            + order.getId();
}
}
