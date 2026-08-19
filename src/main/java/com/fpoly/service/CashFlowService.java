package com.fpoly.service;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * Phân tích dòng tiền cho trang admin "Dòng tiền".
 *
 * Tiền vào = doanh thu đơn hàng ĐÃ GIAO THÀNH CÔNG (ORDER.status = 'delivered'), tách theo kênh
 *            bán qua cột ORDER.channel ('online' | 'pos').
 * Tiền ra  = chi phí nhập hàng (STOCK_MOVEMENT.reason = 'nhap_hang').
 * Chưa gồm hoàn tiền đổi trả (hệ thống chưa lưu số tiền hoàn cụ thể) và tín dụng đổi-đồ-cũ
 * (không phải tiền mặt, đã nằm gộp trong discount_amount của đơn hàng sau khi khách dùng).
 */
@Service
public class CashFlowService {

    @PersistenceContext
    private EntityManager em;

    // ===== 1. Báo cáo theo khoảng ngày + nhóm ngày/tháng/năm =====
    public Map<String, Object> getReport(LocalDate fromDate, LocalDate toDate, String groupBy) {
        if (toDate.isBefore(fromDate)) {
            throw new RuntimeException("Ngày kết thúc phải sau ngày bắt đầu");
        }
        if (!List.of("day", "month", "year").contains(groupBy)) groupBy = "day";

        LocalDateTime fromDt = fromDate.atStartOfDay();
        LocalDateTime toDt = toDate.plusDays(1).atStartOfDay();
        String periodExpr = periodExpr(groupBy);

        // Tiền vào — tách theo kênh (online/pos), kèm số đơn hàng
        @SuppressWarnings("unchecked")
        List<Object[]> inRows = em.createNativeQuery(
                "SELECT " + periodExpr + ", channel, COUNT(*), ISNULL(SUM(total_amount),0) FROM [ORDER] " +
                "WHERE status = 'delivered' AND created_at >= :from AND created_at < :to " +
                "GROUP BY " + periodExpr + ", channel"
        ).setParameter("from", fromDt).setParameter("to", toDt).getResultList();

        Map<LocalDate, BigDecimal> inOnline = new HashMap<>();
        Map<LocalDate, BigDecimal> inPos = new HashMap<>();
        Map<LocalDate, Integer> inCount = new HashMap<>();
        for (Object[] r : inRows) {
            LocalDate d = toLocalDate(r[0]);
            String channel = (String) r[1];
            int cnt = ((Number) r[2]).intValue();
            BigDecimal sum = (BigDecimal) r[3];
            if ("pos".equals(channel)) inPos.merge(d, sum, BigDecimal::add);
            else inOnline.merge(d, sum, BigDecimal::add);
            inCount.merge(d, cnt, Integer::sum);
        }

        // Tiền ra — kèm số phiếu nhập kho
        @SuppressWarnings("unchecked")
        List<Object[]> outRows = em.createNativeQuery(
                "SELECT " + periodExpr + ", COUNT(*), ISNULL(SUM(change_qty * unit_cost),0) FROM STOCK_MOVEMENT " +
                "WHERE reason = 'nhap_hang' AND created_at >= :from AND created_at < :to " +
                "GROUP BY " + periodExpr
        ).setParameter("from", fromDt).setParameter("to", toDt).getResultList();

        Map<LocalDate, Integer> outCount = new HashMap<>();
        Map<LocalDate, BigDecimal> outSum = new HashMap<>();
        for (Object[] r : outRows) {
            LocalDate d = toLocalDate(r[0]);
            outCount.put(d, ((Number) r[1]).intValue());
            outSum.put(d, (BigDecimal) r[2]);
        }

        List<LocalDate> periods = buildPeriods(fromDate, toDate, groupBy);
        DateTimeFormatter fmt = labelFormatter(groupBy);
        LocalDate hardEnd = toDate.plusDays(1);

        List<Map<String, Object>> points = new ArrayList<>();
        BigDecimal totalIn = BigDecimal.ZERO, totalOut = BigDecimal.ZERO, cumulative = BigDecimal.ZERO;
        for (LocalDate p : periods) {
            LocalDate pEnd = switch (groupBy) {
                case "month" -> p.plusMonths(1);
                case "year" -> p.plusYears(1);
                default -> p.plusDays(1);
            };
            if (pEnd.isAfter(hardEnd)) pEnd = hardEnd;

            BigDecimal onlineIn = inOnline.getOrDefault(p, BigDecimal.ZERO);
            BigDecimal posIn = inPos.getOrDefault(p, BigDecimal.ZERO);
            BigDecimal cashIn = onlineIn.add(posIn);
            BigDecimal cashOut = outSum.getOrDefault(p, BigDecimal.ZERO);
            BigDecimal net = cashIn.subtract(cashOut);
            cumulative = cumulative.add(net);
            totalIn = totalIn.add(cashIn);
            totalOut = totalOut.add(cashOut);

            Map<String, Object> pt = new LinkedHashMap<>();
            pt.put("periodFrom", p.toString());
            pt.put("periodTo", pEnd.toString()); // cận trên loại trừ — dùng để gọi /cashflow/detail
            pt.put("label", p.format(fmt));
            pt.put("cashIn", cashIn);
            pt.put("cashInOnline", onlineIn);
            pt.put("cashInPos", posIn);
            pt.put("orderCount", inCount.getOrDefault(p, 0));
            pt.put("cashOut", cashOut);
            pt.put("movementCount", outCount.getOrDefault(p, 0));
            pt.put("net", net);
            pt.put("cumulativeNet", cumulative);
            points.add(pt);
        }

        // So sánh với kỳ liền trước, cùng độ dài
        long spanDays = ChronoUnit.DAYS.between(fromDate, toDate) + 1;
        LocalDate prevTo = fromDate.minusDays(1);
        LocalDate prevFrom = prevTo.minusDays(spanDays - 1);
        BigDecimal[] prevTotals = sumRange(prevFrom, prevTo);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("totalCashIn", totalIn);
        result.put("totalCashOut", totalOut);
        result.put("netCashFlow", totalIn.subtract(totalOut));
        result.put("prevTotalCashIn", prevTotals[0]);
        result.put("prevTotalCashOut", prevTotals[1]);
        result.put("cashInChangePct", pctChange(totalIn, prevTotals[0]));
        result.put("cashOutChangePct", pctChange(totalOut, prevTotals[1]));
        result.put("points", points);
        return result;
    }

