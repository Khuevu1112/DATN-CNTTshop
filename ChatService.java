package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.ChatDtos.ChatMessageRequest;
import com.fpoly.dto.ChatDtos.ChatMessageResponse;
import com.fpoly.model.ChatMessage;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.ChatMessageRepository;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class ChatService {

    @Autowired
    private ChatMessageRepository chatRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    public List<ChatMessageResponse> layLichSu(String email) {
        NguoiDung user = layUser(email);
        return chatRepo.findByNguoiDungOrderByCreatedAtAsc(user)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public ChatMessageResponse luuTinNhan(String email, ChatMessageRequest req) {
        if (req == null || req.role() == null || req.content() == null || req.content().isBlank()) {
            throw new RuntimeException("Thiếu nội dung tin nhắn");
        }
        if (!"user".equals(req.role()) && !"bot".equals(req.role())) {
            throw new RuntimeException("role không hợp lệ (chỉ nhận 'user' hoặc 'bot')");
        }

        NguoiDung user = layUser(email);

        ChatMessage msg = new ChatMessage();
        msg.setNguoiDung(user);
        msg.setRole(req.role());
        msg.setContent(req.content());
        msg.setMetadata(req.metadata());

        ChatMessage saved = chatRepo.save(msg);
        return toResponse(saved);
    }

    @Transactional
    public void xoaLichSu(String email) {
        NguoiDung user = layUser(email);
        chatRepo.deleteByNguoiDung(user);
    }

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private ChatMessageResponse toResponse(ChatMessage m) {
        return new ChatMessageResponse(
                m.getId(),
                m.getRole(),
                m.getContent(),
                m.getMetadata(),
                m.getCreatedAt()
        );
    }
}
