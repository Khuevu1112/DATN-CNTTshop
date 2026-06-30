package com.fpoly.controller.cilent;

import com.fpoly.model.PcBuild;
import com.fpoly.model.PcBuildItem;
import com.fpoly.model.PcBuildItem.LoaiLinhKien;
import com.fpoly.model.Product;
import com.fpoly.service.CartService;
import com.fpoly.service.PcBuildService;
import com.fpoly.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/pc-config")
public class PcBuildController {

    @Autowired private PcBuildService pcBuildService;
    @Autowired private ProductService productService;
    @Autowired private CartService cartService;

    @GetMapping
    public String trangDanhSach(Model model, Principal principal) {
        List<PcBuild> builds = pcBuildService.layDanhSachBuild(principal.getName());
        model.addAttribute("builds", builds);
        model.addAttribute("title", "Cấu hình PC của tôi");
        model.addAttribute("content", "pc-config/list");
        return "layout/Base";
    }

    @PostMapping("/tao-moi")
    public String taoMoi(Principal principal, RedirectAttributes ra) {
        try {
            PcBuild build = pcBuildService.layHoacTaoBuildNhap(principal.getName());
            return "redirect:/pc-config/builder/" + build.getId() + "?loai=CPU";
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể tạo cấu hình: " + e.getMessage());
            return "redirect:/pc-config";
        }
    }

    @GetMapping("/builder/{buildId}")
    public String builder(@PathVariable Integer buildId,
                          @RequestParam(defaultValue = "CPU") String loai,
                          @RequestParam(defaultValue = "") String keyword,
                          @RequestParam(defaultValue = "0") int page,
                          Model model, Principal principal) {
        try {
            PcBuild build = pcBuildService.layBuildTheoId(buildId, principal.getName());
            List<LoaiLinhKien> danhSachLoai = pcBuildService.layDanhSachLoaiLinhKien();
            Page<Product> sanPhamTrang = productService.timSanPhamTheoLoai(loai, keyword, PageRequest.of(page, 8));
            List<String> canhBao = pcBuildService.kiemTraTuongThich(build);

            // Build map loaiLinhKien -> PcBuildItem để dùng trong Thymeleaf
            Map<String, PcBuildItem> itemTheoLoai = new HashMap<>();
            for (PcBuildItem item : build.getItems()) {
                itemTheoLoai.put(item.getLoaiLinhKien(), item);
            }

            model.addAttribute("build", build);
            model.addAttribute("itemTheoLoai", itemTheoLoai);
            model.addAttribute("danhSachLoai", danhSachLoai);
            model.addAttribute("loaiDangChon", loai);
            model.addAttribute("keyword", keyword);
            model.addAttribute("sanPhamTrang", sanPhamTrang);
            model.addAttribute("canhBao", canhBao);
            model.addAttribute("title", "Xây dựng cấu hình PC");
            model.addAttribute("content", "pc-config/builder");
            return "layout/Base";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/pc-config";
        }
    }

    @PostMapping("/builder/{buildId}/them")
    public String themLinhKien(@PathVariable Integer buildId,
                               @RequestParam Integer variantId,
                               @RequestParam String loaiLinhKien,
                               Principal principal,
                               RedirectAttributes ra) {
        try {
            pcBuildService.themLinhKien(buildId, principal.getName(), variantId, loaiLinhKien);
            ra.addFlashAttribute("success", "Đã thêm linh kiện vào cấu hình!");
        } catch (Exception e) {
            e.printStackTrace();
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/pc-config/builder/" + buildId + "?loai=" + loaiLinhKien;
    }

    @PostMapping("/builder/{buildId}/xoa")
    public String xoaLinhKien(@PathVariable Integer buildId,
                               @RequestParam String loaiLinhKien,
                               Principal principal,
                               RedirectAttributes ra) {
        try {
            pcBuildService.xoaLinhKien(buildId, principal.getName(), loaiLinhKien);
            ra.addFlashAttribute("success", "Đã xóa linh kiện!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/pc-config/builder/" + buildId + "?loai=" + loaiLinhKien;
    }

    @PostMapping("/builder/{buildId}/luu")
    public String luuCauHinh(@PathVariable Integer buildId,
                              @RequestParam String tenCauHinh,
                              @RequestParam(required = false) String ghiChu,
                              Principal principal,
                              RedirectAttributes ra) {
        try {
            pcBuildService.luuCauHinh(buildId, principal.getName(), tenCauHinh, ghiChu);
            ra.addFlashAttribute("success", "Đã lưu cấu hình \"" + tenCauHinh + "\"!");
            return "redirect:/pc-config";
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/pc-config/builder/" + buildId;
        }
    }

    @GetMapping("/chi-tiet/{buildId}")
    public String chiTiet(@PathVariable Integer buildId, Model model, Principal principal) {
        try {
            PcBuild build = pcBuildService.layBuildTheoId(buildId, principal.getName());
            List<String> canhBao = pcBuildService.kiemTraTuongThich(build);
            model.addAttribute("build", build);
            model.addAttribute("canhBao", canhBao);
            model.addAttribute("title", build.getTenCauHinh());
            model.addAttribute("content", "pc-config/detail");
            return "layout/Base";
        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/pc-config";
        }
    }

    @PostMapping("/chi-tiet/{buildId}/them-gio")
    public String themVaoGio(@PathVariable Integer buildId,
                             Principal principal,
                             RedirectAttributes ra) {
        try {
            pcBuildService.themToanBoCauHinhVaoGio(buildId, principal.getName(), cartService);
            ra.addFlashAttribute("success", "Đã thêm toàn bộ linh kiện vào giỏ hàng!");
            return "redirect:/cart";
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/pc-config/chi-tiet/" + buildId;
        }
    }

    @PostMapping("/xoa/{buildId}")
    public String xoaBuild(@PathVariable Integer buildId,
                           Principal principal,
                           RedirectAttributes ra) {
        try {
            pcBuildService.xoaBuild(buildId, principal.getName());
            ra.addFlashAttribute("success", "Đã xóa cấu hình!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/pc-config";
    }
}