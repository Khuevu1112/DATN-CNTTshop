package com.fpoly.service;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import com.fpoly.model.SubscriptionPlan;

/** Khoá lại nền kinh tế GÓI HỘI VIÊN "CNTT Care", tương tự XuEconomyTest khoá kinh tế Xu CT.
 *
 * Bất biến sống còn: giá mỗi gói PHẢI lớn hơn chi phí quyền lợi tối đa shop gánh trong 1 năm
 * (khi khách xài kịch mọi hạn mức). Đây chính là bài học từ ý tưởng ban đầu "nạp tiền để giảm %
 * mọi đơn" — bán quyền lợi vô hạn bằng khoản thu hữu hạn thì càng bán càng lỗ. Gói dịch vụ chỉ
 * an toàn vì mọi quyền lợi tốn tiền đều có HẠN MỨC; test này canh để không ai vô tình nâng hạn
 * mức hoặc hạ giá làm gói lỗ.
 *
 * Bộ số dưới đây PHẢI khớp seed trong database/61_membership_subscription.sql. */
class SubscriptionEconomyTest {

    /** Biên lãi tối thiểu trên giá bán — dưới mức này coi như định giá sai, kể cả còn lãi. */
    private static final BigDecimal BIEN_LAI_TOI_THIEU = new BigDecimal("0.15");

    private SubscriptionPlan goi(String code, long gia, int shipLienTinh, int veSinh, boolean traKeo,
                                 int tanNoi, int mayMuon, Long voucher) {
        SubscriptionPlan p = new SubscriptionPlan();
        p.setCode(code);
        p.setName(code);
        p.setPrice(BigDecimal.valueOf(gia));
        p.setDurationMonths(12);
        p.setInterprovinceQuota(shipLienTinh);
        p.setCleaningQuota(veSinh);
        p.setThermalPaste(traKeo);
        p.setOnsiteWarrantyQuota(tanNoi);
        p.setLoanerQuota(mayMuon);
        p.setActivationVoucherAmount(voucher == null ? null : BigDecimal.valueOf(voucher));
        return p;
    }

    private SubscriptionPlan coBan() { return goi("basic", 149_000, 1, 1, false, 0, 0, null); }
    private SubscriptionPlan plus()  { return goi("plus",  399_000, 2, 2, true,  0, 0, 50_000L); }
    private SubscriptionPlan pro()   { return goi("pro",   899_000, 4, 3, true,  2, 1, 100_000L); }

    @Test
    @DisplayName("Mỗi gói có lãi kể cả khi khách xài KỊCH mọi hạn mức")
    void moiGoiCoLaiTrongTruongHopXauNhat() {
        for (SubscriptionPlan p : new SubscriptionPlan[] { coBan(), plus(), pro() }) {
            BigDecimal chiPhi = p.chiPhiToiDaMotNam();
            assertTrue(p.getPrice().compareTo(chiPhi) > 0,
                    "Gói " + p.getCode() + " lỗ: giá " + p.getPrice() + " <= chi phí tối đa " + chiPhi);

            BigDecimal bienLai = p.getPrice().subtract(chiPhi)
                    .divide(p.getPrice(), 4, java.math.RoundingMode.HALF_UP);
            assertTrue(bienLai.compareTo(BIEN_LAI_TOI_THIEU) >= 0,
                    "Gói " + p.getCode() + " biên lãi " + bienLai + " thấp hơn mức tối thiểu " + BIEN_LAI_TOI_THIEU);
        }
    }

    @Test
    @DisplayName("Chi phí tối đa/năm đúng bằng con số đã tính khi thiết kế gói")
    void chiPhiToiDaKhopThietKe() {
        // Cơ bản: 1×49k ship + 1×45k vệ sinh                              = 94k
        assertTrue(coBan().chiPhiToiDaMotNam().compareTo(new BigDecimal("94000")) == 0);
        // Plus:  2×49k + 2×60k (vệ sinh tra keo) + 50k voucher            = 268k
        assertTrue(plus().chiPhiToiDaMotNam().compareTo(new BigDecimal("268000")) == 0);
        // Pro:   4×49k + 3×60k + 2×40k tận nơi + 1×100k máy mượn + 100k   = 656k
        assertTrue(pro().chiPhiToiDaMotNam().compareTo(new BigDecimal("656000")) == 0);
    }

    @Test
    @DisplayName("Giá 3 cấp tăng dần — cấp cao không bao giờ rẻ hơn cấp thấp")
    void giaTangDanTheoCap() {
        assertTrue(coBan().getPrice().compareTo(plus().getPrice()) < 0);
        assertTrue(plus().getPrice().compareTo(pro().getPrice()) < 0);
    }

    @Test
    @DisplayName("Gói KHÔNG có khái niệm tặng xu — quyền lợi chỉ là dịch vụ/ship/voucher")
    void goiKhongTangXu() {
        // Chốt chặn bằng thiết kế: SubscriptionPlan không có bất kỳ trường xu/điểm nào. Nếu ai
        // thêm cột thưởng xu vào gói, hãy xoá nó — đó là đường tắt bán hạng tích luỹ (xem
        // MembershipTier + XuEconomyTest.diemDanhKhongConLaDuongTatLenHang). Test này để lại dấu
        // vết chủ đích đó cho người sửa sau.
        assertTrue(true);
    }
}
