package com.fpoly.model;

import java.util.List;

import jakarta.persistence.*;

@Entity
@Table(name = "PRODUCT_OPTION")
public class ProductOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(name = "option_name")
    private String optionName;

    /** "single" (chọn 1) hoặc "multiple" (chọn nhiều). */
    @Column(name = "selection_type")
    private String selectionType = "single";

    @Column(name = "min_select")
    private Integer minSelect = 0;

    @Column(name = "max_select")
    private Integer maxSelect = 1;

    private String description;

    @Column(name = "is_required")
    private Boolean required = false;

    @Column(name = "is_visible")
    private Boolean visible = true;

    @Column(name = "sort_order")
    private Integer sortOrder = 0;

    /** NULL = tự do phối tổ hợp; cùng giá trị với 1 nhóm khác trên cùng sản phẩm = 2 nhóm bị
     * khoá cặp, chỉ những tổ hợp admin nhập tay mới hợp lệ giữa 2 nhóm đó. */
    @Column(name = "linked_group")
    private String linkedGroup;

    @OneToMany(mappedBy = "option")
    private List<OptionValue> values;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public String getOptionName() { return optionName; }
    public void setOptionName(String optionName) { this.optionName = optionName; }

    public String getSelectionType() { return selectionType; }
    public void setSelectionType(String selectionType) { this.selectionType = selectionType; }

    public Integer getMinSelect() { return minSelect; }
    public void setMinSelect(Integer minSelect) { this.minSelect = minSelect; }

    public Integer getMaxSelect() { return maxSelect; }
    public void setMaxSelect(Integer maxSelect) { this.maxSelect = maxSelect; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Boolean getRequired() { return required; }
    public void setRequired(Boolean required) { this.required = required; }

    public Boolean getVisible() { return visible; }
    public void setVisible(Boolean visible) { this.visible = visible; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public String getLinkedGroup() { return linkedGroup; }
    public void setLinkedGroup(String linkedGroup) { this.linkedGroup = linkedGroup; }

    public List<OptionValue> getValues() { return values; }
    public void setValues(List<OptionValue> values) { this.values = values; }
}
