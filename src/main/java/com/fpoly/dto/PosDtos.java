package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
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

    // ===== Các chương trình ưu đãi ở tầm CỬA HÀNG (không gắn với một sản phẩm cụ thể) =====
    // Nhân viên tại quầy phải đọc vanh vách được cho khách: đang có đợt sale nào, mua tới mức
    // nào thì lên hạng, gói hội viên gồm những gì, trả góp kỳ nào lãi bao nhiêu. Trước đây thanh
    // ưu đãi POS chỉ có khuyến mãi/tặng kèm/coupon nên mấy câu đó phải đoán hoặc gọi hỏi admin.

    /** Một sản phẩm trong đợt Flash Sale đang chạy. */
    public record PosFlashSaleItemDto(
            Integer variantId, String tenSanPham, String sku,
            BigDecimal giaGoc, BigDecimal giaSale, Integer phanTramGiam, Integer soLuongConLai
    ) {}

    public record PosFlashSaleDto(
            String tieuDe, LocalDateTime batDauLuc, LocalDateTime ketThucLuc,
            List<PosFlashSaleItemDto> sanPham
    ) {}

    /** Hạng thành viên tích luỹ (Bạc/Vàng/Kim cương) — giảm % tự động mọi đơn. */
    public record PosHangThanhVienDto(
            String ten, BigDecimal mucChiToiThieu, Integer phanTramGiam, String moTa
    ) {}

    /** Gói hội viên TRẢ PHÍ (CNTT Care) — khác hoàn toàn hạng tích luỹ ở trên. */
    public record PosGoiHoiVienDto(
            String ma, String ten, BigDecimal gia, Integer soThang, List<String> quyenLoi
    ) {}

    /** Một kỳ hạn trả góp đang mở. */
    public record PosTraGopDto(Integer soThang, BigDecimal laiSuatNam) {}

    /** Gói TẤT CẢ chương trình ưu đãi để thanh bên chỉ cần một lượt gọi. */
    public record PosUuDaiDto(
            List<PosKhuyenMaiDto> khuyenMai,
            List<PosTangKemDto> tangKem,
            List<PosCouponDto> coupon,
            PosFlashSaleDto flashSale,
            List<PosHangThanhVienDto> hangThanhVien,
            List<PosGoiHoiVienDto> goiHoiVien,
            List<PosTraGopDto> traGop
    ) {}

    // ===== TRA CỨU & BẢO HÀNH TẠI QUẦY =====
    // Khách cầm máy tới quầy hỏi "đơn của tôi tới đâu rồi", "máy này còn bảo hành không",
    // "cái máy gửi sửa tuần trước xong chưa" — trước đây nhân viên POS không tra được gì, phải
    // mở Admin Console bằng tài khoản khác. Ba record dưới đây là những gì cần để trả lời ngay.

    /** Một phiếu bảo hành của khách. */
    public record PosBaoHanhDto(
            Integer id, String maBaoHanh, String tenSanPham, String serial,
            LocalDate ngayBatDau, LocalDate ngayKetThuc,
            String trangThai, String nhanTrangThai, Integer soNgayConLai,
            List<PosBaoHanhYeuCauDto> yeuCau
    ) {}

    /** Một lần khách gửi máy đi bảo hành/sửa chữa. */
    public record PosBaoHanhYeuCauDto(
            Integer id, String moTaLoi, String trangThai, String nhanTrangThai,
            LocalDate ngayHen, String hinhThuc, LocalDateTime taoLuc
    ) {}

    /** Tình trạng một đơn hàng, gọn đủ để đọc cho khách nghe. */
    public record PosDonHangDto(
            Integer id, String maDonHang, LocalDateTime thoiGian, String kenhBan,
            BigDecimal tongTien, String trangThai, String nhanTrangThai, String moTaTrangThai,
            String trangThaiThanhToan, Integer soMatHang, String tenSanPhamDauTien
    ) {}

    /** Lịch hẹn dịch vụ / yêu cầu đổi trả / yêu cầu thu cũ — ba loại việc còn dang dở của khách. */
    public record PosViecDangXuLyDto(
            String loai, String ma, String tieuDe, String trangThai, String nhanTrangThai,
            LocalDateTime thoiGian
    ) {}

    /**
     * Bảng tra cứu tổng hợp theo SỐ ĐIỆN THOẠI (hoặc mã đơn / serial).
     * Một lượt gọi trả về đủ mọi thứ nhân viên cần đọc cho khách đang đứng trước quầy.
     */
    public record PosTraCuuDto(
            PosKhachDto khach,
            List<PosDonHangDto> donHang,
            List<PosBaoHanhDto> baoHanh,
            List<PosViecDangXuLyDto> viecDangXuLy
    ) {}

    /** Nhân viên lập yêu cầu bảo hành hộ khách ngay tại quầy. */
    public record PosTaoYeuCauBaoHanhRequest(
            Integer warrantyId, String moTaLoi, String hinhThuc, Integer centerId
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
