package com.fpoly.service;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;

import com.fpoly.model.MembershipTier;

/** Phí giao nội thành theo km luỹ tiến + ưu đãi bậc thành viên chồng lên nó — phần dễ sai nhất
 * vì là số tiền khách thực trả, nên khoá lại bằng test thay vì tin vào đọc code. */
class ShippingFeeTest {

    private final ShippingService shippingService = new ShippingService();

    private void kiemTra(String km, long phiMongDoi) {
        assertEquals(
                BigDecimal.valueOf(phiMongDoi).setScale(0),
                shippingService.phiTheoKhoangCach(new BigDecimal(km)),
                km + "km"
        );
    }

    @Test
    void trongVongDau_chiTinh250MoiKm() {
        kiemTra("0", 0);
        kiemTra("1", 250);
        kiemTra("5", 1_250);
        kiemTra("10", 2_500);   // đúng mốc vòng 1
    }

    @Test
    void vuotVong1_phanDoiTinh500MoiKm() {
        kiemTra("11", 3_000);   // 10x250 + 1x500
        kiemTra("15", 5_000);   // 10x250 + 5x500
        kiemTra("20", 7_500);   // đúng mốc vòng 2
    }

    @Test
    void vuotVong2_phanDoiTinh1000MoiKm() {
        kiemTra("21", 8_500);   // 2500 + 5000 + 1x1000
        kiemTra("30", 17_500);  // 2500 + 5000 + 10x1000
    }

    @Test
    void khoangCachLe_khongLamTronKmTruocKhiNhan() {
        // 12,5km = 10x250 + 2,5x500 = 3.750đ — nếu lỡ làm tròn km lên 13 sẽ ra 4.000đ.
        kiemTra("12.5", 3_750);
    }

    @Test
    void khoangCachThieu_khongTinhPhiThayViNemLoi() {
        assertEquals(BigDecimal.ZERO, shippingService.phiTheoKhoangCach(null));
    }

    @Test
    void bacThanhVien_mienPhiNoiThanhTuBac() {
        BigDecimal phiGoc = new BigDecimal("5000");
        assertEquals(phiGoc, MembershipTier.DONG.phiVanChuyenSauUuDai(phiGoc, true));
        assertEquals(BigDecimal.ZERO, MembershipTier.BAC.phiVanChuyenSauUuDai(phiGoc, true));
        assertEquals(BigDecimal.ZERO, MembershipTier.KIM_CUONG.phiVanChuyenSauUuDai(phiGoc, true));
    }

    @Test
    void bacThanhVien_giamPhanTramPhiLienTinh() {
        BigDecimal phiGoc = new BigDecimal("40000");
        assertEquals(new BigDecimal("40000"), MembershipTier.DONG.phiVanChuyenSauUuDai(phiGoc, false));
        assertEquals(new BigDecimal("32000"), MembershipTier.BAC.phiVanChuyenSauUuDai(phiGoc, false));
        assertEquals(new BigDecimal("26000"), MembershipTier.VANG.phiVanChuyenSauUuDai(phiGoc, false));
        assertEquals(new BigDecimal("20000"), MembershipTier.KIM_CUONG.phiVanChuyenSauUuDai(phiGoc, false));
    }

    @Test
    void bacThanhVien_xetTheoTongXuTichLuy() {
        assertEquals(MembershipTier.DONG, MembershipTier.tuXuTichLuy(0));
        assertEquals(MembershipTier.DONG, MembershipTier.tuXuTichLuy(5_999));
        assertEquals(MembershipTier.BAC, MembershipTier.tuXuTichLuy(6_000));
        assertEquals(MembershipTier.BAC, MembershipTier.tuXuTichLuy(9_999));
        assertEquals(MembershipTier.VANG, MembershipTier.tuXuTichLuy(10_000));
        assertEquals(MembershipTier.VANG, MembershipTier.tuXuTichLuy(19_999));
        assertEquals(MembershipTier.KIM_CUONG, MembershipTier.tuXuTichLuy(20_000));
        assertEquals(MembershipTier.KIM_CUONG, MembershipTier.tuXuTichLuy(999_999));
    }

    @Test
    void tienDoThangCap_khongBaoGioHien100PhanTramKhiChuaDuXu() {
        assertEquals(0, MembershipTier.DONG.phanTramTienDo(0));
        assertEquals(99, MembershipTier.DONG.phanTramTienDo(5_999));
        assertEquals(0, MembershipTier.BAC.phanTramTienDo(6_000));
        assertEquals(99, MembershipTier.BAC.phanTramTienDo(9_999));
        // Kim cương không còn bậc để lên -> luôn đầy thanh.
        assertEquals(100, MembershipTier.KIM_CUONG.phanTramTienDo(20_000));
    }
}
