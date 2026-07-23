package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.Notification;
import com.fpoly.repository.NotificationRepository;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository repo;

    public void tao(String loai, String tieuDe, String noiDung, String link) {
        Notification n = new Notification();
        n.setLoai(loai);
        n.setTieuDe(tieuDe);
        n.setNoiDung(noiDung);
        n.setLink(link);
        repo.save(n);
    }

    public List<Notification> layGanDay() {
        return repo.findTop20ByOrderByCreatedAtDesc();
    }

    public long soChuaDoc() {
        return repo.countByDaDocFalse();
    }

    @Transactional
    public void danhDauDaDoc(Integer id) {
        repo.findById(id).ifPresent(n -> {
            n.setDaDoc(true);
            repo.save(n);
        });
    }

    @Transactional
    public void danhDauTatCaDaDoc() {
        repo.danhDauTatCaDaDoc();
    }

    // ===== Thông báo riêng cho khách hàng (đơn hàng, bảo hành...) =====

    public void taoChoUser(Integer userId, String loai, String tieuDe, String noiDung, String link) {
        Notification n = new Notification();
        n.setUserId(userId);
        n.setLoai(loai);
        n.setTieuDe(tieuDe);
        n.setNoiDung(noiDung);
        n.setLink(link);
        repo.save(n);
    }

    public List<Notification> layGanDayCuaUser(Integer userId) {
        return repo.findTop20ByUserIdOrderByCreatedAtDesc(userId);
    }

    public long soChuaDocCuaUser(Integer userId) {
        return repo.countByUserIdAndDaDocFalse(userId);
    }

    @Transactional
    public void danhDauDaDocCuaUser(Integer id, Integer userId) {
        repo.findByIdAndUserId(id, userId).ifPresent(n -> {
            n.setDaDoc(true);
            repo.save(n);
        });
    }

    @Transactional
    public void danhDauTatCaDaDocCuaUser(Integer userId) {
        repo.danhDauTatCaDaDocCuaUser(userId);
    }
}
