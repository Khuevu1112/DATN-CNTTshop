package com.fpoly.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyHistory;
import com.fpoly.model.WarrantyRequest;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.WarrantyHistoryRepository;
import com.fpoly.repository.WarrantyRepository;
import com.fpoly.repository.WarrantyRequestRepository;

@Service
public class WarrantyService {

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private MailService mailService;

    @Autowired
    private WarrantyHistoryRepository historyRepo;

    @Autowired
    private WarrantyRepository warrantyRepo;

    @Autowired
    private WarrantyRequestRepository requestRepo;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private com.fpoly.repository.ServiceCenterRepository serviceCenterRepo;

    private static final List<String> VALID_REQUEST_STATUS =
            List.of("pending", "accepted", "processing", "resolved", "rejected", "no_show");

    /** Các trạng thái coi là "còn đang chờ xử lý" — dùng để lọc trong job quét lịch hẹn hằng ngày. */
    private static final List<String> TRANG_THAI_DANG_CHO = List.of("pending", "accepted");

    /** Phụ phí cố định khi chọn bảo hành tận nơi thay vì mang tới cửa hàng. */
    private static final java.math.BigDecimal PHU_PHI_TAN_NOI = new java.math.BigDecimal("150000");

    /** Bỏ ký tự dễ nhìn nhầm (0/O, 1/I) khỏi phần ngẫu nhiên của mã — khách hay đọc mã qua
     * điện thoại cho tổng đài. */
    private static final String BANG_CHU = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final java.util.Random random = new java.util.Random();

    /** Sinh mã bảo hành BHCNTT + 4 ký tự, kiểm trùng ở tầng CSDL. Sinh TRƯỚC khi lưu để cột
     * ma_bao_hanh không bao giờ NULL, nhờ đó ràng buộc UNIQUE là index thường (không cần
     * filtered index + QUOTED_IDENTIFIER cho mọi lần ghi về sau). */
    private String sinhMaBaoHanh() {
        for (int lan = 0; lan < 12; lan++) {
            StringBuilder sb = new StringBuilder("BHCNTT");
            for (int i = 0; i < 4; i++) sb.append(BANG_CHU.charAt(random.nextInt(BANG_CHU.length())));
            String ma = sb.toString();
            if (!warrantyRepo.existsByMaBaoHanh(ma)) return ma;
        }
        throw new RuntimeException("Không sinh được mã bảo hành, vui lòng thử lại.");
    }

    /** Tạo phiếu bảo hành cho toàn bộ sản phẩm trong đơn (gọi khi đơn chuyển 'delivered'). */
    @Transactional
    public void createWarranty(Order order) {
        for (OrderItem item : order.getChiTiet()) {
            if (warrantyRepo.existsByOrderItem(item)) continue;

            Warranty w = new Warranty();
            w.setOrderItem(item);
            w.setNguoiDung(order.getNguoiDung());
            w.setMaBaoHanh(sinhMaBaoHanh());
            w.setStartDate(LocalDate.now());
            w.setEndDate(LocalDate.now().plusMonths(12));
            w.setStatus("active");
            warrantyRepo.save(w);
        }
    }

    public List<Warranty> getAllWarranty() {
        return warrantyRepo.findAllByOrderByIdDesc();
    }

    public List<Warranty> getWarrantyByStatus(String status) {
        return warrantyRepo.findByStatusOrderByIdDesc(status);
    }

    public Warranty getById(Integer id) {
        return warrantyRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phiếu bảo hành"));
    }

    @Transactional
    public void updateStatus(Integer id, String status) {
        Warranty w = getById(id);
        w.setStatus(status);
        warrantyRepo.save(w);
    }

    @Transactional
    public void createRequest(Integer warrantyId, String email, String issue) {
        createRequest(warrantyId, email, issue, null, null, null);
    }

