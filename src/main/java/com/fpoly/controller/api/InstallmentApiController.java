package com.fpoly.controller.api;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.InstallmentDtos.CauHinhDto;
import com.fpoly.dto.InstallmentDtos.DangKyRequest;
import com.fpoly.dto.InstallmentDtos.DonCuaToiDto;
import com.fpoly.dto.InstallmentDtos.TinhToanDto;
import com.fpoly.service.InstallmentService;

/** Trả góp — phía khách. Xem kỳ hạn, tính thử, đăng ký hồ sơ.
 *
 * Phần tính thử để CÔNG KHAI (khách chưa đăng nhập vẫn xem được khoản trả hàng tháng ở trang sản
 * phẩm), còn đăng ký thì cần đăng nhập để hồ sơ gắn với tài khoản và khách theo dõi được. */
@RestController
@RequestMapping("/api/installment")
public class InstallmentApiController {

    @Autowired private InstallmentService installmentService;

    @GetMapping("/config")
    public CauHinhDto cauHinh() {
        return installmentService.cauHinh();
    }

    /** Tính thử theo biến thể — giá lấy từ DB, client không gửi giá lên được. */
    @GetMapping("/quote")
    public TinhToanDto tinhThu(@RequestParam Integer variantId,
                               @RequestParam Integer soThang,
                               @RequestParam(required = false) Integer soLuong,
                               @RequestParam(required = false) BigDecimal traTruoc) {
        return installmentService.tinhToanTheoVariant(variantId, soLuong, soThang, traTruoc);
    }

    @PostMapping
    public DonCuaToiDto dangKy(@RequestBody DangKyRequest req, Authentication auth) {
        return installmentService.dangKy(req, auth == null ? null : auth.getName());
    }

    @GetMapping
    public List<DonCuaToiDto> donCuaToi(Authentication auth) {
        return installmentService.donCuaToi(auth.getName());
    }
}
