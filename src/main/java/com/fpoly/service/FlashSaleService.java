package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.FlashSaleDtos.FlashSaleAdminDto;
import com.fpoly.dto.FlashSaleDtos.FlashSaleCongKhaiDto;
import com.fpoly.dto.FlashSaleDtos.FlashSaleItemDto;
import com.fpoly.dto.FlashSaleDtos.LuuFlashSaleItemRequest;
import com.fpoly.dto.FlashSaleDtos.LuuFlashSaleRequest;
import com.fpoly.model.FlashSale;
import com.fpoly.model.FlashSaleItem;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Product;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.FlashSaleRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ProductVariantRepository;

import tools.jackson.databind.ObjectMapper;

/** Flash sale — thuộc nhóm Quản lý khuyến mãi.
 *
 * Hai quy tắc chi phối toàn bộ service này:
 *
 * 1. CHỈ 1 ĐỢT CÒN HIỆU LỰC TẠI MỘT THỜI ĐIỂM. Chưa có đợt nào còn hiệu lực -> admin tạo mới
 *    được; đang có -> chỉ sửa đợt đó, gọi taoMoi() sẽ bị từ chối.
 *
 * 2. SỬA KHÔNG ĐỒNG NGHĨA VỚI ĐĂNG. Admin sửa bao nhiêu tuỳ ý, lưu thẳng vào bản nháp (chính là
 *    các cột của FLASH_SALE), khách hàng vẫn thấy nguyên bản cũ cho tới khi bấm Public. Lúc đó
 *    publish() chụp bản nháp thành JSON đưa vào published_payload. */
@Service
public class FlashSaleService {

    @Autowired private FlashSaleRepository flashSaleRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // ==================== Phía khách hàng ====================

    /** null = không có đợt nào đang chạy -> client tự ẩn banner. Đọc từ ảnh chụp đã public chứ
     * KHÔNG đọc bản nháp, nên admin đang sửa dở không ảnh hưởng gì tới khách. */
    public FlashSaleCongKhaiDto dangChay() {
        Optional<FlashSale> dot = flashSaleRepo.findFirstByIsActiveTrueOrderByIdDesc()
                .filter(FlashSale::dangChay);
        if (dot.isEmpty()) return null;

        try {
            return objectMapper.readValue(dot.get().getNoiDungDaPublic(), FlashSaleCongKhaiDto.class);
        } catch (Exception e) {
            // Ảnh chụp hỏng (đổi cấu trúc DTO sau khi đã public chẳng hạn) -> coi như chưa public,
            // thà không hiện banner còn hơn để trang chủ vỡ.
            return null;
        }
    }

    // ==================== Phía admin ====================

    /** Đợt admin đang làm việc: ưu tiên đợt còn hiệu lực, không có thì đợt gần nhất để admin xem
     * lại/khởi động lại. null = chưa từng tạo đợt nào. */
    public FlashSaleAdminDto dotDangSoan() {
        return dotHienTai().map(this::toAdminDto).orElse(null);
    }

    private Optional<FlashSale> dotHienTai() {
        return flashSaleRepo.findAllByOrderByIdDesc().stream().findFirst();
    }

    /** Đợt "còn hiệu lực" = còn bật và chưa qua thời điểm kết thúc. Đây là điều kiện chặn tạo mới
     * — đợt đã hết hạn hoặc đã tắt thì không tính, admin được tạo đợt kế tiếp. */
    public boolean dangCoDotConHieuLuc() {
        return flashSaleRepo.findFirstByIsActiveTrueOrderByIdDesc()
                .filter(fs -> fs.getKetThucLuc() != null && fs.getKetThucLuc().isAfter(LocalDateTime.now()))
                .isPresent();
    }

    @Transactional
    public FlashSaleAdminDto taoMoi(LuuFlashSaleRequest req, String email) {
        if (dangCoDotConHieuLuc()) {
            throw new RuntimeException(
                    "Đang có một flash sale còn hiệu lực. Không thể tạo đợt mới — hãy sửa đợt đang chạy, "
                    + "hoặc tắt/để nó kết thúc trước.");
        }
        FlashSale fs = new FlashSale();
        apDung(fs, req, email);
        return toAdminDto(flashSaleRepo.save(fs));
    }

