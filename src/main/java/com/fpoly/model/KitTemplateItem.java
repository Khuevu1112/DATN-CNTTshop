package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

/**
 * 1 linh kiện/thành phần trong mẫu cấu hình. Nguồn gốc "stock" = lấy từ sản phẩm/variant
 * có sẵn trong catalog (tên + giá lấy từ đó); "external" = ngoài kho, nhập tay tên + giá
 * (tạm thời, chờ nối với trang Quản lý nhập hàng sau này).
 */
@Entity
@Table(name = "KIT_TEMPLATE_ITEM")
public class KitTemplateItem {

    public static final String NGUON_TRONG_KHO = "stock";
    public static final String NGUON_NGOAI_KHO = "external";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "kit_template_id", nullable = false)
    private KitTemplate kitTemplate;

    @Column(name = "component_type", nullable = false)
    private String loaiLinhKien;

    @Column(name = "source", nullable = false)
    private String nguonGoc = NGUON_TRONG_KHO;

    @ManyToOne
    @JoinColumn(name = "variant_id")
    private ProductVariant productVariant;

    @Column(name = "manual_name")
    private String tenTuNhap;

    @Column(name = "extra_price")
    private BigDecimal giaCongThem;

    @Column(name = "sort_order", nullable = false)
    private Integer thuTu = 0;

    /** Tên hiển thị thật sự dùng khi áp vào sản phẩm: ưu tiên tên sản phẩm trong kho, không có thì dùng tên nhập tay. */
    public String getTenHienThi() {
        if (NGUON_TRONG_KHO.equals(nguonGoc) && productVariant != null) {
            return productVariant.getProduct().getName();
        }
        return tenTuNhap;
    }

    /** Giá thật sự dùng: ưu tiên giá cộng thêm nhập tay, không có thì lấy giá variant (nếu trong kho). */
    public BigDecimal getGiaThucTe() {
        if (giaCongThem != null) return giaCongThem;
        if (NGUON_TRONG_KHO.equals(nguonGoc) && productVariant != null) {
            return productVariant.getPrice();
        }
        return BigDecimal.ZERO;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public KitTemplate getKitTemplate() { return kitTemplate; }
    public void setKitTemplate(KitTemplate kitTemplate) { this.kitTemplate = kitTemplate; }

    public String getLoaiLinhKien() { return loaiLinhKien; }
    public void setLoaiLinhKien(String loaiLinhKien) { this.loaiLinhKien = loaiLinhKien; }

    public String getNguonGoc() { return nguonGoc; }
    public void setNguonGoc(String nguonGoc) { this.nguonGoc = nguonGoc; }

    public ProductVariant getProductVariant() { return productVariant; }
    public void setProductVariant(ProductVariant productVariant) { this.productVariant = productVariant; }

    public String getTenTuNhap() { return tenTuNhap; }
    public void setTenTuNhap(String tenTuNhap) { this.tenTuNhap = tenTuNhap; }

    public BigDecimal getGiaCongThem() { return giaCongThem; }
    public void setGiaCongThem(BigDecimal giaCongThem) { this.giaCongThem = giaCongThem; }

    public Integer getThuTu() { return thuTu; }
    public void setThuTu(Integer thuTu) { this.thuTu = thuTu; }
}
