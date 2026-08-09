package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.Coupon;
import com.fpoly.repository.CouponRepository;

/** Áp mã giảm giá ở trang thanh toán — dùng chung cho coupon admin tạo sẵn lẫn coupon đổi từ
 * Xu CT (xem RedemptionService). */
@Service
public class CouponService {

    @Autowired
    private CouponRepository couponRepo;

    /** Kiểm tra mã hợp lệ với đơn hàng có tổng tiền hàng (chưa gồm phí ship) là subtotal — ném
     * lỗi rõ lý do nếu không hợp lệ, KHÔNG tăng used_count (chỉ xem trước). */
    public Coupon layCouponHopLe(String maNhap, BigDecimal subtotal) {
        if (maNhap == null || maNhap.isBlank()) {
            throw new RuntimeException("Vui lòng nhập mã giảm giá");
        }
        Coupon coupon = couponRepo.findByMa(maNhap.trim().toUpperCase())
                .orElseThrow(() -> new RuntimeException("Mã giảm giá không tồn tại"));

        if (!Boolean.TRUE.equals(coupon.getIsActive())) {
            throw new RuntimeException("Mã giảm giá đã ngừng áp dụng");
        }
        LocalDateTime now = LocalDateTime.now();
        if (coupon.getBatDauTu() != null && now.isBefore(coupon.getBatDauTu())) {
            throw new RuntimeException("Mã giảm giá chưa tới thời gian áp dụng");
        }
        if (coupon.getHetHanLuc() != null && now.isAfter(coupon.getHetHanLuc())) {
            throw new RuntimeException("Mã giảm giá đã hết hạn");
        }
        if (coupon.getSoLuotToiDa() != null && coupon.getSoLuotDaDung() >= coupon.getSoLuotToiDa()) {
            throw new RuntimeException("Mã giảm giá đã hết lượt sử dụng");
        }
        if (subtotal.compareTo(coupon.getDonToiThieu()) < 0) {
            throw new RuntimeException("Đơn hàng chưa đạt giá trị tối thiểu " + coupon.getDonToiThieu().longValue() + "đ để áp mã này");
        }
        return coupon;
    }

    /** percent: % trên tiền hàng, giới hạn theo giamToiDa (nếu admin cấu hình) để tránh đơn
     * hàng lớn bị giảm quá sâu; fixed: số tiền cố định, không áp giamToiDa vì bản thân giá trị
     * đã là số tiền cụ thể — luôn giới hạn không vượt quá tiền hàng (không để giảm giá âm
     * tổng đơn). */
    public BigDecimal tinhGiamGia(Coupon coupon, BigDecimal subtotal) {
        BigDecimal giam;
        if ("percent".equals(coupon.getLoaiGiam())) {
            giam = subtotal.multiply(coupon.getGiaTriGiam()).divide(BigDecimal.valueOf(100));
            if (coupon.getGiamToiDa() != null) {
                giam = giam.min(coupon.getGiamToiDa());
            }
        } else {
            giam = coupon.getGiaTriGiam();
        }
        return giam.min(subtotal);
    }

    @Transactional
    public void danhDauDaDung(Coupon coupon) {
        coupon.setSoLuotDaDung(coupon.getSoLuotDaDung() + 1);
        couponRepo.save(coupon);
    }

    // ── Áp NHIỀU mã cùng lúc (cộng dồn/loại trừ) ──────────────────────────

    /** Kiểm tra từng mã trong danh sách hợp lệ với subtotal (dùng lại layCouponHopLe), loại bỏ
     * mã nhập trùng nhau, rồi kiểm tra các mã có TƯƠNG THÍCH để dùng chung hay không. Ném lỗi
     * rõ lý do (mã nào, vì sao) nếu có mã không hợp lệ hoặc không tương thích — KHÔNG tăng
     * used_count (chỉ xem trước), giống layCouponHopLe. */
    public List<Coupon> layDanhSachCouponHopLe(List<String> maNhapList, BigDecimal subtotal) {
        if (maNhapList == null || maNhapList.isEmpty()) {
            throw new RuntimeException("Vui lòng chọn ít nhất 1 mã giảm giá");
        }
        List<Coupon> ketQua = new ArrayList<>();
        Set<String> daThay = new HashSet<>();
        for (String maNhap : maNhapList) {
            if (maNhap == null || maNhap.isBlank()) continue;
            String chuanHoa = maNhap.trim().toUpperCase();
            if (!daThay.add(chuanHoa)) continue; // bỏ qua mã nhập trùng lặp trong cùng lượt chọn
            ketQua.add(layCouponHopLe(chuanHoa, subtotal));
        }
        if (ketQua.isEmpty()) {
            throw new RuntimeException("Vui lòng chọn ít nhất 1 mã giảm giá");
        }
        kiemTraTuongThich(ketQua);
        return ketQua;
    }

