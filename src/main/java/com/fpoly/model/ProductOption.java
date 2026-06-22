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

    @OneToMany(mappedBy = "option")
    private List<OptionValue> values;

    public Integer getId() { return id; }
    public Product getProduct() { return product; }
    public String getOptionName() { return optionName; }
    public List<OptionValue> getValues() { return values; }
}
