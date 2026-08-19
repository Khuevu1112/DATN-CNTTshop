package com.fpoly.controller.admin;

import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.fpoly.model.GoodsReceipt;
import com.fpoly.service.GoodsReceiptService;

/**
 * XUẤT HOÁ ĐƠN / CHỨNG TỪ cho phiếu nhập kho.
 *
 * Trả về một trang HTML tối giản, đã canh sẵn khổ A4 và tự mở hộp thoại in — admin bấm "In
 * phiếu" ở admin-vue là ra ngay bản để ký, hoặc chọn "Save as PDF" trong hộp thoại in của trình
 * duyệt nếu cần lưu file.
 *
 * Cố ý KHÔNG kéo thêm thư viện sinh PDF: dự án đã có Thymeleaf, và bản in của trình duyệt cho ra
 * đúng khổ giấy mà kế toán cần mà không thêm phụ thuộc nào.
 *
 * Trang này nằm ngoài /api nên đi theo phiên đăng nhập Thymeleaf của khu vực admin
 * (xem SecurityConfig) — mở trực tiếp bằng URL, không cần token.
 */
@Controller
public class AdminGoodsReceiptController {

    @Autowired private GoodsReceiptService goodsReceiptService;

    @GetMapping("/admin/goods-receipts/{id}/in")
    public String inPhieu(@PathVariable Integer id, Model model) {
        GoodsReceipt phieu = goodsReceiptService.layPhieu(id);
        model.addAttribute("phieu", phieu);
        model.addAttribute("tienBangChu", docTien(phieu.getTongTien()));
        return "admin/goods-receipt-print";
    }

    // ============================================================
    //  Đọc số tiền thành chữ
    // ============================================================
    // Chứng từ kế toán Việt Nam bắt buộc có dòng "Số tiền bằng chữ" để chống sửa số sau khi ký.

    private static final String[] CHU_SO = {
            "không", "một", "hai", "ba", "bốn", "năm", "sáu", "bảy", "tám", "chín"
    };

    private String docTien(BigDecimal tien) {
        if (tien == null) return "";
        long n = tien.setScale(0, java.math.RoundingMode.HALF_UP).longValue();
        if (n == 0) return "Không đồng";
        String s = docSo(n, false).trim().replaceAll("\\s+", " ");
        return Character.toUpperCase(s.charAt(0)) + s.substring(1) + " đồng";
    }

    /**
     * Đọc theo từng nhóm 3 chữ số: tỷ / triệu / nghìn / đơn vị.
     *
     * dayDu chỉ false ở NHÓM ĐẦU TIÊN (để không đọc "không trăm" thừa ở đầu câu). Mọi nhóm phía
     * sau luôn đọc đủ, nếu không 1.000.045 sẽ thành "một triệu bốn mươi lăm" — nghe hệt như
     * 1.045.000.
     */
    private String docSo(long n, boolean dayDu) {
        if (n >= 1_000_000_000L) {
            return docSo(n / 1_000_000_000L, dayDu) + " tỷ" + phanConLai(n % 1_000_000_000L);
        }
        if (n >= 1_000_000L) {
            return docSo(n / 1_000_000L, dayDu) + " triệu" + phanConLai(n % 1_000_000L);
        }
        if (n >= 1_000L) {
            return docSo(n / 1_000L, dayDu) + " nghìn" + phanConLai(n % 1_000L);
        }
        return docBaChuSo((int) n, dayDu);
    }

    private String phanConLai(long con) {
        return con == 0 ? "" : " " + docSo(con, true);
    }

    /**
     * Đọc một nhóm tối đa 3 chữ số. dayDu=false cho nhóm đầu tiên (bỏ "không trăm" thừa ở đầu),
     * nhưng các nhóm sau vẫn phải đọc đủ để "1.000.045" ra "một triệu không trăm bốn mươi lăm"
     * chứ không phải "một triệu bốn mươi lăm".
     */
    private String docBaChuSo(int n, boolean dayDu) {
        int tram = n / 100, chuc = (n / 10) % 10, donVi = n % 10;
        StringBuilder sb = new StringBuilder();

        if (tram > 0 || dayDu) sb.append(CHU_SO[tram]).append(" trăm");
        if (chuc == 0) {
            if (donVi > 0 && (tram > 0 || dayDu)) sb.append(" lẻ");
        } else if (chuc == 1) {
            sb.append(" mười");
        } else {
            sb.append(' ').append(CHU_SO[chuc]).append(" mươi");
        }

        if (donVi > 0) {
            if (chuc >= 2 && donVi == 1) sb.append(" mốt");
            else if (chuc >= 1 && donVi == 5) sb.append(" lăm");
            else sb.append(' ').append(CHU_SO[donVi]);
        }
        return sb.toString();
    }
}