    /** Ném lỗi rõ ràng (nêu đích danh mã nào) nếu các mã trong danh sách KHÔNG thể dùng chung:
     * - Bất kỳ mã nào có stackable = false thì phải đi một mình, không được chọn kèm mã khác.
     * - Hai mã cùng nhomLoaiTru (khác NULL/rỗng) dù đều stackable = true vẫn loại trừ nhau. */
    public void kiemTraTuongThich(List<Coupon> coupons) {
        if (coupons == null || coupons.size() <= 1) return;

        for (Coupon c : coupons) {
            if (!Boolean.TRUE.equals(c.getStackable())) {
                throw new RuntimeException(
                        "Mã \"" + c.getMa() + "\" không thể dùng chung với mã khác — vui lòng chỉ chọn một mình mã này");
            }
        }

        Map<String, String> nhomDaGap = new HashMap<>();
        for (Coupon c : coupons) {
            String nhom = c.getNhomLoaiTru();
            if (nhom == null || nhom.isBlank()) continue;
            String maTruoc = nhomDaGap.get(nhom);
            if (maTruoc != null) {
                throw new RuntimeException(
                        "Mã \"" + maTruoc + "\" và \"" + c.getMa() + "\" không tương thích với nhau — vui lòng chỉ chọn một trong hai");
            }
            nhomDaGap.put(nhom, c.getMa());
        }
    }

    /** Tổng tiền giảm khi áp nhiều mã cùng lúc — cộng dồn từng mã (đã tự giới hạn theo
     * giamToiDa nếu có ở tinhGiamGia), tổng cuối vẫn không được vượt quá tiền hàng. */
    public BigDecimal tinhTongGiamGia(List<Coupon> coupons, BigDecimal subtotal) {
        BigDecimal tong = BigDecimal.ZERO;
        for (Coupon c : coupons) {
            tong = tong.add(tinhGiamGia(c, subtotal));
        }
        return tong.min(subtotal);
    }

    @Transactional
    public void danhDauDaDungNhieu(List<Coupon> coupons) {
        for (Coupon c : coupons) {
            danhDauDaDung(c);
        }
    }

    /** Validate cấu hình coupon trước khi lưu (admin tạo/sửa mã) — gọi từ AdminApiController.
     * Đặt ở đây để dùng chung, tránh mỗi nơi validate một kiểu khác nhau. */
    public void kiemTraCauHinhHopLe(Coupon coupon) {
        if (coupon.getGiaTriGiam() == null || coupon.getGiaTriGiam().signum() <= 0) {
            throw new RuntimeException("Giá trị giảm phải lớn hơn 0");
        }
        if ("percent".equals(coupon.getLoaiGiam())) {
            if (coupon.getGiaTriGiam().compareTo(BigDecimal.valueOf(100)) > 0) {
                throw new RuntimeException("Giá trị giảm theo % không được vượt quá 100");
            }
            if (coupon.getGiamToiDa() != null && coupon.getGiamToiDa().signum() <= 0) {
                throw new RuntimeException("Giá trị giảm tối đa phải lớn hơn 0");
            }
        } else if ("fixed".equals(coupon.getLoaiGiam())) {
            coupon.setGiamToiDa(null);
        } else {
            throw new RuntimeException("Loại giảm giá không hợp lệ (chỉ chấp nhận percent hoặc fixed)");
        }
        // exclusiveGroup chỉ có ý nghĩa khi mã CÓ cộng dồn — nếu admin không bật stackable thì
        // ép về null để tránh cấu hình gây hiểu lầm (tưởng đang giới hạn thêm nhưng không dùng tới).
        if (!Boolean.TRUE.equals(coupon.getStackable())) {
            coupon.setNhomLoaiTru(null);
        }
    }
}
