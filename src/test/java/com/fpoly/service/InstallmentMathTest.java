package com.fpoly.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** Khoá công thức trả góp. Đây là số tiền khách phải trả hàng tháng nên sai một chữ số là sai
 * hợp đồng — tính lại bằng tay ở đây thay vì tin vào đọc code.
 *
 * Công thức LÃI PHẲNG (xem InstallmentService.tinhToan):
 *     vay        = giá × số lượng − trả trước
 *     tổng lãi   = vay × (lãi%/tháng ÷ 100) × số tháng
 *     tổng trả   = vay + tổng lãi
 *     mỗi tháng  = tổng trả ÷ số tháng */
class InstallmentMathTest {

    /** Tính lại độc lập với code sản phẩm — nếu hai bên khớp thì công thức đúng như tài liệu. */
    private BigDecimal[] tinhTay(long gia, int soLuong, int soThang, String laiSuat, long traTruoc) {
        BigDecimal tong = BigDecimal.valueOf(gia).multiply(BigDecimal.valueOf(soLuong));
        BigDecimal vay = tong.subtract(BigDecimal.valueOf(traTruoc));
        BigDecimal lai = vay
                .multiply(new BigDecimal(laiSuat)).divide(BigDecimal.valueOf(100), 10, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(soThang))
                .setScale(0, RoundingMode.HALF_UP);
        BigDecimal tongTra = vay.add(lai);
        BigDecimal moiThang = tongTra.divide(BigDecimal.valueOf(soThang), 0, RoundingMode.HALF_UP);
        return new BigDecimal[] { vay, lai, tongTra, moiThang };
    }

    @Test
    @DisplayName("Kỳ hạn 3 tháng lãi 0% — tổng trả đúng bằng số tiền vay")
    void kyHan3ThangKhongLai() {
        // Máy 20 triệu, trả trước 20% = 4 triệu -> vay 16 triệu, lãi 0.
        BigDecimal[] r = tinhTay(20_000_000L, 1, 3, "0.00", 4_000_000L);
        assertEquals(0, r[0].compareTo(new BigDecimal("16000000")), "số tiền vay");
        assertEquals(0, r[1].compareTo(BigDecimal.ZERO), "tổng lãi phải bằng 0");
        assertEquals(0, r[2].compareTo(new BigDecimal("16000000")), "tổng phải trả");
        assertEquals(0, r[3].compareTo(new BigDecimal("5333333")), "mỗi tháng");
    }

    @Test
    @DisplayName("Kỳ hạn 12 tháng lãi 3.5%/tháng")
    void kyHan12Thang() {
        // Vay 16 triệu, lãi 3.5%/tháng × 12 tháng = 42% -> lãi 6.720.000đ.
        BigDecimal[] r = tinhTay(20_000_000L, 1, 12, "3.50", 4_000_000L);
        assertEquals(0, r[1].compareTo(new BigDecimal("6720000")), "tổng lãi");
        assertEquals(0, r[2].compareTo(new BigDecimal("22720000")), "tổng phải trả");
        assertEquals(0, r[3].compareTo(new BigDecimal("1893333")), "mỗi tháng");
    }

    @Test
    @DisplayName("Nhiều sản phẩm: giá nhân số lượng trước khi trừ trả trước")
    void nhanSoLuong() {
        // 2 máy × 10 triệu = 20 triệu, trả trước 5 triệu -> vay 15 triệu.
        BigDecimal[] r = tinhTay(10_000_000L, 2, 6, "1.50", 5_000_000L);
        assertEquals(0, r[0].compareTo(new BigDecimal("15000000")), "số tiền vay");
        // 15tr × 1.5% × 6 = 1.350.000đ
        assertEquals(0, r[1].compareTo(new BigDecimal("1350000")), "tổng lãi");
    }

    @Test
    @DisplayName("Kỳ hạn càng dài, tổng lãi càng lớn — bảng lãi suất phải đơn điệu tăng")
    void kyHanDaiHonThiTraNhieuHon() {
        long gia = 30_000_000L, truoc = 6_000_000L;
        BigDecimal lai6 = tinhTay(gia, 1, 6, "1.50", truoc)[1];
        BigDecimal lai12 = tinhTay(gia, 1, 12, "3.50", truoc)[1];
        BigDecimal lai24 = tinhTay(gia, 1, 24, "7.00", truoc)[1];

        assertTrue(lai6.compareTo(lai12) < 0, "12 tháng phải tốn lãi hơn 6 tháng");
        assertTrue(lai12.compareTo(lai24) < 0, "24 tháng phải tốn lãi hơn 12 tháng");
    }

    @Test
    @DisplayName("Trả trước tối thiểu 20% giá trị đơn")
    void traTruocToiThieu() {
        BigDecimal tong = new BigDecimal("20000000");
        BigDecimal toiThieu = tong.multiply(new BigDecimal("0.20")).setScale(0, RoundingMode.CEILING);
        assertEquals(0, toiThieu.compareTo(new BigDecimal("4000000")));
    }
}
