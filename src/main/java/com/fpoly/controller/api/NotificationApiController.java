package com.fpoly.controller.api;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.service.NotificationService;

/** REST API thông báo phía khách hàng — yêu cầu đăng nhập (xem JWT trong SecurityConfig).
 * Tách riêng khỏi /api/admin/notifications (thông báo chung cho admin/staff) — mỗi user chỉ
 * thấy thông báo của chính mình (đơn hàng, bảo hành...). */
@RestController
@RequestMapping("/api/notifications")
public class NotificationApiController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    private Integer currentUserId(Authentication auth) {
        NguoiDung u = nguoiDungRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
        return u.getId();
    }

    @GetMapping
    public List<Map<String, Object>> list(Authentication auth) {
        return notificationService.layGanDayCuaUser(currentUserId(auth)).stream().map(n -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", n.getId());
            m.put("type", n.getLoai());
            m.put("title", n.getTieuDe());
            m.put("message", n.getNoiDung());
            m.put("link", n.getLink());
            m.put("isRead", n.getDaDoc());
            m.put("createdAt", n.getCreatedAt());
            return m;
        }).toList();
    }

    @GetMapping("/unread-count")
    public Map<String, Object> unreadCount(Authentication auth) {
        return Map.of("count", notificationService.soChuaDocCuaUser(currentUserId(auth)));
    }

    @PostMapping("/{id}/read")
    public void markRead(@PathVariable Integer id, Authentication auth) {
        notificationService.danhDauDaDocCuaUser(id, currentUserId(auth));
    }

    @PostMapping("/read-all")
    public void markAllRead(Authentication auth) {
        notificationService.danhDauTatCaDaDocCuaUser(currentUserId(auth));
    }
}
