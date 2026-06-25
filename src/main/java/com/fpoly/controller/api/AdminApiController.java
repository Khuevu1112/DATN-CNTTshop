package com.fpoly.controller.api;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.service.NotificationService;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * REST API cho khu vực ADMIN (Vue admin tiêu thụ).
 * Bảo vệ bằng JWT yêu cầu role ADMIN/STAFF (cấu hình trong SecurityConfig apiSecurityChain).
 */
@RestController
@RequestMapping("/api/admin")
public class AdminApiController {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/dashboard")
    public Map<String, Object> dashboard() {
        Map<String, Object> r = new HashMap<>();

        r.put("todayOrders", em.createNativeQuery(
                "SELECT COUNT(*) FROM [ORDER] WHERE CAST(created_at AS DATE)=CAST(GETDATE() AS DATE)"
        ).getSingleResult());

        r.put("todayRevenue", em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] " +
                "WHERE CAST(created_at AS DATE)=CAST(GETDATE() AS DATE) AND status!='cancelled'"
        ).getSingleResult());

        r.put("totalRevenue", em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] WHERE status!='cancelled'"
        ).getSingleResult());

        r.put("totalCustomers", em.createNativeQuery(
                "SELECT COUNT(*) FROM [USER] WHERE role='customer'"
        ).getSingleResult());

        r.put("newCustomersToday", em.createNativeQuery(
                "SELECT COUNT(*) FROM [USER] WHERE role='customer' AND CAST(created_at AS DATE)=CAST(GETDATE() AS DATE)"
        ).getSingleResult());

        r.put("totalProducts", em.createNativeQuery(
                "SELECT COUNT(*) FROM PRODUCT WHERE is_active=1"
        ).getSingleResult());

        r.put("totalOrders", em.createNativeQuery(
                "SELECT COUNT(*) FROM [ORDER]"
        ).getSingleResult());

        // [order_code, full_name, total_amount, status]
        r.put("recentOrders", em.createNativeQuery(
                "SELECT TOP 8 o.order_code, u.full_name, o.total_amount, o.status " +
                "FROM [ORDER] o JOIN [USER] u ON o.user_id=u.id ORDER BY o.created_at DESC"
        ).getResultList());

        // [dd/MM/yyyy, count] — 7 ngày gần nhất
        r.put("last7Days", em.createNativeQuery(
                "SELECT CONVERT(VARCHAR,CAST(created_at AS DATE),103), COUNT(*) " +
                "FROM [ORDER] WHERE created_at>=DATEADD(DAY,-6,CAST(GETDATE() AS DATE)) " +
                "GROUP BY CAST(created_at AS DATE) ORDER BY CAST(created_at AS DATE) ASC"
        ).getResultList());

        // [dd/MM/yyyy, doanh thu] — 7 ngày gần nhất, loại đơn đã huỷ
        r.put("last7Revenue", em.createNativeQuery(
                "SELECT CONVERT(VARCHAR,CAST(created_at AS DATE),103), ISNULL(SUM(total_amount),0) " +
                "FROM [ORDER] WHERE created_at>=DATEADD(DAY,-6,CAST(GETDATE() AS DATE)) AND status!='cancelled' " +
                "GROUP BY CAST(created_at AS DATE) ORDER BY CAST(created_at AS DATE) ASC"
        ).getResultList());

        // [status, count]
        r.put("statusBreakdown", em.createNativeQuery(
                "SELECT status, COUNT(*) FROM [ORDER] GROUP BY status"
        ).getResultList());

        // [id, name, brand_name, stock] — top 6 sắp hết hàng (stock thấp nhất theo biến thể)
        r.put("lowStock", em.createNativeQuery(
                "SELECT TOP 6 p.id, p.name, b.name, MIN(v.stock) " +
                "FROM PRODUCT p JOIN PRODUCT_VARIANT v ON v.product_id=p.id " +
                "LEFT JOIN BRAND b ON p.brand_id=b.id " +
                "WHERE p.is_active=1 GROUP BY p.id, p.name, b.name ORDER BY MIN(v.stock) ASC"
        ).getResultList());

        return r;
    }

    @GetMapping("/notifications")
    public List<Map<String, Object>> notifications() {
        return notificationService.layGanDay().stream().map(n -> {
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

    @GetMapping("/notifications/unread-count")
    public Map<String, Object> unreadCount() {
        return Map.of("count", notificationService.soChuaDoc());
    }

    @PostMapping("/notifications/{id}/read")
    public void markRead(@PathVariable Integer id) {
        notificationService.danhDauDaDoc(id);
    }

    @PostMapping("/notifications/read-all")
    public void markAllRead() {
        notificationService.danhDauTatCaDaDoc();
    }
}
