package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "OPTION_VALUE")
public class OptionValue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "option_id")
    private ProductOption option;

    private String value;

    public Integer getId() { return id; }
    public ProductOption getOption() { return option; }
    public String getValue() { return value; }
}
