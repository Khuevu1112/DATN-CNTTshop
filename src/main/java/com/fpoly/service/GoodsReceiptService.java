package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.GoodsReceiptDtos.DongNhapDto;
import com.fpoly.dto.GoodsReceiptDtos.DongNhapRequest;
import com.fpoly.dto.GoodsReceiptDtos.LuuPhieuNhapRequest;
import com.fpoly.dto.GoodsReceiptDtos.LuuSupplierRequest;
import com.fpoly.dto.GoodsReceiptDtos.PhieuNhapDto;
import com.fpoly.dto.GoodsReceiptDtos.SupplierDto;
import com.fpoly.model.GoodsReceipt;
import com.fpoly.model.GoodsReceiptItem;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.StockMovement;
import com.fpoly.model.Supplier;
import com.fpoly.repository.GoodsReceiptItemRepository;
import com.fpoly.repository.GoodsReceiptRepository;
import com.fpoly.repository.ProductVariantRepository;
import com.fpoly.repository.StockMovementRepository;
import com.fpoly.repository.SupplierRepository;

/**
 * NHẬP KHO theo chứng từ: một phiếu = một lần nhận hàng từ một nhà cung cấp, gồm nhiều dòng hàng.
 *
 * Thay cho cách cũ (mỗi lần nhập là một dòng STOCK_MOVEMENT rời rạc, không nhà cung cấp, không
 * số hoá đơn, không tổng tiền, không in được gì). Nay:
 *   - Lập phiếu -> cộng kho từng dòng + ghi sổ STOCK_MOVEMENT có trỏ ngược về phiếu.
 *   - Tiền hàng/VAT/tổng được CHỐT vào phiếu, không tính lại lúc hiển thị.
 *   - In được chứng từ để thủ kho + kế toán ký (xem AdminGoodsReceiptController).
 *
 * Sổ STOCK_MOVEMENT vẫn giữ nguyên vai trò cũ nên lịch sử tồn kho của một biến thể liền mạch dù
 * hàng vào bằng phiếu hay bằng điều chỉnh tay (StockMovementService).
 */
@Service
public class GoodsReceiptService {

    private static final DateTimeFormatter MA_NGAY = DateTimeFormatter.ofPattern("yyMMdd");

    @Autowired private GoodsReceiptRepository receiptRepo;
    @Autowired private GoodsReceiptItemRepository itemRepo;
    @Autowired private SupplierRepository supplierRepo;
    @Autowired private ProductVariantRepository variantRepo;
    @Autowired private StockMovementRepository stockMovementRepo;
    @Autowired private TonKhoService tonKhoService;

    // ============================================================
    //  Nhà cung cấp
    // ============================================================

    public List<SupplierDto> danhSachNhaCungCap(boolean chiHienThi) {
        List<Supplier> ds = chiHienThi ? supplierRepo.findByHienThiTrueOrderByTenAsc()
                : supplierRepo.findAllByOrderByTenAsc();
        return ds.stream().map(this::toSupplierDto).toList();
    }

    @Transactional
    public SupplierDto luuNhaCungCap(Integer id, LuuSupplierRequest req) {
        if (req.ten() == null || req.ten().isBlank()) {
            throw new RuntimeException("Tên nhà cung cấp không được để trống");
        }
        Supplier s = id == null ? new Supplier()
                : supplierRepo.findById(id).orElseThrow(() -> new RuntimeException("Không tìm thấy nhà cung cấp"));
        s.setTen(req.ten().trim());
        s.setMaSoThue(rong(req.maSoThue()));
        s.setDienThoai(rong(req.dienThoai()));
        s.setEmail(rong(req.email()));
        s.setDiaChi(rong(req.diaChi()));
        s.setNguoiLienHe(rong(req.nguoiLienHe()));
        s.setGhiChu(rong(req.ghiChu()));
        s.setHienThi(req.hienThi() == null || req.hienThi());
        return toSupplierDto(supplierRepo.save(s));
    }

    private String rong(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }

    private SupplierDto toSupplierDto(Supplier s) {
        return new SupplierDto(s.getId(), s.getTen(), s.getMaSoThue(), s.getDienThoai(),
                s.getEmail(), s.getDiaChi(), s.getNguoiLienHe(), s.getGhiChu(), s.getHienThi());
    }

