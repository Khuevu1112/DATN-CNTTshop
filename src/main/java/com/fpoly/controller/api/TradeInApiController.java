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

import com.fpoly.dto.TradeInDtos.CreditDto;
import com.fpoly.dto.TradeInDtos.TaoYeuCauRequest;
import com.fpoly.dto.TradeInDtos.YeuCauDto;
import com.fpoly.service.TradeInService;

/** Thu cũ đổi mới — phía KHÁCH. Gửi yêu cầu kèm ảnh, theo dõi tiến trình, xem tín dụng đã nhận.
 * Phần định giá của nhân viên nằm ở AdminTradeInApiController. */
@RestController
@RequestMapping("/api/trade-in")
public class TradeInApiController {

    @Autowired private TradeInService tradeInService;

    private static final String THU_MUC_ANH = "uploads/trade-in/";
    private static final long DUNG_LUONG_TOI_DA = 5 * 1024 * 1024; // 5MB mỗi ảnh

    /** Gửi yêu cầu kèm tối đa 4 ảnh. Dùng multipart vì có file — các trường text đi kèm dạng
     * @RequestParam thay vì @RequestBody JSON. */
    @PostMapping
    public YeuCauDto guiYeuCau(
            @RequestParam String model,
            @RequestParam(required = false) String loaiThietBi,
            @RequestParam(required = false) String hang,
            @RequestParam(required = false) String tinhTrangKhai,
            @RequestParam(required = false) Integer namMua,
            @RequestParam(required = false) String moTa,
            @RequestParam(required = false) String serial,
            @RequestParam(value = "anh", required = false) List<MultipartFile> anh,
            Authentication auth) {

        List<String> duongDan = luuAnh(anh);
        TaoYeuCauRequest req = new TaoYeuCauRequest(loaiThietBi, hang, model, tinhTrangKhai, namMua, moTa, serial);
        return tradeInService.taoYeuCau(auth.getName(), req, duongDan);
    }

    @GetMapping
    public List<YeuCauDto> yeuCauCuaToi(Authentication auth) {
        return tradeInService.yeuCauCuaToi(auth.getName());
    }

    /** Khách chấp nhận / từ chối mức giá tạm tính shop báo. */
    @PostMapping("/{id}/phan-hoi")
    public YeuCauDto phanHoi(@PathVariable Integer id, @RequestParam boolean dongY, Authentication auth) {
        return tradeInService.khachPhanHoiBaoGia(id, auth.getName(), dongY);
    }

    /** Tín dụng thu cũ của khách — dùng ở trang cá nhân và ở bước thanh toán. */
    @GetMapping("/credits")
    public List<CreditDto> tinDungCuaToi(Authentication auth) {
        return tradeInService.tinDungCuaToi(auth.getName());
    }

    /** Lưu ảnh hiện trạng máy. Giữ nguyên cách làm của ReviewApiController (ghi vào uploads/ rồi
     * trả đường dẫn tương đối) để phục vụ ảnh dùng chung một cơ chế. */
    private List<String> luuAnh(List<MultipartFile> files) {
        List<String> out = new ArrayList<>();
        if (files == null) return out;
        try {
            Path thuMuc = Paths.get(THU_MUC_ANH);
            Files.createDirectories(thuMuc);
            for (MultipartFile f : files) {
                if (f == null || f.isEmpty()) continue;
                if (out.size() >= 4) break; // bảng chỉ có 4 cột ảnh
                if (f.getSize() > DUNG_LUONG_TOI_DA) {
                    throw new RuntimeException("Ảnh vượt quá 5MB, vui lòng chọn ảnh nhỏ hơn");
                }
                String goc = f.getOriginalFilename() == null ? "anh.jpg" : f.getOriginalFilename();
                String ten = UUID.randomUUID() + "_" + goc.replaceAll("[^a-zA-Z0-9._-]", "");
                Files.copy(f.getInputStream(), thuMuc.resolve(ten), StandardCopyOption.REPLACE_EXISTING);
                out.add("/" + THU_MUC_ANH + ten);
            }
        } catch (IOException e) {
            throw new RuntimeException("Không lưu được ảnh: " + e.getMessage());
        }
        return out;
    }
}
