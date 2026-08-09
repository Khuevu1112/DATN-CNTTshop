package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ChatMessage;
import com.fpoly.model.NguoiDung;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Integer> {

    List<ChatMessage> findByNguoiDungOrderByCreatedAtAsc(NguoiDung nguoiDung);

    // Lấy N tin nhắn gần nhất (dùng khi lịch sử quá dài) - lấy desc rồi đảo ở service
    List<ChatMessage> findTop50ByNguoiDungOrderByCreatedAtDesc(NguoiDung nguoiDung);

    void deleteByNguoiDung(NguoiDung nguoiDung);
}
