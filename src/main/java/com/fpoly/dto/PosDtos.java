package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class PosDtos {

    /** Kết quả tra sản phẩm ở màn hình bán hàng — quét mã hoặc gõ tên. */
    public record PosProductDto(
            Integer variantId, Integer productId, String productName, String sku,
            String imageUrl, BigDecimal gia, Integer stock
    ) {}

    /** Khách tại quầy, tra theo số điện thoại. moi=true nghĩa là số này chưa từng mua -> sẽ tạo
     * tài khoản khách lẻ khi chốt đơn. */
    public record PosKhachDto(
            Integer id, String hoTen, String soDienThoai, boolean moi,
            Integer xuHienCo, String hangThanhVien, Integer phanTramGiamHang
    ) {}

    public record PosDongHangRequest(Integer variantId, Integer soLuong) {}

    /** soDienThoai bắt buộc — đây là định danh khách tại quầy. hoTen chỉ dùng khi tạo khách mới.
     * soXuMuonDung/maCoupon để nhân viên áp ưu đãi hộ khách. */
    public record PosTaoDonRequest(
            String soDienThoai, String hoTen,
            List<PosDongHangRequest> dongHang,
            String maPhuongThucThanhToan,
            String maCoupon, Integer soXuMuonDung
    ) {}

    public record PosDongHangDto(
            String tenSanPham, String sku, BigDecimal donGia, Integer soLuong, BigDecimal thanhTien
    ) {}

    /** Hoá đơn tại quầy — đủ để in và để màn hình phụ hiển thị. */
    // ===== Dữ liệu cho thanh bên phải của màn hình bán hàng =====
    // Nhân viên cần tra nhanh 3 thứ khi khách đứng trước quầy: sản phẩm này đang có khuyến mãi
    // gì, mua kèm được gì, và còn mã giảm giá nào dùng được.

    /** 1 dòng khuyến mãi kèm theo sản phẩm (VD "Tặng chuột", "Trả góp 0%"). */
    public record PosKhuyenMaiDto(Integer productId, String tenSanPham, String noiDung) {}

    /** Sản phẩm tặng kèm / mua kèm của 1 sản phẩm chính. */
    public record PosTangKemDto(
            Integer productId, String tenSanPhamChinh,
            Integer variantIdTang, String tenSanPhamTang, String imageUrl, BigDecimal gia
    ) {}

    /** Mã giảm giá còn hiệu lực, để nhân viên đọc cho khách. */
    public record PosCouponDto(
            String ma, String loaiGiam, BigDecimal giaTriGiam, BigDecimal donToiThieu,
            Integer soLuotConLai, LocalDateTime hetHanLuc
    ) {}

    /** Gói cả 3 mục để thanh bên chỉ cần một lượt gọi. */
    public record PosUuDaiDto(
            List<PosKhuyenMaiDto> khuyenMai,
            List<PosTangKemDto> tangKem,
            List<PosCouponDto> coupon
    ) {}

    public record PosHoaDonDto(
            Integer orderId, String maDonHang, LocalDateTime thoiGian,
            String tenKhach, String soDienThoai,
            List<PosDongHangDto> dongHang,
            BigDecimal tienHang, BigDecimal tienGiamGia, BigDecimal tongTien,
            String phuongThucThanhToan, String trangThaiThanhToan,
            Integer xuNhanDuoc,
            String urlThanhToan
    ) {}
}
