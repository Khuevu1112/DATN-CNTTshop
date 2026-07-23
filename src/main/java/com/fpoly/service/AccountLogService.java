package com.fpoly.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import com.fpoly.model.AccountLog;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.AccountLogRepository;

/** Timeline hoạt động của 1 tài khoản (đăng nhập + khoá/mở khoá) — dùng chung bởi AuthApiController
 * (ghi log đăng nhập) và AdminApiController (ghi log khoá/mở khoá, đọc lại timeline cho trang chi
 * tiết tài khoản ở Quản lý tài khoản). */
@Service
public class AccountLogService {

    @Autowired
    private AccountLogRepository repo;

    public void logLogin(NguoiDung user, String ipAddress) {
        AccountLog log = new AccountLog();
        log.setUser(user);
        log.setLogType("login");
        log.setIpAddress(ipAddress);
        repo.save(log);
    }

    public void logLock(NguoiDung user, NguoiDung performedBy, String reason, LocalDateTime lockUntil, String evidenceImage) {
        AccountLog log = new AccountLog();
        log.setUser(user);
        log.setLogType("lock");
        log.setReason(reason);
        log.setLockUntil(lockUntil);
        log.setEvidenceImage(evidenceImage);
        log.setPerformedBy(performedBy);
        repo.save(log);
    }

    public void logUnlock(NguoiDung user, NguoiDung performedBy) {
        AccountLog log = new AccountLog();
        log.setUser(user);
        log.setLogType("unlock");
        log.setPerformedBy(performedBy);
        repo.save(log);
    }

    public List<Map<String, Object>> getRecentLogs(Integer userId, int limit) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (AccountLog log : repo.findByUserId(userId, PageRequest.of(0, limit))) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", log.getId());
            m.put("logType", log.getLogType());
            m.put("createdAt", log.getCreatedAt());
            m.put("reason", log.getReason());
            m.put("lockUntil", log.getLockUntil());
            m.put("evidenceImage", log.getEvidenceImage());
            m.put("performedByName", log.getPerformedBy() != null ? log.getPerformedBy().getHoTen() : null);
            m.put("ipAddress", log.getIpAddress());
            out.add(m);
        }
        return out;
    }
}
