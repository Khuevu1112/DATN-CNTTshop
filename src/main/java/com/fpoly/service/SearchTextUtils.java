package com.fpoly.service;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * Chuẩn hoá chuỗi cho MỌI ô tìm kiếm phía khách (sản phẩm, FAQ, trung tâm bảo hành, chatbot).
 *
 * Ba vấn đề thực tế mà mỗi nơi trước đây tự xoay xở (hoặc không xử lý):
 *   1. Khách gõ KHÔNG DẤU ("man hinh gaming") — phải khớp được "Màn hình Gaming".
 *   2. Khách VIẾT TẮT ("bh", "km", "sp", "lap") — phải giãn ra cụm đầy đủ trước khi so khớp.
 *   3. Khách gõ NHIỀU TỪ RỜI ("laptop asus gaming") — LIKE nguyên cụm gần như luôn trượt vì tên
 *      thật là "Laptop Gaming ASUS TUF..."; phải tách từ và đòi khớp ĐỦ mọi từ, không cần đúng
 *      thứ tự.
 *
 * Bản không dấu ở đây phải khớp hành vi của boDau() bên chatbot (cnttshop-vue) để kết quả tìm
 * trong chat và trên trang danh mục không lệch nhau.
 */
public final class SearchTextUtils {

    private SearchTextUtils() {}

    /** Viết tắt/tiếng lóng -> cụm đầy đủ. Khoá viết dạng KHÔNG DẤU vì chỉ tra sau khi boDau().
     * Chỉ nhận những tắt CHẮC NGHĨA trong ngữ cảnh shop máy tính — tắt đa nghĩa ("hd", "dt")
     * cố tình bỏ ra ngoài vì đoán sai còn hại hơn không đoán. Đồng bộ với VIET_TAT bên
     * cnttshop-vue/src/components/ChatbotDrawer.vue. */
    private static final Map<String, String> VIET_TAT = Map.ofEntries(
            Map.entry("bh", "bao hanh"),
            Map.entry("km", "khuyen mai"),
            Map.entry("sp", "san pham"),
            Map.entry("dh", "don hang"),
            Map.entry("tk", "tai khoan"),
            Map.entry("mk", "mat khau"),
            Map.entry("tt", "thanh toan"),
            Map.entry("ck", "chuyen khoan"),
            Map.entry("gh", "giao hang"),
            Map.entry("vc", "van chuyen"),
            Map.entry("hv", "hoi vien"),
            Map.entry("cskh", "cham soc khach hang"),
            Map.entry("sdt", "so dien thoai"),
            Map.entry("lap", "laptop"),
            Map.entry("lt", "laptop"),
            Map.entry("mh", "man hinh"),
            Map.entry("mhinh", "man hinh"),
            Map.entry("bp", "ban phim"),
            Map.entry("pk", "phu kien"),
            Map.entry("lk", "linh kien"),
            Map.entry("vga", "card man hinh"),
            Map.entry("main", "mainboard"),
            Map.entry("ocung", "o cung"),
            Map.entry("ko", "khong"),
            Map.entry("bn", "bao nhieu"));

    /** Từ đệm bị loại khỏi phép so khớp — giữ lại chúng thì câu nào cũng "khớp" một phần. */
    private static final Set<String> TU_DEM = Set.of(
            "va", "voi", "cho", "cua", "la", "nen", "cai", "nao", "hay", "minh", "ban", "toi",
            "shop", "oi", "nhe", "a", "the", "nhu", "gi", "vay", "duoc", "khong", "co", "thi",
            "lam", "sao", "dau", "nay", "do", "ve", "neu", "hoac", "da", "roi", "chua", "con",
            "lai", "ra", "vao", "len", "xuong", "mua", "gia", "tim", "can", "muon");

    /** Bỏ dấu tiếng Việt + hạ chữ thường. */
    public static String boDau(String s) {
        if (s == null) return "";
        String n = Normalizer.normalize(s, Normalizer.Form.NFD)
                .replaceAll("\\p{InCombiningDiacriticalMarks}+", "")
                .replace('đ', 'd').replace('Đ', 'D');
        return n.toLowerCase(Locale.ROOT).trim();
    }

    /** Bỏ dấu + giãn viết tắt theo TỪ (không thay chuỗi con, "km" trong "10km" giữ nguyên). */
    public static String chuanHoa(String s) {
        String[] tu = boDau(s).replaceAll("[?!.,;:()\"']", " ").split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (String t : tu) {
            if (t.isEmpty()) continue;
            if (sb.length() > 0) sb.append(' ');
            sb.append(VIET_TAT.getOrDefault(t, t));
        }
        return sb.toString();
    }

    /** Tách câu tìm kiếm thành các từ có nghĩa (đã chuẩn hoá, đã loại từ đệm, bỏ trùng). */
    public static List<String> tachTu(String s) {
        Set<String> ra = new LinkedHashSet<>();
        for (String t : chuanHoa(s).split("\\s+")) {
            if (t.isEmpty() || TU_DEM.contains(t)) continue;
            ra.add(t);
        }
        // Câu chỉ toàn từ đệm (vd "cho mình hỏi") -> giữ nguyên từ gốc còn hơn trả về rỗng,
        // vì rỗng nghĩa là "không lọc gì" và sẽ đổ ra toàn bộ danh sách.
        if (ra.isEmpty()) {
            ra.addAll(Arrays.asList(chuanHoa(s).split("\\s+")));
            ra.remove("");
        }
        return new ArrayList<>(ra);
    }

    /** true nếu MỌI từ trong câu tìm kiếm đều xuất hiện trong noiDung (không cần đúng thứ tự). */
    public static boolean khopMoiTu(String noiDung, List<String> tuKhoa) {
        if (tuKhoa.isEmpty()) return true;
        String nd = chuanHoa(noiDung);
        for (String t : tuKhoa) {
            if (!nd.contains(t)) return false;
        }
        return true;
    }

    /** Số từ khoá xuất hiện trong noiDung — dùng để xếp hạng độ liên quan. */
    public static int demTuKhop(String noiDung, List<String> tuKhoa) {
        String nd = chuanHoa(noiDung);
        int n = 0;
        for (String t : tuKhoa) {
            if (nd.contains(t)) n++;
        }
        return n;
    }
}
