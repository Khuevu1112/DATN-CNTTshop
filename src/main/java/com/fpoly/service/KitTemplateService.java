package com.fpoly.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.KitTemplateDtos.KitTemplateDetailDto;
import com.fpoly.dto.KitTemplateDtos.KitTemplateItemDto;
import com.fpoly.dto.KitTemplateDtos.KitTemplateSummaryDto;
import com.fpoly.dto.KitTemplateDtos.SaveKitTemplateItemRequest;
import com.fpoly.dto.KitTemplateDtos.SaveKitTemplateRequest;
import com.fpoly.dto.KitTemplateDtos.VariantSearchResultDto;
import com.fpoly.model.KitTemplate;
import com.fpoly.model.KitTemplateItem;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.KitTemplateRepository;
import com.fpoly.repository.ProductVariantRepository;

@Service
public class KitTemplateService {

    @Autowired private KitTemplateRepository kitTemplateRepo;
    @Autowired private ProductVariantRepository variantRepo;

    public List<KitTemplateSummaryDto> layDanhSach() {
        return kitTemplateRepo.findAllByOrderByIdDesc().stream().map(this::toSummary).toList();
    }

    /** Ánh xạ componentType (khoá trong TYPES ở KitTemplates.vue) -> slug danh mục thật, để tìm
     * "trong kho" chỉ đề xuất đúng loại linh kiện (vd CPU chỉ ra CPU, không lẫn RAM/Mainboard...). */
    private static final Map<String, String> LOAI_LINH_KIEN_SANG_SLUG = Map.ofEntries(
            Map.entry("CPU", "cpu"),
            Map.entry("Mainboard", "mainboard"),
            Map.entry("RAM", "ram"),
            Map.entry("GPU", "gpu"),
            Map.entry("SSD", "ssd"),
            Map.entry("HDD", "hdd"),
            Map.entry("PSU", "psu"),
            Map.entry("Case", "case-may-tinh"),
            Map.entry("Cooler", "tan-nhiet-cpu"),
            Map.entry("Monitor", "man-hinh"),
            Map.entry("Mouse", "ngoai-vi"),
            Map.entry("Keyboard", "ngoai-vi"));

    /** Tìm sản phẩm/variant theo từ khóa — dùng cho ô chọn "trong kho" khi thêm linh kiện vào mẫu.
     * componentType (nếu có khớp trong bảng ánh xạ) sẽ giới hạn kết quả về đúng danh mục đó. */
    public List<VariantSearchResultDto> timSanPham(String keyword, String componentType) {
        if (keyword == null || keyword.isBlank()) return List.of();
        String categorySlug = LOAI_LINH_KIEN_SANG_SLUG.get(componentType);
        return variantRepo.search(keyword.trim(), categorySlug, PageRequest.of(0, 20)).stream()
                .map(v -> new VariantSearchResultDto(v.getId(), v.getProduct().getName(), v.getSku(), v.getPrice()))
                .toList();
    }

    public KitTemplateDetailDto layChiTiet(Integer id) {
        return toDetail(layEntity(id));
    }

    @Transactional
    public KitTemplateDetailDto tao(SaveKitTemplateRequest req) {
        KitTemplate kt = new KitTemplate();
        apply(kt, req);
        return toDetail(kitTemplateRepo.save(kt));
    }

    @Transactional
    public KitTemplateDetailDto capNhat(Integer id, SaveKitTemplateRequest req) {
        KitTemplate kt = layEntity(id);
        kt.getItems().clear();
        apply(kt, req);
        return toDetail(kitTemplateRepo.save(kt));
    }

    @Transactional
    public void xoa(Integer id) {
        kitTemplateRepo.delete(layEntity(id));
    }