    // ============================================================
    //  Phiếu nhập kho
    // ============================================================

    /**
     * Lập phiếu nhập và CỘNG KHO ngay.
     *
     * Cộng kho qua TonKhoService (UPDATE có điều kiện) thay vì variant.setStock(): cùng lúc có
     * thể đang có đơn hàng trừ kho chính biến thể đó, đọc-rồi-ghi sẽ nuốt mất một trong hai.
     */
    @Transactional
    public PhieuNhapDto lapPhieu(LuuPhieuNhapRequest req, NguoiDung nguoiLap) {
        if (req.dongHang() == null || req.dongHang().isEmpty()) {
            throw new RuntimeException("Phiếu nhập phải có ít nhất 1 dòng hàng");
        }

        GoodsReceipt phieu = new GoodsReceipt();
        phieu.setMaPhieu(sinhMaPhieu());
        phieu.setNgayNhap(LocalDateTime.now());
        phieu.setNguoiLap(nguoiLap);
        phieu.setSoHoaDon(rong(req.soHoaDon()));
        phieu.setNgayHoaDon(req.ngayHoaDon());
        phieu.setGhiChu(rong(req.ghiChu()));

        BigDecimal vat = req.vatPercent() == null ? BigDecimal.ZERO : req.vatPercent();
        if (vat.signum() < 0 || vat.compareTo(new BigDecimal("100")) > 0) {
            throw new RuntimeException("Thuế suất VAT phải trong khoảng 0–100%");
        }
        phieu.setVatPercent(vat);

        if (req.supplierId() != null) {
            phieu.setSupplier(supplierRepo.findById(req.supplierId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy nhà cung cấp")));
        }

        List<GoodsReceiptItem> chiTiet = new ArrayList<>();
        BigDecimal tienHang = BigDecimal.ZERO;

        for (DongNhapRequest d : req.dongHang()) {
            if (d.variantId() == null) {
                throw new RuntimeException("Có dòng chưa chọn sản phẩm");
            }
            if (d.soLuong() == null || d.soLuong() <= 0) {
                throw new RuntimeException("Số lượng nhập phải lớn hơn 0");
            }
            BigDecimal donGia = d.donGia() == null ? BigDecimal.ZERO : d.donGia();
            if (donGia.signum() < 0) {
                throw new RuntimeException("Đơn giá nhập không được âm");
            }

            ProductVariant v = variantRepo.findById(d.variantId())
                    .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm trong dòng hàng"));

            GoodsReceiptItem item = new GoodsReceiptItem();
            item.setReceipt(phieu);
            item.setVariant(v);
            item.setTenSanPham(v.getProduct() != null ? v.getProduct().getName() : v.getSku());
            item.setSku(v.getSku());
            item.setSoLuong(d.soLuong());
            item.setDonGia(donGia);
            item.setThanhTien(donGia.multiply(BigDecimal.valueOf(d.soLuong())));
            item.setGhiChu(rong(d.ghiChu()));
            chiTiet.add(item);

            tienHang = tienHang.add(item.getThanhTien());
        }

        BigDecimal tienVat = tienHang.multiply(vat).divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        phieu.setTienHang(tienHang);
        phieu.setTienVat(tienVat);
        phieu.setTongTien(tienHang.add(tienVat));
        phieu.setChiTiet(chiTiet);

        GoodsReceipt daLuu = receiptRepo.save(phieu);

        // Cộng kho + ghi sổ SAU khi phiếu đã có id, để dòng sổ trỏ được về phiếu.
        for (GoodsReceiptItem item : daLuu.getChiTiet()) {
            tonKhoService.traHang(item.getVariant(), item.getSoLuong());

            StockMovement sm = new StockMovement();
            sm.setVariant(item.getVariant());
            sm.setChangeQty(item.getSoLuong());
            sm.setReason("nhap_hang");
            sm.setUnitCost(item.getDonGia());
            sm.setNote("Phiếu nhập " + daLuu.getMaPhieu()
                    + (daLuu.getSupplier() != null ? " — " + daLuu.getSupplier().getTen() : ""));
            sm.setCreatedBy(nguoiLap);
            sm.setReceipt(daLuu);
            stockMovementRepo.save(sm);
        }

        return toDto(daLuu, true);
    }

    /**
     * Mã phiếu PNyyMMdd-#### đánh số theo NGÀY (đếm phiếu đã có cùng tiền tố + 1).
     *
     * Vòng lặp nhỏ ở đây là để phòng hai người bấm lập phiếu cùng lúc: cả hai đếm ra cùng một
     * số, người sau sẽ vi phạm UNIQUE trên ma_phieu — thử số kế tiếp thay vì ném lỗi vào mặt họ.
     */
    private String sinhMaPhieu() {
        String tienTo = "PN" + LocalDateTime.now().format(MA_NGAY) + "-";
        long stt = receiptRepo.demTheoTienTo(tienTo) + 1;
        for (int i = 0; i < 50; i++) {
            String ma = tienTo + String.format("%04d", stt + i);
            if (receiptRepo.findByMaPhieu(ma).isEmpty()) return ma;
        }
        throw new RuntimeException("Không sinh được mã phiếu, vui lòng thử lại");
    }

    public List<PhieuNhapDto> danhSachPhieu() {
        return receiptRepo.findAllForAdmin().stream().map(r -> toDto(r, false)).toList();
    }

    public PhieuNhapDto chiTietPhieu(Integer id) {
        return toDto(layPhieu(id), true);
    }

    public GoodsReceipt layPhieu(Integer id) {
        return receiptRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phiếu nhập kho"));
    }

    private PhieuNhapDto toDto(GoodsReceipt r, boolean kemChiTiet) {
        Supplier s = r.getSupplier();
        List<GoodsReceiptItem> items = kemChiTiet
                ? itemRepo.findByReceiptId(r.getId())
                : (r.getChiTiet() == null ? List.of() : r.getChiTiet());

        List<DongNhapDto> dong = !kemChiTiet ? null : items.stream().map(i -> {
            // Tồn ngay sau khi nhập = tồn hiện tại trừ đi mọi biến động phát sinh SAU dòng sổ của
            // phiếu này. Đọc thẳng "tồn hiện tại" sẽ sai với phiếu cũ vì hàng đã bán bớt.
            Integer tonSau = stockMovementRepo.findByVariantId(i.getVariant().getId()).stream()
                    .filter(sm -> sm.getReceipt() != null && sm.getReceipt().getId().equals(r.getId()))
                    .findFirst()
                    .map(sm -> tonSauMoc(i.getVariant(), sm))
                    .orElse(i.getVariant().getStock());
            return new DongNhapDto(i.getId(), i.getVariant().getId(), i.getTenSanPham(), i.getSku(),
                    i.getSoLuong(), i.getDonGia(), i.getThanhTien(), i.getGhiChu(), tonSau);
        }).toList();

        int soDong = items.size();
        int tongSl = items.stream().mapToInt(i -> i.getSoLuong() == null ? 0 : i.getSoLuong()).sum();

        return new PhieuNhapDto(
                r.getId(), r.getMaPhieu(),
                s != null ? s.getId() : null,
                s != null ? s.getTen() : null,
                s != null ? s.getMaSoThue() : null,
                s != null ? s.getDienThoai() : null,
                s != null ? s.getDiaChi() : null,
                r.getSoHoaDon(), r.getNgayHoaDon(), r.getNgayNhap(),
                r.getVatPercent(), r.getTienHang(), r.getTienVat(), r.getTongTien(),
                r.getGhiChu(),
                r.getNguoiLap() != null ? r.getNguoiLap().getHoTen() : null,
                soDong, tongSl, dong);
    }

    /** Tồn của biến thể tại thời điểm ngay sau dòng sổ moc: lấy tồn hiện tại trừ mọi biến động sau đó. */
    private Integer tonSauMoc(ProductVariant v, StockMovement moc) {
        int ton = v.getStock() == null ? 0 : v.getStock();
        for (StockMovement sm : stockMovementRepo.findByVariantId(v.getId())) {
            if (sm.getCreatedAt() != null && moc.getCreatedAt() != null
                    && sm.getCreatedAt().isAfter(moc.getCreatedAt())) {
                ton -= sm.getChangeQty() == null ? 0 : sm.getChangeQty();
            }
        }
        return ton;
    }
}
