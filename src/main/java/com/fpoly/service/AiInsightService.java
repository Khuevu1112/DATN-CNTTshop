package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.fpoly.dto.AiInsightDtos.AiAlertDto;
import com.fpoly.dto.AiInsightDtos.AiAlertsDto;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * "Cảnh báo hệ thống" (trước đây gọi là "AI Phân tích") — chỉ dùng công thức/ngưỡng số do Java
 * tự tính, KHÔNG gọi AI trả phí. Bỏ phần "tóm tắt tự động do AI viết" vì cần trả phí Anthropic
 * API — có thể bật lại sau nếu cần, xem lịch sử git để khôi phục AnthropicClient.java.
 *
 * Đợt 1: chỉ dùng dữ liệu dòng tiền + doanh thu + đơn hàng (chưa gồm tồn kho, bảo hành...).
 */
@Service
public class AiInsightService {

    @PersistenceContext
    private EntityManager em;

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // ===== C. Cảnh báo bất thường =====
    public AiAlertsDto getAnomalyAlerts() {
        List<AiAlertDto> alerts = new ArrayList<>();
        Map<String, Object> data = thuThapSoLieu();

        BigDecimal doanhThu7 = (BigDecimal) data.get("doanhThu7NgayGanNhat");
        BigDecimal doanhThu7Truoc = (BigDecimal) data.get("doanhThu7NgayTruocDo");
        BigDecimal dongTienRong7 = (BigDecimal) data.get("dongTienRong7NgayGanNhat");
        double tiLeHuy = ((Number) data.get("tiLeHuy7NgayGanNhat")).doubleValue();

        // 1) Doanh thu giảm > 20% so với 7 ngày liền trước
        if (doanhThu7Truoc.signum() > 0) {
            BigDecimal thayDoi = doanhThu7.subtract(doanhThu7Truoc)
                    .divide(doanhThu7Truoc, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
            if (thayDoi.compareTo(BigDecimal.valueOf(-20)) < 0) {
                alerts.add(new AiAlertDto("danger", "Doanh thu giảm mạnh",
                        "Doanh thu 7 ngày gần nhất (" + formatTien(doanhThu7) + ") giảm "
                                + thayDoi.abs().setScale(1, RoundingMode.HALF_UP) + "% so với 7 ngày trước đó ("
                                + formatTien(doanhThu7Truoc) + ")."));
            }
        }

        // 2) Dòng tiền ròng 7 ngày gần nhất âm
        if (dongTienRong7.signum() < 0) {
            alerts.add(new AiAlertDto("danger", "Dòng tiền ròng đang âm",
                    "7 ngày gần nhất, chi phí nhập hàng đang vượt doanh thu ghi nhận được, dòng tiền ròng = "
                            + formatTien(dongTienRong7) + "."));
        }

        // 3) Tỉ lệ đơn huỷ > 15%
        if (tiLeHuy > 15) {
            alerts.add(new AiAlertDto("warning", "Tỉ lệ đơn huỷ cao",
                    String.format("%.1f%% đơn hàng trong 7 ngày gần nhất bị huỷ — cao hơn mức bình thường (15%%).", tiLeHuy)));
        }

        // 4) Bán lỗ vốn — giá bán hiện tại thấp hơn giá nhập gần nhất
        kiemTraBanLoVon(alerts);

        // 5) Lệch tồn kho bất thường
        kiemTraLechTonKho(alerts);

        // 6) Xử lý chậm — đơn hàng / yêu cầu bảo hành bị "ngâm" quá lâu
        kiemTraXuLyCham(alerts);

        return new AiAlertsDto(alerts, LocalDateTime.now().format(DAY_FMT));
    }

    /** 9. Cảnh báo bán lỗ vốn: so giá bán hiện tại (PRODUCT_VARIANT.price) với giá nhập GẦN NHẤT
     * của chính biến thể đó (STOCK_MOVEMENT.reason='nhap_hang', lấy dòng mới nhất theo created_at). */
    @SuppressWarnings("unchecked")
    private void kiemTraBanLoVon(List<AiAlertDto> alerts) {
        List<Object[]> rows = em.createNativeQuery(
                "SELECT p.name, v.sku, v.price, latest.unit_cost FROM PRODUCT_VARIANT v " +
                "JOIN PRODUCT p ON p.id = v.product_id " +
                "JOIN ( " +
                "  SELECT sm.variant_id, sm.unit_cost, " +
                "         ROW_NUMBER() OVER (PARTITION BY sm.variant_id ORDER BY sm.created_at DESC) rn " +
                "  FROM STOCK_MOVEMENT sm WHERE sm.reason = 'nhap_hang' " +
                ") latest ON latest.variant_id = v.id AND latest.rn = 1 " +
                "WHERE v.price < latest.unit_cost"
        ).getResultList();

        if (rows.isEmpty()) return;

        BigDecimal loTong = BigDecimal.ZERO;
        List<String> viDu = new ArrayList<>();
        for (Object[] r : rows) {
            BigDecimal gia = (BigDecimal) r[2];
            BigDecimal giaNhap = (BigDecimal) r[3];
            loTong = loTong.add(giaNhap.subtract(gia));
            if (viDu.size() < 3) {
                viDu.add(r[0] + " (SKU " + r[1] + "): bán " + formatTien(gia) + " < nhập " + formatTien(giaNhap));
            }
        }
        alerts.add(new AiAlertDto("danger", "Có sản phẩm đang bán dưới giá vốn",
                rows.size() + " biến thể đang bán thấp hơn giá nhập gần nhất, tổng lỗ ước tính mỗi lượt bán hết "
                        + formatTien(loTong) + ". Ví dụ: " + String.join("; ", viDu) + "."));
    }

    /** 17. Phát hiện lệch tồn kho bất thường — phạm vi khả thi với dữ liệu hiện có:
     *  a) Tồn kho ÂM (dấu hiệu rõ nhất của lỗi bán vượt tồn / sai lệch dữ liệu).
     *  b) Với biến thể CHƯA từng bán (không có trong ORDER_ITEM nào), tồn kho lẽ ra phải khớp
     *     đúng tổng các phiếu nhập/điều chỉnh — nếu lệch thì có gì đó bất thường (chỉnh tay không
     *     qua hệ thống, lỗi đồng bộ...).
     * Lưu ý: hệ thống hiện CHƯA ghi phiếu xuất kho khi bán hàng (STOCK_MOVEMENT chỉ có 2 loại
     * 'nhap_hang'/'dieu_chinh'), nên chưa thể đối chiếu đầy đủ cho biến thể đã từng bán. */
    @SuppressWarnings("unchecked")
    private void kiemTraLechTonKho(List<AiAlertDto> alerts) {
        List<Object[]> amRows = em.createNativeQuery(
                "SELECT p.name, v.sku, v.stock FROM PRODUCT_VARIANT v " +
                "JOIN PRODUCT p ON p.id = v.product_id WHERE v.stock < 0"
        ).getResultList();
        if (!amRows.isEmpty()) {
            List<String> viDu = new ArrayList<>();
            for (Object[] r : amRows) {
                if (viDu.size() < 3) viDu.add(r[0] + " (SKU " + r[1] + "): " + r[2]);
            }
            alerts.add(new AiAlertDto("danger", "Tồn kho âm",
                    amRows.size() + " biến thể có tồn kho âm — dấu hiệu bán vượt số lượng thực có. Ví dụ: "
                            + String.join("; ", viDu) + "."));
        }

        List<Object[]> lechRows = em.createNativeQuery(
                "SELECT p.name, v.sku, v.stock, ISNULL(mv.tong,0) FROM PRODUCT_VARIANT v " +
                "JOIN PRODUCT p ON p.id = v.product_id " +
                "LEFT JOIN (SELECT variant_id, SUM(change_qty) tong FROM STOCK_MOVEMENT GROUP BY variant_id) mv " +
                "  ON mv.variant_id = v.id " +
                "WHERE v.id NOT IN (SELECT DISTINCT variant_id FROM ORDER_ITEM) " +
                "  AND v.stock <> ISNULL(mv.tong,0)"
        ).getResultList();
        if (!lechRows.isEmpty()) {
            List<String> viDu = new ArrayList<>();
            for (Object[] r : lechRows) {
                if (viDu.size() < 3) viDu.add(r[0] + " (SKU " + r[1] + "): tồn " + r[2] + " ≠ tổng phiếu nhập " + r[3]);
            }
            alerts.add(new AiAlertDto("warning", "Lệch tồn kho bất thường",
                    lechRows.size() + " biến thể CHƯA từng bán nhưng tồn kho không khớp tổng phiếu nhập/điều chỉnh — có thể đã bị sửa tay không qua hệ thống. Ví dụ: "
                            + String.join("; ", viDu) + "."));
        }
    }

    /** 20. Cảnh báo xử lý chậm: đơn hàng chờ xác nhận > 24h, yêu cầu bảo hành chờ tiếp nhận > 48h. */
    private void kiemTraXuLyCham(List<AiAlertDto> alerts) {
        LocalDateTime nguong24h = LocalDateTime.now().minusHours(24);
        long donCham = ((Number) em.createNativeQuery(
                "SELECT COUNT(*) FROM [ORDER] WHERE status = 'pending' AND created_at < :nguong"
        ).setParameter("nguong", nguong24h).getSingleResult()).longValue();
        if (donCham > 0) {
            alerts.add(new AiAlertDto("warning", "Đơn hàng chờ xác nhận quá lâu",
                    donCham + " đơn hàng đang ở trạng thái \"Chờ xác nhận\" quá 24 giờ — nên xử lý sớm để tránh khách huỷ đơn."));
        }

        LocalDateTime nguong48h = LocalDateTime.now().minusHours(48);
        long baoHanhCham = ((Number) em.createNativeQuery(
                "SELECT COUNT(*) FROM WARRANTY_REQUEST WHERE request_status = 'pending' AND created_at < :nguong"
        ).setParameter("nguong", nguong48h).getSingleResult()).longValue();
        if (baoHanhCham > 0) {
            alerts.add(new AiAlertDto("warning", "Yêu cầu bảo hành chờ tiếp nhận quá lâu",
                    baoHanhCham + " yêu cầu bảo hành đang chờ tiếp nhận quá 48 giờ — khách có thể đang chờ phản hồi."));
        }
    }

    // ===== helpers =====

    private Map<String, Object> thuThapSoLieu() {
        LocalDate today = LocalDate.now();
        LocalDateTime last7Start = today.minusDays(6).atStartOfDay();
        LocalDateTime prev7Start = today.minusDays(13).atStartOfDay();
        LocalDateTime nowEnd = today.plusDays(1).atStartOfDay();

        BigDecimal doanhThu7 = sumOrder(last7Start, nowEnd, "delivered");
        BigDecimal doanhThu7Truoc = sumOrder(prev7Start, last7Start, "delivered");
        BigDecimal chiPhi7 = sumStockMovement(last7Start, nowEnd);

        long tongDon7 = countOrder(last7Start, nowEnd, null);
        long donHuy7 = countOrder(last7Start, nowEnd, "cancelled");
        double tiLeHuy = tongDon7 == 0 ? 0 : (donHuy7 * 100.0 / tongDon7);

        return Map.of(
                "doanhThu7NgayGanNhat", doanhThu7,
                "doanhThu7NgayTruocDo", doanhThu7Truoc,
                "chiPhiNhapHang7NgayGanNhat", chiPhi7,
                "dongTienRong7NgayGanNhat", doanhThu7.subtract(chiPhi7),
                "tongSoDon7NgayGanNhat", tongDon7,
                "soDonHuy7NgayGanNhat", donHuy7,
                "tiLeHuy7NgayGanNhat", tiLeHuy
        );
    }

    private BigDecimal sumOrder(LocalDateTime from, LocalDateTime to, String status) {
        Object r = em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] WHERE status = :status AND created_at >= :from AND created_at < :to"
        ).setParameter("status", status).setParameter("from", from).setParameter("to", to).getSingleResult();
        return (BigDecimal) r;
    }

    private BigDecimal sumStockMovement(LocalDateTime from, LocalDateTime to) {
        Object r = em.createNativeQuery(
                "SELECT ISNULL(SUM(change_qty * unit_cost),0) FROM STOCK_MOVEMENT WHERE reason = 'nhap_hang' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", from).setParameter("to", to).getSingleResult();
        return (BigDecimal) r;
    }

    private long countOrder(LocalDateTime from, LocalDateTime to, String status) {
        String sql = "SELECT COUNT(*) FROM [ORDER] WHERE created_at >= :from AND created_at < :to"
                + (status != null ? " AND status = :status" : "");
        var q = em.createNativeQuery(sql).setParameter("from", from).setParameter("to", to);
        if (status != null) q.setParameter("status", status);
        return ((Number) q.getSingleResult()).longValue();
    }

    private String formatTien(BigDecimal v) {
        if (v == null) return "0đ";
        return String.format("%,dđ", v.longValue());
    }
}
