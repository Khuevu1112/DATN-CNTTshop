package com.fpoly.controller.api;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.OrderDtos.PaymentDto;
import com.fpoly.dto.OrderDtos.PaymentMethodDto;
import com.fpoly.model.Order;
import com.fpoly.model.Payment;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;

/** Phương thức thanh toán + nộp biên lai chuyển khoản — dùng cho cnttshop-vue. */
@RestController
@RequestMapping("/api")
public class PaymentApiController {

    @Autowired private PaymentMethodRepository paymentMethodRepo;
    @Autowired private PaymentRepository paymentRepo;

    @GetMapping("/payment-methods")
    public List<PaymentMethodDto> paymentMethods() {
        return paymentMethodRepo.findByIsActiveTrueOrderByIdAsc().stream()
                .map(m -> new PaymentMethodDto(m.getId(), m.getCode(), m.getName(), m.getLogoUrl()))
                .toList();
    }

    @PostMapping("/payments/{id}/upload-proof")
    public PaymentDto uploadProof(@PathVariable Integer id, @RequestParam("image") MultipartFile image,
                                   Authentication auth) {
        Payment payment = paymentRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán"));

        Order order = payment.getOrder();
        if (!order.getNguoiDung().getEmail().equals(auth.getName())) {
            throw new RuntimeException("Bạn không có quyền thao tác với giao dịch này");
        }
        if (!"banking".equals(payment.getPaymentMethod().getCode())) {
            throw new RuntimeException("Phương thức thanh toán này không cần nộp biên lai");
        }

        try {
            String uploadDir = "uploads/payment/";
            Files.createDirectories(Paths.get(uploadDir));

            String originalName = image.getOriginalFilename();
            if (originalName == null || originalName.isBlank()) originalName = "proof.jpg";
            String safeName = originalName.replaceAll("\\s+", "_").replaceAll("[^a-zA-Z0-9._-]", "");
            String fileName = UUID.randomUUID() + "_" + safeName;

            Path path = Paths.get(uploadDir).resolve(fileName);
            Files.copy(image.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

            payment.setProofImage("/uploads/payment/" + fileName);
            payment.setStatus("waiting_verify");
            paymentRepo.save(payment);
        } catch (IOException e) {
            throw new RuntimeException("Lỗi khi lưu ảnh biên lai: " + e.getMessage());
        }

        return new PaymentDto(payment.getId(), payment.getPaymentMethod().getCode(),
                payment.getPaymentMethod().getName(), payment.getAmount(), payment.getStatus(),
                payment.getPaidAt(), payment.getProofImage());
    }
}
