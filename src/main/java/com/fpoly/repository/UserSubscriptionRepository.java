package com.fpoly.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.UserSubscription;

public interface UserSubscriptionRepository extends JpaRepository<UserSubscription, Integer> {

    /** Gói còn hiệu lực của khách: đã kích hoạt và chưa hết hạn. Lấy gói hết hạn muộn nhất
     * phòng khi khách mua chồng nhiều gói (gói mua sau gia hạn cho gói trước). */
    @Query("select us from UserSubscription us "
            + "where us.nguoiDung = :user and us.status = 'active' and us.expiresAt > :now "
            + "order by us.expiresAt desc")
    List<UserSubscription> timGoiConHieuLuc(@Param("user") NguoiDung user, @Param("now") LocalDateTime now);

    default Optional<UserSubscription> goiConHieuLuc(NguoiDung user, LocalDateTime now) {
        return timGoiConHieuLuc(user, now).stream().findFirst();
    }

    List<UserSubscription> findByNguoiDungOrderByCreatedAtDesc(NguoiDung user);

    /** Mọi lượt đăng ký, mới nhất trước — dùng cho trang quản lý hội viên phía admin để dựng
     * danh sách hội viên (gom nhóm theo người trong service). */
    List<UserSubscription> findAllByOrderByCreatedAtDesc();
}
