package com.fpoly.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.AccountLog;

public interface AccountLogRepository extends JpaRepository<AccountLog, Integer> {

    @Query("SELECT a FROM AccountLog a LEFT JOIN FETCH a.performedBy WHERE a.user.id = :userId ORDER BY a.createdAt DESC")
    List<AccountLog> findByUserId(@Param("userId") Integer userId, Pageable pageable);
}
