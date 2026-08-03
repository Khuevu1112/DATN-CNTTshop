package com.fpoly.controller.api;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.ReturnDtos.ReturnDto;
import com.fpoly.service.ReturnRequestService;

/** Đổi trả hàng — phía KHÁCH (yêu cầu đăng nhập). Gửi yêu cầu dùng multipart vì kèm video minh
 * chứng lỗi + video mở hàng + ảnh lỗi. */
@RestController
@RequestMapping("/api/returns")
public class ReturnApiController {

    @Autowired private ReturnRequestService service;

    private static final String DIR = "uploads/return/";

    /** Lưu 1 file vào uploads/return/, trả URL /uploads/return/... ; null nếu không có file. */
    private String luuFile(MultipartFile f) {
        if (f == null || f.isEmpty()) return null;
        try {
            Files.createDirectories(Paths.get(DIR));
            String goc = f.getOriginalFilename();
            if (goc == null || goc.isBlank()) goc = "file";
            String an = goc.replaceAll("\\s+", "_").replaceAll("[^a-zA-Z0-9._-]", "");
            String ten = UUID.randomUUID() + "_" + an;
            Path p = Paths.get(DIR).resolve(ten);
            Files.copy(f.getInputStream(), p, StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/return/" + ten;
        } catch (IOException e) {
            throw new RuntimeException("Lỗi khi lưu tệp minh chứng: " + e.getMessage());
        }
    }

    @PostMapping
    public ReturnDto guiYeuCau(
            @RequestParam(required = false) String maDon,
            @RequestParam(required = false) String kenhMua,
            @RequestParam(required = false) String lyDo,
            @RequestParam String noiDung,
            @RequestParam(value = "videoLoi", required = false) MultipartFile videoLoi,
            @RequestParam(value = "videoMoHang", required = false) MultipartFile videoMoHang,
            @RequestParam(value = "anh", required = false) List<MultipartFile> anh,
            Authentication auth) {
        String urlVideoLoi = luuFile(videoLoi);
        String urlVideoMoHang = luuFile(videoMoHang);
        List<String> urlAnh = new ArrayList<>();
        if (anh != null) {
            for (MultipartFile a : anh) {
                String u = luuFile(a);
                if (u != null) urlAnh.add(u);
                if (urlAnh.size() >= 3) break; // tối đa 3 ảnh lỗi
            }
        }
        return service.taoYeuCau(auth.getName(), maDon, kenhMua, lyDo, noiDung,
                urlVideoLoi, urlVideoMoHang, urlAnh);
    }

    @GetMapping
    public List<ReturnDto> cuaToi(Authentication auth) {
        return service.cuaToi(auth.getName());
    }
}
