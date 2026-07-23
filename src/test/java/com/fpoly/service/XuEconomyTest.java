package com.fpoly.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.lang.reflect.Field;
import java.math.BigDecimal;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.fpoly.model.MembershipTier;

/** Khoá lại nền kinh tế Xu CT. Trước đây chiều kiếm và chiều tiêu dùng chung một tỉ giá nên
 * hoàn tiền 100% mọi đơn; các test dưới đây tồn tại để lỗi đó không quay lại lần nữa.
 *
 * Tỉ giá hiện tại: kiếm 10.000đ = 1 xu, tiêu 1 xu = 1.000đ -> hoàn 10%. */
class XuEconomyTest {

    private final WalletService walletService = new WalletService();

    /** Tỉ lệ hoàn mục tiêu — đổi 2 hằng số tỉ giá bên WalletService thì phải đổi cả số này. */
    private static final BigDecimal TI_LE_HOAN_MONG_DOI = new BigDecimal("0.10");

    private int[] thuongDiemDanhTheoNgay() throws Exception {
        Field f = CheckinService.class.getDeclaredField("THUONG_THEO_NGAY");
        f.setAccessible(true);
        return (int[]) f.get(null);
    }

    @Test
    @DisplayName("Chiều kiếm: 10.000đ tiền hàng = 1 xu")
    void chieuKiem() {
        assertEquals(1, walletService.uocTinhXu(new BigDecimal("10000")));
        assertEquals(100, walletService.uocTinhXu(new BigDecimal("1000000")));
        assertEquals(2_500, walletService.uocTinhXu(new BigDecimal("25000000")));
        // Dưới 10.000đ không ra xu nào (làm tròn xuống, không cho ăn gian từng đồng lẻ).
        assertEquals(0, walletService.uocTinhXu(new BigDecimal("9999")));
    }

    @Test
    @DisplayName("Chiều tiêu: 1 xu giảm được 1.000đ")
    void chieuTieu() {
        assertEquals(new BigDecimal("1000"), walletService.quyDoiXuRaTien(1));
        assertEquals(new BigDecimal("2500000"), walletService.quyDoiXuRaTien(2_500));
        // Hướng ngược: muốn giảm ngần này thì tốn bao nhiêu xu.
        assertEquals(2_500, walletService.soXuDeGiam(new BigDecimal("2500000")));
    }

    @Test
    @DisplayName("HAI chiều phải LỆCH nhau — đây chính là lỗi cũ, không được lặp lại")
    void haiChieuKhongDuocBangNhau() {
        BigDecimal tienHang = new BigDecimal("25000000");

        int xuNhanDuoc = walletService.uocTinhXu(tienHang);
        BigDecimal giaTriXuDo = walletService.quyDoiXuRaTien(xuNhanDuoc);

        assertTrue(giaTriXuDo.compareTo(tienHang) < 0,
                "Xu nhận về phải có giá trị NHỎ HƠN số tiền bỏ ra, nếu bằng là hoàn 100%");
        assertEquals(new BigDecimal("2500000"), giaTriXuDo, "Mua 25 triệu hoàn lại 2,5 triệu");
    }

    @Test
    @DisplayName("Tỉ lệ hoàn thực tế đúng 10% ở mọi mức giá")
    void tiLeHoanOnDinh() {
        for (String gia : new String[] { "500000", "3000000", "25000000", "80000000" }) {
            BigDecimal tienHang = new BigDecimal(gia);
            BigDecimal hoanLai = walletService.quyDoiXuRaTien(walletService.uocTinhXu(tienHang));
            assertEquals(0, hoanLai.compareTo(tienHang.multiply(TI_LE_HOAN_MONG_DOI)),
                    "Tỉ lệ hoàn ở mức giá " + gia);
        }
    }

    @Test
    @DisplayName("Mốc hạng thành viên quy ra đúng 60 / 100 / 200 triệu tiền mua hàng")
    void mocHangKhopVoiTiGiaKiem() {
        // Mốc hạng tính theo xu KIẾM ĐƯỢC nên phải quy ngược bằng tỉ giá kiếm, không phải tỉ
        // giá tiêu — dùng nhầm sẽ ra 6 triệu thay vì 60 triệu.
        assertEquals(60_000_000, MembershipTier.BAC.getXuToiThieu() * 10_000);
        assertEquals(100_000_000, MembershipTier.VANG.getXuToiThieu() * 10_000);
        assertEquals(200_000_000, MembershipTier.KIM_CUONG.getXuToiThieu() * 10_000);
    }

    @Test
    @DisplayName("Điểm danh 7 ngày quy ra tiền thật")
    void giaTriDiemDanhMotChuKy() throws Exception {
        int tongXuMotTuan = 0;
        for (int thuong : thuongDiemDanhTheoNgay()) tongXuMotTuan += thuong;

        assertEquals(110, tongXuMotTuan);
        // 110 xu x 1.000đ = 110.000đ/tuần. Trước khi tách tỉ giá con số này là 11.000.000đ.
        assertEquals(new BigDecimal("110000"), walletService.quyDoiXuRaTien(tongXuMotTuan));
    }

    @Test
    @DisplayName("Điểm danh suông không còn là đường tắt lên hạng cao nhất")
    void diemDanhKhongConLaDuongTatLenHang() throws Exception {
        int tongXuMotTuan = 0;
        for (int thuong : thuongDiemDanhTheoNgay()) tongXuMotTuan += thuong;

        int soTuan = (int) Math.ceil(MembershipTier.KIM_CUONG.getXuToiThieu() / (double) tongXuMotTuan);
        // 182 tuần (~3,5 năm) điểm danh liên tục không nghỉ ngày nào mới đạt Kim cương — đủ xa
        // để điểm danh không còn là lỗ hổng cày hạng. Nếu hạ mốc hạng xuống thì phải xem lại
        // con số này, dưới ~50 tuần là bắt đầu đáng lo.
        assertEquals(182, soTuan);
        assertTrue(soTuan > 50, "Điểm danh suông không được lên hạng cao nhất quá nhanh");
    }
}
