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
}
