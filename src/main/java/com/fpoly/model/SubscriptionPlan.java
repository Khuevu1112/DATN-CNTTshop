package com.fpoly.model;

import java.math.BigDecimal;

import jakarta.persistence.*;

/** Cấu hình 1 gói hội viên trả phí "CNTT Care" (xem database/61_membership_subscription.sql).
 * KHÁC hoàn toàn MembershipTier: đây là dịch vụ BÁN, có trần chi phí, không đụng tới xu/hạng
 * tích luỹ. Để DB (không hardcode enum như MembershipTier) vì giá + hạn mức là thứ marketing
 * chỉnh theo mùa; bù lại bất biến "giá > chi phí quyền lợi tối đa/năm" được canh bằng
 * SubscriptionEconomyTest trên đúng bộ số seed. */
@Entity
@Table(name = "SUBSCRIPTION_PLAN")
public class SubscriptionPlan {

    // Giá vốn tham chiếu của shop cho từng quyền lợi có hạn mức — đây là các con số dùng để
    // chứng minh gói có lãi kể cả khi khách xài kịch hạn mức (xem chiPhiToiDaMotNam +
    // SubscriptionEconomyTest). Ship nội thành KHÔNG nằm ở đây vì là xe của shop, chi phí biên
    // coi như 0 nên cho không giới hạn. Sửa số nào thì test sẽ báo nếu làm gói lỗ.
    public static final BigDecimal GIA_VON_SHIP_LIEN_TINH   = new BigDecimal("49000");  // phí hãng vận chuyển đắt nhất shop gánh
    public static final BigDecimal GIA_VON_VE_SINH          = new BigDecimal("45000");  // 1 lần vệ sinh (không tra keo)
    public static final BigDecimal GIA_VON_VE_SINH_TRA_KEO  = new BigDecimal("60000");  // 1 lần vệ sinh có tra keo tản nhiệt
    public static final BigDecimal GIA_VON_TAN_NOI          = new BigDecimal("40000");  // 1 lượt bảo hành tận nơi (đi lại)
    public static final BigDecimal GIA_VON_MAY_MUON         = new BigDecimal("100000"); // 1 lượt cho mượn máy (khấu hao/rủi ro)

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", nullable = false, unique = true)
    private String code;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "price", nullable = false)
    private BigDecimal price;

    @Column(name = "duration_months", nullable = false)
    private Integer durationMonths = 12;

    @Column(name = "sort_order", nullable = false)
    private Integer sortOrder = 0;

    @Column(name = "free_inner_shipping", nullable = false)
    private Boolean freeInnerShipping = false;

    @Column(name = "free_express_inner", nullable = false)
    private Boolean freeExpressInner = false;

    @Column(name = "interprovince_quota", nullable = false)
    private Integer interprovinceQuota = 0;

    @Column(name = "warranty_priority", nullable = false)
    private Boolean warrantyPriority = false;

    @Column(name = "cleaning_quota", nullable = false)
    private Integer cleaningQuota = 0;

    @Column(name = "thermal_paste", nullable = false)
    private Boolean thermalPaste = false;

    @Column(name = "onsite_warranty_quota", nullable = false)
    private Integer onsiteWarrantyQuota = 0;

    @Column(name = "loaner_quota", nullable = false)
    private Integer loanerQuota = 0;

    @Column(name = "flash_sale_early", nullable = false)
    private Boolean flashSaleEarly = false;

    @Column(name = "pc_build_consult", nullable = false)
    private Boolean pcBuildConsult = false;

    @Column(name = "activation_voucher_amount")
    private BigDecimal activationVoucherAmount;

    @Column(name = "activation_voucher_min")
    private BigDecimal activationVoucherMin;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    /** Chi phí quyền lợi tối đa shop phải gánh trong 1 năm nếu khách xài KỊCH mọi hạn mức. Đây
     * là mẫu số của bài toán lãi/lỗ: giá gói PHẢI lớn hơn con số này. Không tính ship nội thành
     * (chi phí biên ~0) và các quyền lợi dạng cờ (ưu tiên bảo hành, flash sale sớm, tư vấn). */
    public BigDecimal chiPhiToiDaMotNam() {
        BigDecimal giaVonVeSinh = Boolean.TRUE.equals(thermalPaste) ? GIA_VON_VE_SINH_TRA_KEO : GIA_VON_VE_SINH;
        BigDecimal tong = BigDecimal.ZERO;
        tong = tong.add(GIA_VON_SHIP_LIEN_TINH.multiply(BigDecimal.valueOf(interprovinceQuota)));
        tong = tong.add(giaVonVeSinh.multiply(BigDecimal.valueOf(cleaningQuota)));
        tong = tong.add(GIA_VON_TAN_NOI.multiply(BigDecimal.valueOf(onsiteWarrantyQuota)));
        tong = tong.add(GIA_VON_MAY_MUON.multiply(BigDecimal.valueOf(loanerQuota)));
        if (activationVoucherAmount != null) {
            tong = tong.add(activationVoucherAmount);
        }
        return tong;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public Integer getDurationMonths() { return durationMonths; }
    public void setDurationMonths(Integer durationMonths) { this.durationMonths = durationMonths; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public Boolean getFreeInnerShipping() { return freeInnerShipping; }
    public void setFreeInnerShipping(Boolean freeInnerShipping) { this.freeInnerShipping = freeInnerShipping; }

    public Boolean getFreeExpressInner() { return freeExpressInner; }
    public void setFreeExpressInner(Boolean freeExpressInner) { this.freeExpressInner = freeExpressInner; }

    public Integer getInterprovinceQuota() { return interprovinceQuota; }
    public void setInterprovinceQuota(Integer interprovinceQuota) { this.interprovinceQuota = interprovinceQuota; }

    public Boolean getWarrantyPriority() { return warrantyPriority; }
    public void setWarrantyPriority(Boolean warrantyPriority) { this.warrantyPriority = warrantyPriority; }

    public Integer getCleaningQuota() { return cleaningQuota; }
    public void setCleaningQuota(Integer cleaningQuota) { this.cleaningQuota = cleaningQuota; }

    public Boolean getThermalPaste() { return thermalPaste; }
    public void setThermalPaste(Boolean thermalPaste) { this.thermalPaste = thermalPaste; }

    public Integer getOnsiteWarrantyQuota() { return onsiteWarrantyQuota; }
    public void setOnsiteWarrantyQuota(Integer onsiteWarrantyQuota) { this.onsiteWarrantyQuota = onsiteWarrantyQuota; }

    public Integer getLoanerQuota() { return loanerQuota; }
    public void setLoanerQuota(Integer loanerQuota) { this.loanerQuota = loanerQuota; }

    public Boolean getFlashSaleEarly() { return flashSaleEarly; }
    public void setFlashSaleEarly(Boolean flashSaleEarly) { this.flashSaleEarly = flashSaleEarly; }

    public Boolean getPcBuildConsult() { return pcBuildConsult; }
    public void setPcBuildConsult(Boolean pcBuildConsult) { this.pcBuildConsult = pcBuildConsult; }

    public BigDecimal getActivationVoucherAmount() { return activationVoucherAmount; }
    public void setActivationVoucherAmount(BigDecimal activationVoucherAmount) { this.activationVoucherAmount = activationVoucherAmount; }

    public BigDecimal getActivationVoucherMin() { return activationVoucherMin; }
    public void setActivationVoucherMin(BigDecimal activationVoucherMin) { this.activationVoucherMin = activationVoucherMin; }

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
}
