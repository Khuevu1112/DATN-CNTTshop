package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "BRAND")
public class Brand {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;

    @Column(name = "logo_url")
    private String logoUrl;

    public Integer getId() { return id; }
    public String getName() { return name; }
    public String getLogoUrl() { return logoUrl; }
}
