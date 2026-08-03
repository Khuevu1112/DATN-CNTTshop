package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/** DTO cho Trung tâm hỗ trợ: trung tâm bảo hành, đặt lịch dịch vụ, bảng giá sửa chữa,
 * chính sách bảo hành và FAQ. */
public class SupportDtos {

    // ===================== Trung tâm bảo hành =====================

    /** khoangCachKm chỉ có giá trị khi client gửi kèm toạ độ của mình, ngược lại null.
     *
     * hienThi luôn true ở đường công khai (bản ghi ẩn không bao giờ được trả ra), nhưng BẮT BUỘC
     * phải có mặt cho màn hình admin: thiếu nó thì form sửa không biết trạng thái hiện tại và
     * mỗi lần lưu sẽ vô tình bật hiển thị lại những điểm đã cố ý ẩn đi. */
    public record TrungTamDto(
            Integer id, String ten, String diaChi,
            Integer provinceId, String tenTinh,
            BigDecimal lat, BigDecimal lng,
            String dienThoai, String email, String gioMoCua,
            List<String> dichVu, String loai, boolean nhanDatLich, String ghiChu,
            boolean hienThi, Integer sortOrder,
            Double khoangCachKm
    ) {}

    public record LuuTrungTamRequest(
            String ten, String diaChi, Integer provinceId, Integer wardId,
            BigDecimal lat, BigDecimal lng,
            String dienThoai, String email, String gioMoCua,
            List<String> dichVu, String loai, Boolean nhanDatLich, String ghiChu,
            Boolean hienThi, Integer sortOrder
    ) {}

    // ===================== Đặt lịch dịch vụ =====================

    /** Khung giờ trong ngày kèm cờ còn trống — FE tô xám ô đã bị chiếm thay vì để khách bấm
     * rồi mới báo lỗi. */
    public record KhungGioDto(String khungGio, boolean conTrong) {}

    public record DatLichRequest(
            Integer centerId, String hoTen, String dienThoai, String email,
            String loaiThietBi, String model, String moTaLoi,
            LocalDate ngayHen, String khungGio, Integer warrantyId
    ) {}

    public record LichHenDto(
            Integer id, String maLich,
            Integer centerId, String tenTrungTam, String diaChiTrungTam, String dienThoaiTrungTam,
            String hoTen, String dienThoai, String email,
            String loaiThietBi, String model, String moTaLoi,
            LocalDate ngayHen, String khungGio,
            String trangThai, String nhanTrangThai, String ghiChuKtv,
            Integer warrantyId, BigDecimal chiPhi,
            LocalDateTime createdAt, LocalDateTime updatedAt
    ) {}

    /** chiPhi tuỳ chọn — chỉ có nghĩa khi chuyển sang "hoàn thành", để lưu vào lịch sử bảo hành. */
    public record DoiTrangThaiLichRequest(String trangThai, String ghiChu, BigDecimal chiPhi) {}

    // ===================== Bảng giá sửa chữa =====================

    /** giaDen null = báo một con số (giaTu), có giá trị = báo khoảng "giaTu – giaDen".
     * hienThi/sortOrder: xem ghi chú ở TrungTamDto. */
    public record GiaSuaChuaDto(
            Integer id, String loaiThietBi, String hang, String dongMay,
            String maLoi, String tenLoi,
            BigDecimal giaLinhKien, BigDecimal tienCong, BigDecimal giaTu, BigDecimal giaDen,
            String thoiGianDuKien, Integer baoHanhThang, String ghiChu,
            boolean hienThi, Integer sortOrder
    ) {}

    /** Kết quả ước tính khi khách chọn tối đa 2 hạng mục — cộng dồn thành một khoảng giá. */
    public record UocTinhDto(
            List<GiaSuaChuaDto> hangMuc,
            BigDecimal tongTu, BigDecimal tongDen,
            String thoiGianDuKien
    ) {}

    public record LuuGiaSuaChuaRequest(
            String loaiThietBi, String hang, String dongMay,
            String maLoi, String tenLoi,
            BigDecimal giaLinhKien, BigDecimal tienCong, BigDecimal giaDen,
            String thoiGianDuKien, Integer baoHanhThang, String ghiChu,
            Boolean hienThi, Integer sortOrder
    ) {}

    // ===================== Chính sách bảo hành =====================

    public record ChinhSachBaoHanhDto(
            Integer id, String nhomHang, Integer soThang, String moTa, String tinhTu,
            boolean hienThi, Integer sortOrder
    ) {}

    public record LuuChinhSachRequest(
            String nhomHang, Integer soThang, String moTa, String tinhTu,
            Boolean hienThi, Integer sortOrder
    ) {}

    /** Tra cứu bảo hành theo serial — KHÔNG cần đăng nhập, nên cố tình không trả về thông tin
     * định danh khách hàng (họ tên/email/mã đơn). Ai cầm được serial cũng tra được, nhưng chỉ
     * biết máy còn hạn hay không, không moi thêm được dữ liệu cá nhân của người mua. */
    public record TraCuuBaoHanhDto(
            boolean timThay, String maBaoHanh, String serial, String tenSanPham,
            LocalDate ngayBatDau, LocalDate ngayHetHan,
            String trangThai, Integer soNgayConLai, String thongBao
    ) {}

    // ===================== FAQ =====================

    public record FaqItemDto(
            Integer id, Integer categoryId, String maDanhMuc, String tenDanhMuc,
            String cauHoi, String traLoi, String tuKhoa, boolean noiBat, Integer luotXem,
            boolean hienThi, Integer sortOrder
    ) {}

    public record FaqDanhMucDto(
            Integer id, String ma, String ten, String moTa, String icon,
            List<FaqItemDto> items
    ) {}

    public record LuuFaqRequest(
            Integer categoryId, String cauHoi, String traLoi, String tuKhoa,
            Boolean noiBat, Boolean hienThi, Integer sortOrder
    ) {}

    // ===================== Trang chủ hỗ trợ =====================

    /** Số liệu tổng hợp cho trang chủ hỗ trợ — gọi một lần thay vì để FE gọi 4 API rồi tự đếm. */
    public record TongQuanHoTroDto(
            int soTrungTam, int soTinhCoTrungTam, int soCauHoi, int soHangMucSuaChua,
            List<FaqItemDto> cauHoiNoiBat,
            List<TrungTamDto> trungTamNoiBat
    ) {}
}
