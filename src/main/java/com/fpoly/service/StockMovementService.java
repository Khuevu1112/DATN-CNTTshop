package com.fpoly.service;

import java.time.format.DateTimeFormatter;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.StockMovementDtos.StockMovementDto;
import com.fpoly.dto.StockMovementDtos.StockMovementRequest;
import com.fpoly.dto.StockMovementDtos.VariantPickResultDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.StockMovement;
import com.fpoly.repository.ProductVariantRepository;
import com.fpoly.repository.StockMovementRepository;

@Service
public class StockMovementService {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    @Autowired private StockMovementRepository stockMovementRepo;
    @Autowired private ProductVariantRepository variantRepo;

    /** Tìm sản phẩm/biến thể theo từ khoá để chọn khi tạo phiếu nhập/điều chỉnh kho. */
    public List<VariantPickResultDto> timBienThe(String keyword) {
        if (keyword == null || keyword.isBlank()) return List.of();
        return variantRepo.search(keyword.trim(), null, PageRequest.of(0, 20)).stream()
                .map(v -> new VariantPickResultDto(v.getId(), v.getProduct().getName(), v.getSku(), v.getStock()))
                .toList();
    }

    @Transactional
    public StockMovementDto taoPhieu(StockMovementRequest req, NguoiDung nguoiThucHien) {
        if (req.variantId() == null) {
            throw new RuntimeException("Vui lòng chọn sản phẩm");
        }
        if (!"nhap_hang".equals(req.reason()) && !"dieu_chinh".equals(req.reason())) {
            throw new RuntimeException("Loại phiếu không hợp lệ");
        }
        if (req.changeQty() == null || req.changeQty() == 0) {
            throw new RuntimeException("Số lượng thay đổi không được bằng 0");
        }
        if ("nhap_hang".equals(req.reason()) && req.changeQty() < 0) {
            throw new RuntimeException("Nhập hàng phải là số lượng dương — dùng \"Điều chỉnh kho\" nếu muốn giảm");
        }

        ProductVariant variant = variantRepo.findById(req.variantId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        int tonHienTai = variant.getStock() == null ? 0 : variant.getStock();
        int tonMoi = tonHienTai + req.changeQty();
        if (tonMoi < 0) {
            throw new RuntimeException("Số lượng kho sau điều chỉnh không được âm (hiện có " + tonHienTai + ")");
        }
        variant.setStock(tonMoi);
        variantRepo.save(variant);

        StockMovement sm = new StockMovement();
        sm.setVariant(variant);
        sm.setChangeQty(req.changeQty());
        sm.setReason(req.reason());
        sm.setUnitCost(req.unitCost());
        sm.setNote(req.note());
        sm.setCreatedBy(nguoiThucHien);
        sm = stockMovementRepo.save(sm);

        return toDto(sm, tonMoi);
    }

    public List<StockMovementDto> lichSuTheoBienThe(Integer variantId) {
        return stockMovementRepo.findByVariantId(variantId).stream()
                .map(sm -> toDto(sm, sm.getVariant().getStock()))
                .toList();
    }

    public List<StockMovementDto> lichSuGanDay(int limit) {
        return stockMovementRepo.findRecent(PageRequest.of(0, limit)).stream()
                .map(sm -> toDto(sm, sm.getVariant().getStock()))
                .toList();
    }

    private StockMovementDto toDto(StockMovement sm, Integer stockAfter) {
        ProductVariant v = sm.getVariant();
        NguoiDung nguoi = sm.getCreatedBy();
        return new StockMovementDto(
                sm.getId(),
                v.getId(),
                v.getProduct().getName(),
                v.getSku(),
                sm.getChangeQty(),
                sm.getReason(),
                sm.getUnitCost(),
                sm.getNote(),
                nguoi != null ? nguoi.getHoTen() : null,
                sm.getCreatedAt() != null ? sm.getCreatedAt().format(FMT) : null,
                stockAfter);
    }
}