    @Transactional
    public FlashSaleAdminDto capNhat(Integer id, LuuFlashSaleRequest req, String email) {
        FlashSale fs = flashSaleRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đợt flash sale"));
        apDung(fs, req, email);
        return toAdminDto(flashSaleRepo.save(fs));
    }

    /** Chụp bản nháp hiện tại thành ảnh JSON để khách bắt đầu nhìn thấy. */
    @Transactional
    public FlashSaleAdminDto publish(Integer id, String email) {
        FlashSale fs = flashSaleRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đợt flash sale"));

        if (fs.getDanhSachSanPham() == null || fs.getDanhSachSanPham().isEmpty()) {
            throw new RuntimeException("Chưa có sản phẩm nào trong đợt sale, không thể đăng");
        }
        if (fs.getKetThucLuc().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Thời gian kết thúc đã qua, vui lòng đặt lại trước khi đăng");
        }

        try {
            fs.setNoiDungDaPublic(objectMapper.writeValueAsString(toCongKhaiDto(fs)));
        } catch (Exception e) {
            throw new RuntimeException("Không đóng gói được nội dung để đăng: " + e.getMessage());
        }
        fs.setPublicLuc(LocalDateTime.now());
        fs.setNguoiSuaCuoi(layUser(email));
        return toAdminDto(flashSaleRepo.save(fs));
    }

    /** Gỡ banner khỏi trang khách nhưng GIỮ nguyên bản nháp để admin bật lại sau. */
    @Transactional
    public FlashSaleAdminDto gongoai(Integer id) {
        FlashSale fs = flashSaleRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đợt flash sale"));
        fs.setIsActive(false);
        return toAdminDto(flashSaleRepo.save(fs));
    }

    private void apDung(FlashSale fs, LuuFlashSaleRequest req, String email) {
        if (req.tieuDe() != null && !req.tieuDe().isBlank()) fs.setTieuDe(req.tieuDe().trim());
        fs.setMoTa(req.moTa());
        if (req.mauBatDau() != null) fs.setMauBatDau(req.mauBatDau());
        if (req.mauKetThuc() != null) fs.setMauKetThuc(req.mauKetThuc());
        if (req.batDauLuc() != null) fs.setBatDauLuc(req.batDauLuc());
        if (req.ketThucLuc() != null) fs.setKetThucLuc(req.ketThucLuc());
        if (req.isActive() != null) fs.setIsActive(req.isActive());
        fs.setNguoiSuaCuoi(layUser(email));

        if (fs.getBatDauLuc() == null || fs.getKetThucLuc() == null) {
            throw new RuntimeException("Vui lòng nhập thời gian bắt đầu và kết thúc");
        }
        if (!fs.getKetThucLuc().isAfter(fs.getBatDauLuc())) {
            throw new RuntimeException("Thời gian kết thúc phải sau thời gian bắt đầu");
        }

        // sanPham null = lần lưu này không đụng tới danh sách (VD chỉ đổi màu/tiêu đề).
        if (req.sanPham() != null) {
            apDungDanhSachSanPham(fs, req.sanPham());
        }
    }

