package com.fpoly.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
}
