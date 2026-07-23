package com.fpoly.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.ContactMessage;

public interface ContactMessageRepository extends JpaRepository<ContactMessage, Integer> {

    List<ContactMessage> findAllByOrderByCreatedAtDesc();

    long countByStatus(String status);
}
