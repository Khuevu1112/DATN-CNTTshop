package com.fpoly.model;

import jakarta.persistence.*;

@Entity
@Table(name = "PROVINCE")
public class Province {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", nullable = false, unique = true)
    private String code;

    @Column(name = "name", nullable = false)
    private String name;

    // bac, trung, nam — dùng để tra "liên tỉnh cùng miền" vs "liên miền" khi tính phí đơn vị
    // vận chuyển ngoài Hải Phòng (xem CarrierService).
    @Column(name = "region", nullable = false)
    private String region;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRegion() { return region; }
    public void setRegion(String region) { this.region = region; }
}