    // ===== 5. Chi tiết đơn hàng / phiếu nhập kho trong 1 khoảng ngày (khi bấm vào 1 dòng) =====
    public Map<String, Object> getDetail(LocalDate fromDate, LocalDate toExclusiveDate) {
        LocalDateTime fromDt = fromDate.atStartOfDay();
        LocalDateTime toDt = toExclusiveDate.atStartOfDay();

        @SuppressWarnings("unchecked")
        List<Object[]> orderRows = em.createNativeQuery(
                "SELECT id, order_code, channel, total_amount, created_at FROM [ORDER] " +
                "WHERE status = 'delivered' AND created_at >= :from AND created_at < :to " +
                "ORDER BY created_at DESC"
        ).setParameter("from", fromDt).setParameter("to", toDt).getResultList();

        List<Map<String, Object>> orders = new ArrayList<>();
        for (Object[] r : orderRows) {
            Map<String, Object> o = new LinkedHashMap<>();
            o.put("id", r[0]);
            o.put("code", r[1]);
            o.put("channel", r[2]);
            o.put("total", r[3]);
            o.put("createdAt", r[4].toString());
            orders.add(o);
        }

        @SuppressWarnings("unchecked")
        List<Object[]> movementRows = em.createNativeQuery(
                "SELECT sm.id, p.name, v.sku, sm.change_qty, sm.unit_cost, sm.created_at " +
                "FROM STOCK_MOVEMENT sm " +
                "JOIN PRODUCT_VARIANT v ON v.id = sm.variant_id " +
                "JOIN PRODUCT p ON p.id = v.product_id " +
                "WHERE sm.reason = 'nhap_hang' AND sm.created_at >= :from AND sm.created_at < :to " +
                "ORDER BY sm.created_at DESC"
        ).setParameter("from", fromDt).setParameter("to", toDt).getResultList();

        List<Map<String, Object>> movements = new ArrayList<>();
        for (Object[] r : movementRows) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", r[0]);
            m.put("productName", r[1]);
            m.put("sku", r[2]);
            m.put("changeQty", r[3]);
            m.put("unitCost", r[4]);
            m.put("createdAt", r[5].toString());
            movements.add(m);
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("orders", orders);
        result.put("stockMovements", movements);
        return result;
    }

