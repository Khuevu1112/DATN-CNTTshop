package com.fpoly.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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

    private static final List<String> VALID_REQUEST_STATUS =
            List.of("pending", "accepted", "processing", "resolved", "rejected");

    /** Tạo phiếu bảo hành cho toàn bộ sản phẩm trong đơn (gọi khi đơn chuyển 'delivered'). */
    @Transactional
    public void createWarranty(Order order) {
        for (OrderItem item : order.getChiTiet()) {
            if (warrantyRepo.existsByOrderItem(item)) continue;

            Warranty w = new Warranty();
            w.setOrderItem(item);
            w.setNguoiDung(order.getNguoiDung());
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
            default -> status;
        };
    }
}
