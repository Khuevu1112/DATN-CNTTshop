package com.fpoly.model;

import jakarta.persistence.*;

/** 1 dòng = 1 quyền (perm_key) mà 1 phòng ban (department) được cấp trên 1 trang (feature_key).
 * "Không có quyền" = không có dòng nào, không phải 1 dòng với perm_key='none'. */
@Entity
@Table(name = "ROLE_PERMISSION")
public class RolePermission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String department;

    @Column(name = "feature_key")
    private String featureKey;

    @Column(name = "perm_key")
    private String permKey;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getFeatureKey() { return featureKey; }
    public void setFeatureKey(String featureKey) { this.featureKey = featureKey; }

    public String getPermKey() { return permKey; }
    public void setPermKey(String permKey) { this.permKey = permKey; }
}
