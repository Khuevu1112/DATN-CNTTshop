package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import com.fpoly.model.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    List<Notification> findTop20ByOrderByCreatedAtDesc();

    long countByDaDocFalse();

    @Modifying
    @Query("UPDATE Notification n SET n.daDoc = true WHERE n.daDoc = false")
    void danhDauTatCaDaDoc();

    List<Notification> findTop20ByUserIdOrderByCreatedAtDesc(Integer userId);

    long countByUserIdAndDaDocFalse(Integer userId);

    Optional<Notification> findByIdAndUserId(Integer id, Integer userId);

    @Modifying
    @Query("UPDATE Notification n SET n.daDoc = true WHERE n.userId = :userId AND n.daDoc = false")
    void danhDauTatCaDaDocCuaUser(Integer userId);
}
