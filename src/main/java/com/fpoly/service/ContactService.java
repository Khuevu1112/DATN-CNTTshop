package com.fpoly.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.ContactDtos.ContactDetailDto;
import com.fpoly.dto.ContactDtos.ContactSubmitRequest;
import com.fpoly.dto.ContactDtos.ContactSummaryDto;
import com.fpoly.model.ContactMessage;
import com.fpoly.repository.ContactMessageRepository;

@Service
public class ContactService {

    @Autowired
    private ContactMessageRepository repo;

    @Autowired
    private NotificationService notificationService;

    @Transactional
    public void submit(ContactSubmitRequest req) {
        if (req.fullName() == null || req.fullName().isBlank()) {
            throw new RuntimeException("Vui lòng nhập họ tên");
        }
        if (req.email() == null || req.email().isBlank()) {
            throw new RuntimeException("Vui lòng nhập email");
        }
        if (req.message() == null || req.message().isBlank()) {
            throw new RuntimeException("Vui lòng nhập nội dung cần hỗ trợ");
        }

        ContactMessage msg = new ContactMessage();
        msg.setFullName(req.fullName().trim());
        msg.setEmail(req.email().trim());
        msg.setPhone(req.phone());
        msg.setSubject(req.subject());
        msg.setMessage(req.message().trim());
        msg.setStatus("new");
        repo.save(msg);

        notificationService.tao(
                "contact",
                "Liên hệ mới từ " + msg.getFullName(),
                msg.getSubject() != null && !msg.getSubject().isBlank() ? msg.getSubject() : msg.getMessage(),
                "/contacts"
        );
    }

    @Transactional(readOnly = true)
    public List<ContactSummaryDto> findAll() {
        return repo.findAllByOrderByCreatedAtDesc().stream()
                .map(m -> new ContactSummaryDto(
                        m.getId(), m.getFullName(), m.getEmail(), m.getPhone(),
                        m.getSubject(), m.getStatus(), m.getCreatedAt()))
                .toList();
    }

    @Transactional(readOnly = true)
    public ContactDetailDto findById(Integer id) {
        ContactMessage m = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy liên hệ"));
        return toDetail(m);
    }

    @Transactional
    public ContactDetailDto updateStatus(Integer id, String status) {
        ContactMessage m = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy liên hệ"));
        if (!List.of("new", "processing", "resolved").contains(status)) {
            throw new RuntimeException("Trạng thái không hợp lệ");
        }
        m.setStatus(status);
        repo.save(m);
        return toDetail(m);
    }

    @Transactional
    public ContactDetailDto reply(Integer id, String reply) {
        ContactMessage m = repo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy liên hệ"));
        m.setAdminReply(reply);
        m.setRepliedAt(LocalDateTime.now());
        m.setStatus("resolved");
        repo.save(m);
        return toDetail(m);
    }

    public long countNew() {
        return repo.countByStatus("new");
    }

    private ContactDetailDto toDetail(ContactMessage m) {
        return new ContactDetailDto(
                m.getId(), m.getFullName(), m.getEmail(), m.getPhone(), m.getSubject(),
                m.getMessage(), m.getStatus(), m.getAdminReply(), m.getRepliedAt(), m.getCreatedAt());
    }
}