    private void apply(KitTemplate kt, SaveKitTemplateRequest req) {
        if (req.name() == null || req.name().isBlank()) {
            throw new RuntimeException("Tên mẫu cấu hình không được để trống");
        }
        kt.setTen(req.name());
        kt.setMoTa(req.description());

        List<KitTemplateItem> items = new ArrayList<>();
        if (req.items() != null) {
            int order = 0;
            for (SaveKitTemplateItemRequest itemReq : req.items()) {
                items.add(toEntity(kt, itemReq, order++));
            }
        }
        if (kt.getItems() == null) {
            kt.setItems(items);
        } else {
            kt.getItems().addAll(items);
        }
    }

    private KitTemplateItem toEntity(KitTemplate kt, SaveKitTemplateItemRequest req, int defaultOrder) {
        if (req.componentType() == null || req.componentType().isBlank()) {
            throw new RuntimeException("Loại linh kiện không được để trống");
        }
        String nguon = req.source() == null ? KitTemplateItem.NGUON_TRONG_KHO : req.source();
        if (!KitTemplateItem.NGUON_TRONG_KHO.equals(nguon) && !KitTemplateItem.NGUON_NGOAI_KHO.equals(nguon)) {
            throw new RuntimeException("Nguồn gốc linh kiện không hợp lệ");
        }

        KitTemplateItem item = new KitTemplateItem();
        item.setKitTemplate(kt);
        item.setLoaiLinhKien(req.componentType());
        item.setNguonGoc(nguon);
        item.setGiaCongThem(req.extraPrice());
        item.setThuTu(req.sortOrder() != null ? req.sortOrder() : defaultOrder);

        if (KitTemplateItem.NGUON_TRONG_KHO.equals(nguon)) {
            if (req.variantId() == null) {
                throw new RuntimeException("Linh kiện \"" + req.componentType() + "\" lấy từ kho phải chọn 1 sản phẩm có sẵn");
            }
            ProductVariant variant = variantRepo.findById(req.variantId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm/biến thể đã chọn"));
            item.setProductVariant(variant);
        } else {
            if (req.manualName() == null || req.manualName().isBlank()) {
                throw new RuntimeException("Linh kiện \"" + req.componentType() + "\" ngoài kho phải nhập tên");
            }
            item.setTenTuNhap(req.manualName());
        }
        return item;
    }

    private KitTemplate layEntity(Integer id) {
        return kitTemplateRepo.findByIdWithItems(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mẫu cấu hình #" + id));
    }

    private KitTemplateSummaryDto toSummary(KitTemplate kt) {
        List<KitTemplateItem> items = kt.getItems();
        int count = items == null ? 0 : items.size();
        BigDecimal total = tongGia(items);
        List<String> types = items == null ? List.of() : items.stream().map(KitTemplateItem::getLoaiLinhKien).toList();
        return new KitTemplateSummaryDto(kt.getId(), kt.getTen(), kt.getMoTa(), kt.getCreatedAt(), count, total, types);
    }

    private KitTemplateDetailDto toDetail(KitTemplate kt) {
        List<KitTemplateItemDto> itemDtos = kt.getItems() == null ? List.of() : kt.getItems().stream()
                .map(this::toItemDto).toList();
        return new KitTemplateDetailDto(kt.getId(), kt.getTen(), kt.getMoTa(), kt.getCreatedAt(),
                itemDtos, tongGia(kt.getItems()));
    }

    private KitTemplateItemDto toItemDto(KitTemplateItem item) {
        ProductVariant v = item.getProductVariant();
        return new KitTemplateItemDto(
                item.getId(), item.getLoaiLinhKien(), item.getNguonGoc(),
                v != null ? v.getId() : null,
                v != null ? v.getProduct().getName() : null,
                v != null ? v.getSku() : null,
                item.getTenTuNhap(), item.getTenHienThi(), item.getGiaThucTe(), item.getThuTu());
    }

    private BigDecimal tongGia(List<KitTemplateItem> items) {
        if (items == null) return BigDecimal.ZERO;
        return items.stream().map(KitTemplateItem::getGiaThucTe).reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