    /** Gửi yêu cầu bảo hành kèm lịch hẹn.
     *
     * @param ngayHen   ngày khách hẹn (null = chưa chọn)
     * @param hinhThuc  "tan_noi" (tận nơi, cộng phụ phí) | "cua_hang" (mang tới cửa hàng)
     * @param centerId  trung tâm khách chọn khi mang tới cửa hàng; bỏ qua với tận nơi
     */
    @Transactional
    public void createRequest(Integer warrantyId, String email, String issue,
                              LocalDate ngayHen, String hinhThuc, Integer centerId) {
        Warranty warranty = getById(warrantyId);
        if (!warranty.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Bạn không có quyền gửi yêu cầu cho phiếu bảo hành này");
        }
        if (issue == null || issue.isBlank()) {
            throw new RuntimeException("Vui lòng mô tả sự cố cần bảo hành");
        }

        WarrantyRequest request = new WarrantyRequest();
        request.setWarranty(warranty);
        request.setIssueDescription(issue.trim());
        request.setRequestStatus("pending");
        request.setNgayHen(ngayHen);

        // Mặc định mang tới cửa hàng nếu không khai — an toàn vì không phát sinh phụ phí ngoài ý.
        String ht = "tan_noi".equals(hinhThuc) ? "tan_noi" : "cua_hang";
        request.setHinhThuc(ht);
        if ("tan_noi".equals(ht)) {
            request.setPhuPhi(PHU_PHI_TAN_NOI);
            request.setCenter(null);
        } else {
            request.setPhuPhi(java.math.BigDecimal.ZERO);
            // Mang tới cửa hàng thì phải biết cửa hàng nào.
            if (centerId == null) {
                throw new RuntimeException("Vui lòng chọn cửa hàng để mang máy tới.");
            }
            request.setCenter(serviceCenterRepo.findById(centerId)
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy cửa hàng đã chọn.")));
        }
        requestRepo.save(request);
    }

    /** Admin chỉ được đổi lại NGÀY HẸN (vd: khách gọi điện xin dời lịch). Hình thức bảo hành
     * (mang ra cửa hàng / sửa tận nơi) và chọn cửa hàng nào là quyết định của KHÁCH khi gửi yêu
     * cầu — admin không có quyền tự đổi thay khách, chỉ được tiếp nhận & xử lý theo đúng lựa
     * chọn ban đầu của khách. Không ghi lịch sử trạng thái vì đây chỉ chỉnh 1 trường ngày, không
     * phải chuyển bước xử lý. */
    @Transactional
    public void updateRequestAppointmentDate(Integer requestId, LocalDate ngayHen) {
        WarrantyRequest request = getRequest(requestId);
        request.setNgayHen(ngayHen);
        requestRepo.save(request);
    }

    public List<WarrantyRequest> getRequests(Integer warrantyId) {
        Warranty warranty = getById(warrantyId);
        return requestRepo.findByWarrantyOrderByCreatedAtDesc(warranty);
    }

    public List<WarrantyHistory> getHistory(WarrantyRequest request) {
        return historyRepo.findByRequestOrderByCreatedAtAsc(request);
    }

    public List<Warranty> getWarrantyOfUser(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return warrantyRepo.findByNguoiDung(user);
    }

    public List<WarrantyRequest> getAllRequest() {
        return requestRepo.findAllByOrderByCreatedAtDesc();
    }

    public WarrantyRequest getRequest(Integer id) {
        return requestRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy yêu cầu"));
    }

    @Transactional
    public void updateRequestStatus(Integer requestId, String status, String note) {
        if (!VALID_REQUEST_STATUS.contains(status)) {
            throw new RuntimeException("Trạng thái không hợp lệ");
        }
        WarrantyRequest request = getRequest(requestId);
        request.setRequestStatus(status);
        requestRepo.save(request);

        WarrantyHistory history = new WarrantyHistory();
        history.setRequest(request);
        history.setStatus(status);
        history.setNote(note);
        history.setCreatedAt(LocalDateTime.now());
        historyRepo.save(history);

        try {
            mailService.sendWarrantyStatusEmail(request);
        } catch (Exception e) {
            // Không chặn luồng cập nhật trạng thái nếu gửi mail thất bại
        }

        notificationService.taoChoUser(
                request.getWarranty().getNguoiDung().getId(),
                "warranty_status",
                "Yêu cầu bảo hành cập nhật",
                "Yêu cầu bảo hành \"" + request.getWarranty().getOrderItem().getTenSanPham() + "\" hiện: " + nhanTrangThaiBaoHanh(status),
                "/tai-khoan/bao-hanh"
        );
    }

    private String nhanTrangThaiBaoHanh(String status) {
        return switch (status) {
            case "pending" -> "Chờ tiếp nhận";
            case "accepted" -> "Đã tiếp nhận";
            case "processing" -> "Đang xử lý";
            case "resolved" -> "Đã xử lý xong";
            case "rejected" -> "Từ chối";
            case "no_show" -> "Khách không đến hẹn";
            default -> status;
        };
    }

    /**
     * Quét định kỳ mỗi ngày lúc 7h sáng, xử lý 3 việc liên quan tới lịch hẹn bảo hành:
     *  1. Yêu cầu hẹn NGÀY MAI, còn đang chờ xử lý -> gửi mail nhắc khách.
     *  2. Yêu cầu hẹn HÔM NAY, còn đang chờ xử lý -> báo cho admin để chuẩn bị tiếp khách.
     *  3. Yêu cầu hẹn ĐÃ QUA (trước hôm nay) mà vẫn còn đang chờ xử lý -> tự động đánh dấu
     *     "khách không đến" (no_show), ghi lịch sử, báo admin và gửi mail cho khách.
     */
    @Scheduled(cron = "0 0 7 * * *")
    @Transactional
    public void quetLichHenBaoHanh() {
        LocalDate homNay = LocalDate.now();
        LocalDate ngayMai = homNay.plusDays(1);

        // 1) Nhắc khách trước 1 ngày
        for (WarrantyRequest r : requestRepo.findByNgayHenAndRequestStatusIn(ngayMai, TRANG_THAI_DANG_CHO)) {
            try {
                mailService.sendWarrantyAppointmentReminderEmail(r);
            } catch (Exception e) {
                // Không chặn job nếu 1 mail gửi lỗi
            }
        }

        // 2) Báo admin: hôm nay có khách hẹn tới
        for (WarrantyRequest r : requestRepo.findByNgayHenAndRequestStatusIn(homNay, TRANG_THAI_DANG_CHO)) {
            notificationService.tao(
                    "warranty_today",
                    "Hôm nay có lịch hẹn bảo hành",
                    r.getWarranty().getNguoiDung().getHoTen() + " hẹn bảo hành \""
                            + r.getWarranty().getOrderItem().getTenSanPham() + "\" hôm nay.",
                    "/warranty"
            );
        }

        // 3) Quá hẹn mà khách chưa tới -> tự động đánh dấu "khách không đến"
        for (WarrantyRequest r : requestRepo.findByNgayHenBeforeAndRequestStatusIn(homNay, TRANG_THAI_DANG_CHO)) {
            r.setRequestStatus("no_show");
            requestRepo.save(r);

            WarrantyHistory history = new WarrantyHistory();
            history.setRequest(r);
            history.setStatus("no_show");
            history.setNote("Tự động đánh dấu: quá ngày hẹn (" + r.getNgayHen() + ") mà khách chưa tới.");
            history.setCreatedAt(LocalDateTime.now());
            historyRepo.save(history);

            notificationService.tao(
                    "warranty_no_show",
                    "Khách không đến hẹn bảo hành",
                    r.getWarranty().getNguoiDung().getHoTen() + " không đến hẹn ngày " + r.getNgayHen()
                            + " cho sản phẩm \"" + r.getWarranty().getOrderItem().getTenSanPham() + "\".",
                    "/warranty"
            );

            try {
                mailService.sendWarrantyStatusEmail(r);
            } catch (Exception e) {
                // Không chặn job nếu 1 mail gửi lỗi
            }
        }
    }
}
