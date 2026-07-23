package com.fpoly.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Bậc thành viên — xét theo TỔNG xu đã tích luỹ từ trước tới nay (không phải số dư hiện có, xem
 * MembershipService.xuTichLuy), nên tiêu xu đổi quà không bao giờ làm tụt hạng. Ưu đãi của mỗi
 * bậc được áp dụng tự động lúc tạo đơn (xem OrderService.datHangTuGioHang) chứ khách không phải
 * bấm gì thêm. Không lưu vào DB — luôn tính lại từ sổ giao dịch ví để không có nguy cơ lệch. */
public enum MembershipTier {

    // Mốc xu quy ra ĐÚNG số tiền khách phải mua, theo tỉ giá kiếm 10.000đ = 1 xu (xem
    // WalletService.VND_MOI_XU_KIEM): Bạc 60 triệu, Vàng 100 triệu, Kim cương 200 triệu.
    // Sửa tỉ giá kiếm thì PHẢI sửa lại 3 mốc này, nếu không ngưỡng lên hạng lệch đi cùng bội số.
    // xuToiDa của bậc cao nhất = null (không có trần).
    DONG      ("dong",      "Đồng",       0,   5_999, false,  0,  0),
    BAC       ("bac",       "Bạc",    6_000,   9_999, true,  20,  2),
    VANG      ("vang",      "Vàng",  10_000,  19_999, true,  35,  5),
    KIM_CUONG ("kim_cuong", "Kim cương", 20_000, null, true,  50, 15);

    private final String code;
    private final String tenHienThi;
    private final int xuToiThieu;
    private final Integer xuToiDa;
    private final boolean mienPhiNoiThanh;
    private final int phanTramGiamPhiLienTinh;
    private final int phanTramGiamDon;

    MembershipTier(String code, String tenHienThi, int xuToiThieu, Integer xuToiDa,
                   boolean mienPhiNoiThanh, int phanTramGiamPhiLienTinh, int phanTramGiamDon) {
        this.code = code;
        this.tenHienThi = tenHienThi;
        this.xuToiThieu = xuToiThieu;
        this.xuToiDa = xuToiDa;
        this.mienPhiNoiThanh = mienPhiNoiThanh;
        this.phanTramGiamPhiLienTinh = phanTramGiamPhiLienTinh;
        this.phanTramGiamDon = phanTramGiamDon;
    }

    /** Bậc tương ứng với số xu tích luỹ — duyệt từ cao xuống thấp nên chỉ cần so mốc dưới. */
    public static MembershipTier tuXuTichLuy(int xuTichLuy) {
        MembershipTier[] tiers = values();
        for (int i = tiers.length - 1; i >= 0; i--) {
            if (xuTichLuy >= tiers[i].xuToiThieu) return tiers[i];
        }
        return DONG;
    }

    /** Bậc kế tiếp, null nếu đã ở bậc cao nhất. */
    public MembershipTier bacKeTiep() {
        return this == KIM_CUONG ? null : values()[ordinal() + 1];
    }

    /** % tiến độ lên bậc kế tiếp (0-100). Kim cương luôn 100 vì không còn bậc nào để lên.
     * Làm tròn XUỐNG để chưa đủ xu thăng cấp thì không bao giờ hiện 100% (VD Bạc 6999/7000 xu
     * ra 99%, không phải 100% gây hiểu nhầm là đã lên hạng). */
    public int phanTramTienDo(int xuTichLuy) {
        if (xuToiDa == null) return 100;
        int trongBac = xuTichLuy - xuToiThieu;
        int doRongBac = xuToiDa + 1 - xuToiThieu;
        return Math.max(0, Math.min(100, (int) Math.floor(trongBac * 100.0 / doRongBac)));
    }

    /** Phí vận chuyển sau ưu đãi. noiThanh = giao trong Hải Phòng (scope "hai_phong" của
     * ShippingService) -> miễn phí từ bậc Bạc; ngoài Hải Phòng -> giảm theo % của bậc. */
    public BigDecimal phiVanChuyenSauUuDai(BigDecimal phiGoc, boolean noiThanh) {
        if (phiGoc == null || phiGoc.signum() <= 0) return BigDecimal.ZERO;
        if (noiThanh) {
            return mienPhiNoiThanh ? BigDecimal.ZERO : phiGoc;
        }
        if (phanTramGiamPhiLienTinh == 0) return phiGoc;
        return phiGoc.multiply(BigDecimal.valueOf(100 - phanTramGiamPhiLienTinh))
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
    }

    /** Số tiền được giảm trên tiền hàng nhờ bậc thành viên (chưa gồm coupon/xu). */
    public BigDecimal tienGiamTheoBac(BigDecimal tienHang) {
        if (phanTramGiamDon == 0 || tienHang == null || tienHang.signum() <= 0) return BigDecimal.ZERO;
        return tienHang.multiply(BigDecimal.valueOf(phanTramGiamDon))
                .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
    }

    public String getCode() { return code; }
    public String getTenHienThi() { return tenHienThi; }
    public int getXuToiThieu() { return xuToiThieu; }
    public Integer getXuToiDa() { return xuToiDa; }
    public boolean isMienPhiNoiThanh() { return mienPhiNoiThanh; }
    public int getPhanTramGiamPhiLienTinh() { return phanTramGiamPhiLienTinh; }
    public int getPhanTramGiamDon() { return phanTramGiamDon; }
}
