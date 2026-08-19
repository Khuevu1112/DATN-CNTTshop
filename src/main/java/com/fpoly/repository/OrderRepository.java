package com.fpoly.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);

    List<Order> findByTrangThaiOrderByCreatedAtDesc(String trangThai);

    List<Order> findAllByOrderByCreatedAtDesc();

    Optional<Order> findByMaDonHang(String maDonHang);

    List<Order> findByDiaChiGiao(com.fpoly.model.UserAddress diaChiGiao);

    // Ứng viên tự huỷ do quá hạn giữ hàng 24h (xem OrderService.huyDonHetHanThanhToan).
    List<Order> findByTrangThaiAndCreatedAtBefore(String trangThai, LocalDateTime cutoff);

    // Đơn qua cổng redirect đã hết 5 phút giữ hàng mà chưa trả tiền — quét mỗi phút để trả
    // hàng lại kho (xem OrderService.giaiPhongDonHetHanGiuHang).
    List<Order> findByTrangThaiAndHanGiuHangNotNullAndHanGiuHangBefore(String trangThai, LocalDateTime moc);

    /**
     * Lọc đơn hàng theo trạng thái (tuỳ chọn), khoảng ngày đặt (tuỳ chọn) và tên/email khách hàng (tuỳ chọn).
     * Mọi tham số truyền null sẽ được bỏ qua điều kiện tương ứng.
     * - tuNgay: mốc bắt đầu (inclusive), thường truyền LocalDate.atStartOfDay()
     * - denNgay: mốc kết thúc (inclusive), thường truyền LocalDate.plusDays(1).atStartOfDay() để bao trọn ngày cuối
     * - tenKhachHang: so khớp gần đúng (LIKE, không phân biệt hoa thường) trên email hoặc số điện thoại người dùng
     */
    @Query("SELECT o FROM Order o "
         + "LEFT JOIN o.nguoiDung nd "
         + "WHERE (:trangThai IS NULL OR o.trangThai = :trangThai) "
         + "AND (:tuNgay IS NULL OR o.createdAt >= :tuNgay) "
         + "AND (:denNgay IS NULL OR o.createdAt < :denNgay) "
         + "AND (:tenKhachHang IS NULL OR "
         + "     LOWER(nd.email) LIKE LOWER(CONCAT('%', :tenKhachHang, '%')) OR "
         + "     LOWER(nd.soDienThoai) LIKE LOWER(CONCAT('%', :tenKhachHang, '%'))) "
         + "ORDER BY o.createdAt DESC")
    List<Order> timDonTheoBoLoc(@Param("trangThai") String trangThai,
                                 @Param("tuNgay") LocalDateTime tuNgay,
                                 @Param("denNgay") LocalDateTime denNgay,
                                 @Param("tenKhachHang") String tenKhachHang);
}