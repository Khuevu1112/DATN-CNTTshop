package com.fpoly.service;

import java.time.LocalDateTime;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.PasswordResetOtp;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.PasswordResetOtpRepository;

/**
 * Quên mật khẩu bằng OTP gửi qua email — lưu OTP trong DB (không dùng HttpSession)
 * để hoạt động được qua REST API (Vue SPA) lẫn form Thymeleaf cũ.
 */
@Service
public class ForgotPasswordService {

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private PasswordResetOtpRepository otpRepo;

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private MailService mailService;

    @Transactional
    public String guiOtp(String email) {
        if (email == null || email.isBlank()) {
            return "Vui lòng nhập email";
        }

        NguoiDung user = nguoiDungRepo.findByEmail(email).orElse(null);
        if (user == null) {
            return "Email không tồn tại trong hệ thống";
        }

        String otp = String.valueOf(100000 + new Random().nextInt(900000));

        PasswordResetOtp record = new PasswordResetOtp();
        record.setEmail(email);
        record.setOtpCode(otp);
        record.setExpiresAt(LocalDateTime.now().plusMinutes(5));
        record.setIsUsed(false);
        otpRepo.save(record);

        try {
            mailService.sendOtp(email, otp);
        } catch (Exception e) {
            return "Không gửi được email. Vui lòng thử lại sau.";
        }
        return null;
    }

    public String xacThucOtp(String email, String otp) {
        if (email == null || otp == null) {
            return "Thiếu thông tin xác thực";
        }

        PasswordResetOtp record = otpRepo.findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(email);
        if (record == null) {
            return "Mã xác nhận không tồn tại. Vui lòng gửi lại mã";
        }
        if (LocalDateTime.now().isAfter(record.getExpiresAt())) {
            return "Mã xác nhận đã hết hạn";
        }
        if (!record.getOtpCode().equals(otp)) {
            return "Mã xác nhận không đúng";
        }
        return null;
    }

    @Transactional
    public String datLaiMatKhau(String email, String otp, String matKhauMoi, String nhapLaiMatKhau) {
        String otpError = xacThucOtp(email, otp);
        if (otpError != null) {
            return otpError;
        }

        if (matKhauMoi == null || matKhauMoi.isBlank()) {
            return "Vui lòng nhập mật khẩu mới";
        }
        if (matKhauMoi.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự";
        }
        if (!matKhauMoi.equals(nhapLaiMatKhau)) {
            return "Mật khẩu nhập lại không khớp";
        }

        NguoiDung user = nguoiDungRepo.findByEmail(email).orElse(null);
        if (user == null) {
            return "Tài khoản không tồn tại";
        }
        user.setMatKhau(encoder.encode(matKhauMoi));
        nguoiDungRepo.save(user);

        PasswordResetOtp record = otpRepo.findTopByEmailAndIsUsedFalseOrderByCreatedAtDesc(email);
        if (record != null) {
            record.setIsUsed(true);
            otpRepo.save(record);
        }
        return null;
    }
}