    // ===== 7. Xuất Excel =====
    public byte[] exportExcel(LocalDate fromDate, LocalDate toDate, String groupBy) {
        Map<String, Object> report = getReport(fromDate, toDate, groupBy);
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> points = (List<Map<String, Object>>) report.get("points");

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("Dong tien");

            // Định dạng số nguyên có dấu phân cách nghìn — không có định dạng này, Excel tự hiển
            // thị số lớn (>= ~1e8) theo ký hiệu khoa học (1.06E+08), gây khó đọc dù giá trị đúng.
            org.apache.poi.ss.usermodel.CellStyle moneyStyle = wb.createCellStyle();
            moneyStyle.setDataFormat(wb.createDataFormat().getFormat("#,##0"));

            String[] headers = {
                    "Thoi gian", "Tien vao", "Tien vao (online)", "Tien vao (POS)", "So don hang",
                    "Tien ra", "So phieu nhap", "Dong tien rong", "Luy ke"
            };
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

            int r = 1;
            for (Map<String, Object> p : points) {
                Row row = sheet.createRow(r++);
                row.createCell(0).setCellValue((String) p.get("label"));
                setMoneyCell(row, 1, ((BigDecimal) p.get("cashIn")).doubleValue(), moneyStyle);
                setMoneyCell(row, 2, ((BigDecimal) p.get("cashInOnline")).doubleValue(), moneyStyle);
                setMoneyCell(row, 3, ((BigDecimal) p.get("cashInPos")).doubleValue(), moneyStyle);
                row.createCell(4).setCellValue(((Number) p.get("orderCount")).intValue());
                setMoneyCell(row, 5, ((BigDecimal) p.get("cashOut")).doubleValue(), moneyStyle);
                row.createCell(6).setCellValue(((Number) p.get("movementCount")).intValue());
                setMoneyCell(row, 7, ((BigDecimal) p.get("net")).doubleValue(), moneyStyle);
                setMoneyCell(row, 8, ((BigDecimal) p.get("cumulativeNet")).doubleValue(), moneyStyle);
            }

            Row totalRow = sheet.createRow(r + 1);
            totalRow.createCell(0).setCellValue("TỔNG");
            setMoneyCell(totalRow, 1, ((BigDecimal) report.get("totalCashIn")).doubleValue(), moneyStyle);
            setMoneyCell(totalRow, 5, ((BigDecimal) report.get("totalCashOut")).doubleValue(), moneyStyle);
            setMoneyCell(totalRow, 7, ((BigDecimal) report.get("netCashFlow")).doubleValue(), moneyStyle);

            for (int i = 0; i < headers.length; i++) sheet.setColumnWidth(i, 4200);

            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            wb.write(bos);
            return bos.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Không xuất được file Excel: " + e.getMessage());
        }
    }

    private void setMoneyCell(Row row, int col, double value, org.apache.poi.ss.usermodel.CellStyle style) {
        var cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    // ===== helpers =====

    /** Tổng tiền vào/tiền ra của 1 khoảng ngày, không tách theo mốc — dùng để so sánh kỳ trước. */
    private BigDecimal[] sumRange(LocalDate fromDate, LocalDate toDate) {
        LocalDateTime fromDt = fromDate.atStartOfDay();
        LocalDateTime toDt = toDate.plusDays(1).atStartOfDay();
        Object inSum = em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] WHERE status='delivered' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", fromDt).setParameter("to", toDt).getSingleResult();
        Object outSum = em.createNativeQuery(
                "SELECT ISNULL(SUM(change_qty*unit_cost),0) FROM STOCK_MOVEMENT WHERE reason='nhap_hang' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", fromDt).setParameter("to", toDt).getSingleResult();
        return new BigDecimal[]{(BigDecimal) inSum, (BigDecimal) outSum};
    }

    /** null khi kỳ trước = 0 (không có gì để so sánh) — frontend hiển thị "—" thay vì % vô nghĩa. */
    private BigDecimal pctChange(BigDecimal current, BigDecimal prev) {
        if (prev == null || prev.signum() == 0) return null;
        return current.subtract(prev).divide(prev, 4, RoundingMode.HALF_UP).multiply(BigDecimal.valueOf(100));
    }

    private String periodExpr(String groupBy) {
        return switch (groupBy) {
            case "month" -> "DATEFROMPARTS(YEAR(created_at), MONTH(created_at), 1)";
            case "year" -> "DATEFROMPARTS(YEAR(created_at), 1, 1)";
            default -> "CAST(created_at AS DATE)";
        };
    }

    private List<LocalDate> buildPeriods(LocalDate fromDate, LocalDate toDate, String groupBy) {
        List<LocalDate> periods = new ArrayList<>();
        if ("month".equals(groupBy)) {
            LocalDate cursor = fromDate.withDayOfMonth(1);
            LocalDate end = toDate.withDayOfMonth(1);
            while (!cursor.isAfter(end)) { periods.add(cursor); cursor = cursor.plusMonths(1); }
        } else if ("year".equals(groupBy)) {
            LocalDate cursor = fromDate.withDayOfYear(1);
            LocalDate end = toDate.withDayOfYear(1);
            while (!cursor.isAfter(end)) { periods.add(cursor); cursor = cursor.plusYears(1); }
        } else {
            LocalDate cursor = fromDate;
            while (!cursor.isAfter(toDate)) { periods.add(cursor); cursor = cursor.plusDays(1); }
        }
        return periods;
    }

    private DateTimeFormatter labelFormatter(String groupBy) {
        return switch (groupBy) {
            case "month" -> DateTimeFormatter.ofPattern("MM/yyyy");
            case "year" -> DateTimeFormatter.ofPattern("yyyy");
            default -> DateTimeFormatter.ofPattern("dd/MM/yyyy");
        };
    }

    private LocalDate toLocalDate(Object o) {
        if (o instanceof java.sql.Date d) return d.toLocalDate();
        if (o instanceof java.sql.Timestamp t) return t.toLocalDateTime().toLocalDate();
        if (o instanceof LocalDate ld) return ld;
        if (o instanceof LocalDateTime ldt) return ldt.toLocalDate();
        throw new IllegalStateException("Kiểu ngày không nhận diện được: " + (o == null ? "null" : o.getClass()));
    }
}
