package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.WarrantyRequest;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class MailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.frontendUrl}")
    private String frontendUrl;

    // Mã tuỳ chọn giao nội thành Hải Phòng (ShippingService) — còn lại là mã hãng vận chuyển
    // liên tỉnh (CARRIER) — dùng để đổi nội dung mail/thông báo cho phù hợp (xem OrderService).
    private static final List<String> MA_TUY_CHON_NOI_THANH = List.of("hoa_toc", "thuong");

    public void sendOtp(String to, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Mã xác nhận đặt lại mật khẩu CNTTShop");
        message.setText(
                "Xin chào,\n\n"
                + "Mã xác nhận đặt lại mật khẩu của bạn là: " + otp + "\n\n"
                + "Mã này có hiệu lực trong 5 phút.\n"
                + "Nếu bạn không yêu cầu đặt lại mật khẩu, vui lòng bỏ qua email này.\n\n"
                + "CNTTShop"
        );
        mailSender.send(message);
    }

    public void sendWarrantyStatusEmail(WarrantyRequest request) throws MessagingException {
        String email = request.getWarranty().getNguoiDung().getEmail();
        String tenKhach = request.getWarranty().getNguoiDung().getHoTen();
        String sanPham = request.getWarranty().getOrderItem().getTenSanPham();
        String trangThai = request.getRequestStatus();

        String mauTrangThai = "#0d6efd";
        String textTrangThai = "Đã tiếp nhận";
        String ghiChuThem = "";
        switch (trangThai) {
            case "processing" -> { textTrangThai = "Đang xử lý"; mauTrangThai = "#fd7e14"; }
            case "resolved"   -> {
                textTrangThai = "Đã hoàn thành";
                mauTrangThai = "#198754";
                ghiChuThem = "<p style=\"background:#e9f7ef;color:#198754;padding:12px 14px;border-radius:8px;margin-top:14px\">"
                        + "Sản phẩm của bạn đã bảo hành xong. Bạn có thể đến nhận máy <b>bất cứ lúc nào</b> trong giờ mở cửa cửa hàng, không cần hẹn trước.</p>";
            }
            case "rejected"   -> { textTrangThai = "Từ chối"; mauTrangThai = "#dc3545"; }
            case "no_show"    -> {
                textTrangThai = "Đã quá lịch hẹn";
                mauTrangThai = "#dc3545";
                ghiChuThem = "<p style=\"background:#fdecea;color:#dc3545;padding:12px 14px;border-radius:8px;margin-top:14px\">"
                        + "Hệ thống ghi nhận bạn chưa đến theo lịch hẹn bảo hành. Vui lòng liên hệ shop để đặt lại lịch hẹn mới.</p>";
            }
            default -> { }
        }

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(email);
        helper.setSubject("Cập nhật yêu cầu bảo hành - CNTTShop");

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#dc3545;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Cập nhật yêu cầu bảo hành</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Yêu cầu bảo hành của bạn đã được cập nhật.</p>
                      <table style="width:100%%;border-collapse:collapse;">
                        <tr><td style="padding:8px"><b>Sản phẩm</b></td><td>%s</td></tr>
                        <tr><td style="padding:8px"><b>Trạng thái</b></td><td>
                          <span style="background:%s;color:white;padding:6px 14px;border-radius:20px;">%s</span>
                        </td></tr>
                        <tr><td style="padding:8px"><b>Mô tả lỗi</b></td><td>%s</td></tr>
                      </table>
                      %s
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, sanPham, mauTrangThai, textTrangThai, request.getIssueDescription(), ghiChuThem);

        helper.setText(html, true);
        mailSender.send(message);
    }

    /** Gửi trước 1 ngày cho khách có lịch hẹn bảo hành vào ngày mai — nhắc để giảm tỉ lệ khách
     * quên không đến (xem WarrantyService.quetLichHenBaoHanh, chạy 7h sáng mỗi ngày). */
    public void sendWarrantyAppointmentReminderEmail(WarrantyRequest request) throws MessagingException {
        String email = request.getWarranty().getNguoiDung().getEmail();
        String tenKhach = request.getWarranty().getNguoiDung().getHoTen();
        String sanPham = request.getWarranty().getOrderItem().getTenSanPham();
        String ngayHen = request.getNgayHen() != null
                ? request.getNgayHen().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                : "";
        String diaDiem = "tan_noi".equals(request.getHinhThuc())
                ? "Kỹ thuật viên sẽ đến tận nơi theo địa chỉ bạn đã đăng ký."
                : "Mang máy tới cửa hàng: " + (request.getCenter() != null ? request.getCenter().getTen() : "cửa hàng đã chọn") + ".";

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(email);
        helper.setSubject("Nhắc lịch hẹn bảo hành ngày mai - CNTTShop");

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#fd7e14;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Nhắc lịch hẹn bảo hành</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Bạn có lịch hẹn bảo hành vào <b>ngày mai (%s)</b> cho sản phẩm <b>%s</b>.</p>
                      <p>%s</p>
                      <p style="font-size:13px;color:#777">Nếu không thể đến đúng hẹn, vui lòng liên hệ shop sớm để đặt lại lịch khác.</p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, ngayHen, sanPham, diaDiem);

        helper.setText(html, true);
        mailSender.send(message);
    }

    public void sendOrderPlacedCodEmail(Order order) throws MessagingException {
        String noiDung = """
                <p>Đơn hàng của bạn đã được tiếp nhận và đang được chuẩn bị.</p>
                <p>Bạn sẽ thanh toán <b>%s</b> trực tiếp cho nhân viên giao hàng khi nhận được sản phẩm (COD).</p>
                """.formatted(fmtTien(order.getTongTien()));
        guiMailDonHang(order, "Đặt hàng thành công - " + order.getMaDonHang(),
                "Đặt hàng thành công", "#198754", noiDung);
    }

    public void sendOrderAwaitingPaymentEmail(Order order, String paymentMethodCode) throws MessagingException {
        String huongDan = "banking".equals(paymentMethodCode)
                ? "Vui lòng chuyển khoản tới <b>Vietcombank - 0123456789 - CNTTSHOP</b>, nội dung chuyển khoản ghi mã đơn <b>"
                        + order.getMaDonHang() + "</b>, sau đó nộp ảnh biên lai trong mục \"Đơn hàng của tôi\"."
                : "Vui lòng hoàn tất thanh toán thẻ trong phiên thanh toán vừa mở. Nếu phiên đã đóng, bạn có thể mở lại từ mục \"Đơn hàng của tôi\".";

        String noiDung = """
                <p>Đơn hàng của bạn đã được tiếp nhận nhưng <b>chưa hoàn tất thanh toán</b>.</p>
                <p>%s</p>
                <p style="color:#dc3545"><b>Lưu ý:</b> đơn hàng sẽ được giữ trong vòng <b>24 giờ</b> kể từ thời điểm đặt hàng.
                Nếu chưa nhận được thanh toán sau thời gian này, đơn sẽ tự động bị hủy.</p>
                """.formatted(huongDan);
        guiMailDonHang(order, "Đơn hàng chờ thanh toán - " + order.getMaDonHang(),
                "Đơn hàng đang chờ thanh toán", "#fd7e14", noiDung);
    }

    public void sendPaymentConfirmedEmail(Order order) throws MessagingException {
        String noiDung = """
                <p>Chúng tôi đã nhận được thanh toán <b>%s</b> cho đơn hàng của bạn.</p>
                <p>Đơn hàng đang được xử lý và sẽ sớm được giao tới bạn.</p>
                """.formatted(fmtTien(order.getTongTien()));
        guiMailDonHang(order, "Thanh toán thành công - " + order.getMaDonHang(),
                "Thanh toán thành công", "#198754", noiDung);
    }

    public void sendOrderConfirmedEmail(Order order) throws MessagingException {
        String noiDung = """
                <p>Đơn hàng của bạn đã được <b>xác nhận</b> và đang được chuẩn bị.</p>
                """;
        guiMailDonHang(order, "Đơn hàng đã được xác nhận - " + order.getMaDonHang(),
                "Đã xác nhận đơn hàng", "#0d6efd", noiDung);
    }

    public void sendOrderProcessingEmail(Order order) throws MessagingException {
        String noiDung = """
                <p>Đơn hàng của bạn đang được <b>đóng gói</b> để chuẩn bị giao đi.</p>
                """;
        guiMailDonHang(order, "Đơn hàng đang đóng gói - " + order.getMaDonHang(),
                "Đang đóng gói", "#6f42c1", noiDung);
    }

    public void sendOrderShippedEmail(Order order) throws MessagingException {
        String noiDung = laDonNoiThanhHaiPhong(order)
                ? """
                  <p>Đơn hàng của bạn đang được <b>giao đi</b> bởi đội ngũ giao hàng CNTTShop.</p>
                  <p>Dự kiến: <b>%s</b>.</p>
                  """.formatted(order.getThoiGianGiaoDuKienHienThi())
                : """
                  <p>Đơn hàng của bạn đã được bàn giao cho đơn vị vận chuyển <b>%s</b>.</p>
                  <p>Dự kiến giao hàng: <b>%s</b>.</p>
                  """.formatted(order.getNhanTuyChonGiaoHangHienThi(), order.getThoiGianGiaoDuKienHienThi());
        guiMailDonHang(order, "Đơn hàng đang giao - " + order.getMaDonHang(),
                "Đang giao hàng", "#0dcaf0", noiDung);
    }

    public void sendOrderDeliveredEmail(Order order) throws MessagingException {
        String daoGiaoBoi = laDonNoiThanhHaiPhong(order)
                ? "<p>Đơn hàng của bạn đã được <b>giao thành công</b>.</p>"
                : "<p>Đơn hàng của bạn đã được <b>giao thành công</b> bởi <b>%s</b>.</p>".formatted(order.getNhanTuyChonGiaoHangHienThi());
        String noiDung = daoGiaoBoi + """
                <p>Hãy dành chút thời gian đánh giá sản phẩm và trải nghiệm giao hàng — bạn có <b>14 ngày</b>
                kể từ hôm nay để đánh giá.</p>
                <p style="text-align:center;margin-top:16px">
                  <a href="%s/tai-khoan/don-hang/%d/danh-gia"
                     style="display:inline-block;background:#198754;color:white;text-decoration:none;
                            padding:10px 22px;border-radius:8px;font-weight:bold">Đánh giá ngay</a>
                </p>
                """.formatted(frontendUrl, order.getId());
        guiMailDonHang(order, "Đơn hàng đã giao thành công - " + order.getMaDonHang(),
                "Đơn hàng hoàn tất", "#198754", noiDung);
    }

    private boolean laDonNoiThanhHaiPhong(Order order) {
        return order.getMaTuyChonGiaoHang() != null && MA_TUY_CHON_NOI_THANH.contains(order.getMaTuyChonGiaoHang());
    }

    public void sendOrderExpiredEmail(Order order) throws MessagingException {
        String noiDung = """
                <p>Đơn hàng của bạn đã bị <b>hủy tự động</b> do chưa hoàn tất thanh toán trong vòng 24 giờ kể từ khi đặt hàng.</p>
                <p>Nếu vẫn muốn mua các sản phẩm này, vui lòng đặt hàng lại.</p>
                """;
        guiMailDonHang(order, "Đơn hàng đã hết hạn - " + order.getMaDonHang(),
                "Đơn hàng đã hết hạn", "#dc3545", noiDung);
    }

    /** Gửi khi khách đổi Xu CT lấy mã giảm giá trên trang khuyến mãi (xem RedemptionService). */
    public void sendCouponRedeemedEmail(String toEmail, String tenKhach, String tenMucDoi, String maCoupon)
            throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("Đổi thưởng thành công - CNTTShop");

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#198754;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Đổi thưởng thành công</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Bạn vừa đổi <b>%s</b> bằng Xu CT. Mã giảm giá của bạn:</p>
                      <div style="text-align:center;margin:20px 0;padding:16px;border:2px dashed #198754;border-radius:10px;font-size:22px;font-weight:bold;letter-spacing:2px;color:#198754;">
                        %s
                      </div>
                      <p style="font-size:13px;color:#777">Áp dụng mã này ở trang thanh toán. Mã chỉ dùng được 1 lần.</p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, tenMucDoi, maCoupon);

        helper.setText(html, true);
        mailSender.send(message);
    }

    /** Nhắc coupon sắp hết hạn (xem RedemptionService.nhacCouponSapHetHan). */
    public void sendCouponExpiringEmail(String toEmail, String tenKhach, String maCoupon, String hanSuDung)
            throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("Mã giảm giá của bạn sắp hết hạn - CNTTShop");

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#fd7e14;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Mã giảm giá sắp hết hạn</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Mã giảm giá dưới đây của bạn sẽ hết hạn vào <b>%s</b>. Hãy dùng trước khi hết hiệu lực nhé!</p>
                      <div style="text-align:center;margin:20px 0;padding:16px;border:2px dashed #fd7e14;border-radius:10px;font-size:22px;font-weight:bold;letter-spacing:2px;color:#fd7e14;">
                        %s
                      </div>
                      <p style="font-size:13px;color:#777">Áp dụng mã ở trang thanh toán. Mã chỉ dùng được 1 lần.</p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, hanSuDung, maCoupon);

        helper.setText(html, true);
        mailSender.send(message);
    }

    /** Sản phẩm trong wishlist vừa giảm giá (xem WishlistService.baoGiamGia). */
    public void sendWishlistDiscountEmail(String toEmail, String tenKhach, String tenSanPham,
                                          String slug, java.math.BigDecimal giaCu, java.math.BigDecimal giaMoi)
            throws jakarta.mail.MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("🔥 Sản phẩm bạn yêu thích vừa giảm giá - CNTTShop");

        String link = frontendUrl + "/san-pham/" + slug;
        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#dc3545;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Sản phẩm yêu thích giảm giá</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p><b>%s</b> trong danh sách yêu thích của bạn vừa giảm giá:</p>
                      <div style="text-align:center;margin:20px 0;padding:16px;background:#f8f9fa;border-radius:10px;">
                        <span style="text-decoration:line-through;color:#999;font-size:14px;">%s đ</span>
                        <span style="font-size:24px;font-weight:bold;color:#dc3545;margin-left:10px;">%s đ</span>
                      </div>
                      <p style="text-align:center">
                        <a href="%s" style="display:inline-block;background:#dc3545;color:white;text-decoration:none;padding:12px 26px;border-radius:8px;font-weight:bold;">Xem sản phẩm</a>
                      </p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b> vì sản phẩm này nằm trong danh sách yêu thích của bạn.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, tenSanPham, giaCu.toBigInteger(), giaMoi.toBigInteger(), link);

        helper.setText(html, true);
        mailSender.send(message);
    }

    /** Gửi khi admin khoá tài khoản (xem AdminApiController#lockCustomer). lockUntil null = khoá vĩnh viễn. */
    public void sendAccountLockedEmail(String toEmail, String tenKhach, String reason, java.time.LocalDateTime lockUntil)
            throws MessagingException {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(toEmail);
        helper.setSubject("Tài khoản của bạn đã bị khoá - CNTTShop");

        String hanKhoa = lockUntil != null
                ? "Đến " + lockUntil.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy"))
                : "Không có thời hạn (khoá vĩnh viễn)";

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:#dc3545;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">Thông báo khoá tài khoản</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Tài khoản của bạn trên hệ thống CNTTShop vừa bị <b>khoá</b>.</p>
                      <table style="width:100%%;border-collapse:collapse;">
                        <tr><td style="padding:8px"><b>Lý do</b></td><td>%s</td></tr>
                        <tr><td style="padding:8px"><b>Thời hạn</b></td><td>%s</td></tr>
                      </table>
                      <p>Nếu bạn cho rằng đây là nhầm lẫn, vui lòng liên hệ bộ phận chăm sóc khách hàng của CNTTShop để được hỗ trợ.</p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(tenKhach, reason, hanKhoa);

        helper.setText(html, true);
        mailSender.send(message);
    }

    private String fmtTien(java.math.BigDecimal tien) {
        return String.format("%,d", tien.longValue()).replace(",", ".") + "đ";
    }

    /** Khung HTML dùng chung cho mọi mail liên quan tới đơn hàng — chỉ khác tiêu đề, màu banner
     * và đoạn nội dung chính (xem các hàm sendXxxEmail ở trên). */
    private void guiMailDonHang(Order order, String tieuDeMail, String tieuDeBanner, String mauBanner, String noiDungChinh)
            throws MessagingException {
        String email = order.getNguoiDung().getEmail();
        String tenKhach = order.getNguoiDung().getHoTen();

        StringBuilder danhSachSp = new StringBuilder();
        List<OrderItem> items = order.getChiTiet() == null ? List.of() : order.getChiTiet();
        for (OrderItem oi : items) {
            danhSachSp.append("""
                    <tr>
                      <td style="padding:6px 8px;border-bottom:1px solid #eee">%s</td>
                      <td style="padding:6px 8px;border-bottom:1px solid #eee;text-align:center">x%d</td>
                      <td style="padding:6px 8px;border-bottom:1px solid #eee;text-align:right">%s</td>
                    </tr>
                    """.formatted(oi.getTenSanPham(), oi.getSoLuong(), fmtTien(oi.getThanhTien())));
        }

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        helper.setTo(email);
        helper.setSubject(tieuDeMail + " - CNTTShop");

        String html = """
                <div style="font-family:Arial;background:#f5f5f5;padding:30px;">
                  <div style="max-width:600px;margin:auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 0 15px rgba(0,0,0,.08);">
                    <div style="background:%s;color:white;padding:20px;text-align:center;">
                      <h2 style="margin:0">CNTTShop</h2>
                      <p style="margin:6px 0 0">%s</p>
                    </div>
                    <div style="padding:28px;">
                      <h3>Xin chào %s,</h3>
                      <p>Mã đơn hàng: <b>%s</b></p>
                      %s
                      <table style="width:100%%;border-collapse:collapse;margin-top:14px">
                        %s
                      </table>
                      <p style="text-align:right;margin-top:10px"><b>Tổng cộng: %s</b></p>
                      <hr>
                      <p style="font-size:13px;color:#777">Email được gửi tự động từ hệ thống <b>CNTTShop</b>.</p>
                    </div>
                  </div>
                </div>
                """.formatted(mauBanner, tieuDeBanner, tenKhach, order.getMaDonHang(), noiDungChinh,
                        danhSachSp, fmtTien(order.getTongTien()));

        helper.setText(html, true);
        mailSender.send(message);
    }
}
