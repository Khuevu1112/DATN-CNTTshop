package com.fpoly.service;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.dto.MembershipDtos.MembershipStatusDto;
import com.fpoly.dto.MembershipDtos.TierBenefitDto;
import com.fpoly.model.MembershipTier;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.WalletTransactionRepository;

/** Chương trình thành viên 4 bậc Đồng/Bạc/Vàng/Kim cương, xây trên đúng số Xu CT khách đã kiếm
 * được từ mua hàng + điểm danh (xem WalletService/CheckinService). Bậc không lưu trong DB mà
 * luôn tính lại từ sổ giao dịch ví, nên không bao giờ có chuyện bậc lệch với số xu thực tế. */
@Service
public class MembershipService {

    @Autowired private WalletService walletService;
    @Autowired private WalletTransactionRepository transactionRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;

    /** Tổng xu ĐÃ KIẾM (không trừ đi phần đã tiêu) — tiêu xu đổi quà không làm tụt hạng. */
    public int xuTichLuy(NguoiDung user) {
        return transactionRepo.tongXuDaKiem(walletService.layHoacTaoVi(user));
    }

    public MembershipTier bacCua(NguoiDung user) {
        return MembershipTier.tuXuTichLuy(xuTichLuy(user));
    }

    /** Bậc theo email — dùng ở luồng đặt hàng/tính phí ship, nơi chỉ có Authentication.getName().
     * "anonymousUser" là tên Spring Security gán cho request không có token trên endpoint
     * permitAll (/api/shipping/options) — chặn sớm để khỏi tra DB vô ích mỗi lượt xem phí. */
    public MembershipTier bacCua(String email) {
        if (email == null || "anonymousUser".equals(email)) return MembershipTier.DONG;
        return nguoiDungRepo.findByEmail(email)
                .map(this::bacCua)
                .orElse(MembershipTier.DONG);
    }

    public MembershipStatusDto trangThai(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        int xu = xuTichLuy(user);
        MembershipTier hienTai = MembershipTier.tuXuTichLuy(xu);
        MembershipTier keTiep = hienTai.bacKeTiep();

        return new MembershipStatusDto(
                xu,
                toDto(hienTai),
                keTiep == null ? null : toDto(keTiep),
                hienTai.getXuToiThieu(),
                hienTai.getXuToiDa() == null ? null : hienTai.getXuToiDa() + 1,
                hienTai.phanTramTienDo(xu),
                keTiep == null ? 0 : Math.max(0, keTiep.getXuToiThieu() - xu),
                tatCaBac()
        );
    }

    public List<TierBenefitDto> tatCaBac() {
        return Arrays.stream(MembershipTier.values()).map(MembershipService::toDto).toList();
    }

    /** Phí ship sau ưu đãi bậc. noiThanh = đơn giao trong Hải Phòng (scope "hai_phong" của
     * ShippingService) — từ bậc Bạc là miễn phí hoàn toàn. */
    public BigDecimal phiVanChuyenSauUuDai(String email, BigDecimal phiGoc, boolean noiThanh) {
        return bacCua(email).phiVanChuyenSauUuDai(phiGoc, noiThanh);
    }

    private static TierBenefitDto toDto(MembershipTier t) {
        return new TierBenefitDto(
                t.getCode(), t.getTenHienThi(), t.getXuToiThieu(), t.getXuToiDa(),
                t.isMienPhiNoiThanh(), t.getPhanTramGiamPhiLienTinh(), t.getPhanTramGiamDon()
        );
    }
}
