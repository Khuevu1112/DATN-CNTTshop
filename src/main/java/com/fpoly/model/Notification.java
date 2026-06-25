package com.fpoly.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

@Entity
@Table(name = "NOTIFICATION")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "type", nullable = false)
    private String loai;

    @Column(name = "title", nullable = false)
    private String tieuDe;

    @Column(name = "message", nullable = false)
    private String noiDung;

    @Column(name = "link")
    private String link;

    @Column(name = "is_read", nullable = false)
    private Boolean daDoc = false;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getLoai() { return loai; }
    public void setLoai(String loai) { this.loai = loai; }

    public String getTieuDe() { return tieuDe; }
    public void setTieuDe(String tieuDe) { this.tieuDe = tieuDe; }

    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public Boolean getDaDoc() { return daDoc; }
    public void setDaDoc(Boolean daDoc) { this.daDoc = daDoc; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