    /** Ghi đè toàn bộ danh sách sản phẩm theo đúng thứ tự client gửi lên. Sửa tại chỗ list gốc
     * (clear + addAll) thay vì gán list mới, vì orphanRemoval của Hibernate cần giữ nguyên
     * tham chiếu collection để biết dòng nào cần xoá. */
    private void apDungDanhSachSanPham(FlashSale fs, List<LuuFlashSaleItemRequest> yeuCau) {
        if (fs.getDanhSachSanPham() == null) {
            fs.setDanhSachSanPham(new ArrayList<>());
        }
        List<FlashSaleItem> hienTai = fs.getDanhSachSanPham();
        hienTai.clear();

        int thuTu = 0;
        for (LuuFlashSaleItemRequest r : yeuCau) {
            ProductVariant v = variantRepo.findById(r.variantId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm id=" + r.variantId()));

            if (r.giaSale() == null || r.giaSale().signum() <= 0) {
                throw new RuntimeException("Giá sale của \"" + v.getProduct().getName() + "\" không hợp lệ");
            }
            if (r.giaSale().compareTo(v.getPrice()) >= 0) {
                throw new RuntimeException("Giá sale của \"" + v.getProduct().getName()
                        + "\" phải thấp hơn giá đang bán (" + v.getPrice().longValue() + "đ)");
            }

            FlashSaleItem item = new FlashSaleItem();
            item.setFlashSale(fs);
            item.setVariant(v);
            item.setGiaSale(r.giaSale());
            item.setThuTu(thuTu++);
            hienTai.add(item);
        }
    }

    private NguoiDung layUser(String email) {
        return email == null ? null : nguoiDungRepo.findByEmail(email).orElse(null);
    }

    /** Tìm biến thể theo tên sản phẩm/SKU để admin thêm vào đợt sale. Giới hạn 20 kết quả — ô
     * tìm kiếm là dropdown gọn, đổ nhiều hơn cũng không ai cuộn hết. */
    public List<FlashSaleItemDto> timBienTheDeThem(String tuKhoa) {
        if (tuKhoa == null || tuKhoa.isBlank()) return List.of();
        String q = tuKhoa.trim().toLowerCase();

        return variantRepo.findAll().stream()
                .filter(v -> v.getProduct() != null && v.getPrice() != null && v.getPrice().signum() > 0)
                .filter(v -> v.getProduct().getName().toLowerCase().contains(q)
                        || (v.getSku() != null && v.getSku().toLowerCase().contains(q)))
                .limit(20)
                .map(v -> {
                    Product p = v.getProduct();
                    String img = (p.getImages() != null && !p.getImages().isEmpty())
                            ? p.getImages().get(0).getUrl() : null;
                    return new FlashSaleItemDto(
                            v.getId(), p.getId(), p.getSlug(), p.getName(), img, v.getSku(),
                            v.getPrice(), BigDecimal.ZERO, 0, v.getStock(), 0);
                })
                .toList();
    }

    // ==================== Chuyển đổi DTO ====================

    private FlashSaleCongKhaiDto toCongKhaiDto(FlashSale fs) {
        return new FlashSaleCongKhaiDto(
                fs.getId(), fs.getTieuDe(), fs.getMoTa(),
                fs.getMauBatDau(), fs.getMauKetThuc(),
                fs.getBatDauLuc(), fs.getKetThucLuc(),
                toItemDtos(fs)
        );
    }

    private FlashSaleAdminDto toAdminDto(FlashSale fs) {
        return new FlashSaleAdminDto(
                fs.getId(), fs.getTieuDe(), fs.getMoTa(),
                fs.getMauBatDau(), fs.getMauKetThuc(),
                fs.getBatDauLuc(), fs.getKetThucLuc(),
                fs.getIsActive(),
                fs.dangChay(), fs.coThayDoiChuaPublic(),
                fs.getPublicLuc(), fs.getUpdatedAt(),
                toItemDtos(fs)
        );
    }

    private List<FlashSaleItemDto> toItemDtos(FlashSale fs) {
        if (fs.getDanhSachSanPham() == null) return List.of();
        return fs.getDanhSachSanPham().stream().map(item -> {
            ProductVariant v = item.getVariant();
            Product p = v.getProduct();
            String img = (p.getImages() != null && !p.getImages().isEmpty())
                    ? p.getImages().get(0).getUrl() : null;

            // % giảm tính từ giá đang bán so với giá sale — chỉ để hiển thị nhãn "-30%".
            int pct = v.getPrice() == null || v.getPrice().signum() <= 0 ? 0
                    : BigDecimal.ONE.subtract(item.getGiaSale().divide(v.getPrice(), 4, RoundingMode.HALF_UP))
                        .multiply(BigDecimal.valueOf(100))
                        .setScale(0, RoundingMode.HALF_UP).intValue();

            return new FlashSaleItemDto(
                    v.getId(), p.getId(), p.getSlug(), p.getName(), img, v.getSku(),
                    v.getPrice(), item.getGiaSale(), pct, v.getStock(), item.getThuTu()
            );
        }).toList();
    }
}
