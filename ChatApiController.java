package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.AuthDtos.MessageResponse;
import com.fpoly.dto.ChatDtos.ChatMessageRequest;
import com.fpoly.dto.ChatDtos.ChatMessageResponse;
import com.fpoly.service.ChatService;

/**
 * REST API lưu & tải lịch sử chat của chatbot — chỉ cho user đã đăng nhập (JWT).
 * Guest (chưa đăng nhập) vẫn dùng localStorage phía Vue, không gọi API này.
 */
@RestController
@RequestMapping("/api/chat")
public class ChatApiController {

    @Autowired
    private ChatService chatService;

    @GetMapping("/history")
    public ResponseEntity<?> layLichSu(Authentication auth) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).body(new MessageResponse("Chưa đăng nhập"));
        }
        List<ChatMessageResponse> history = chatService.layLichSu(auth.getName());
        return ResponseEntity.ok(history);
    }

    @PostMapping("/messages")
    public ResponseEntity<?> luuTinNhan(Authentication auth, @RequestBody ChatMessageRequest req) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).body(new MessageResponse("Chưa đăng nhập"));
        }
        try {
            ChatMessageResponse saved = chatService.luuTinNhan(auth.getName(), req);
            return ResponseEntity.ok(saved);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(new MessageResponse(e.getMessage()));
        }
    }

    @DeleteMapping("/history")
    public ResponseEntity<?> xoaLichSu(Authentication auth) {
        if (auth == null || auth.getName() == null) {
            return ResponseEntity.status(401).body(new MessageResponse("Chưa đăng nhập"));
        }
        chatService.xoaLichSu(auth.getName());
        return ResponseEntity.ok(new MessageResponse("Đã xoá lịch sử chat"));
    }
}
