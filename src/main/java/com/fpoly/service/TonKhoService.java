package com.fpoly.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.ProductVariant;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * Giữ / trả tồn kho của một biến thể.
 *
 * Vì sao không chỉ viết variant.setStock(stock - n): đọc tồn rồi mới ghi lại là hai bước tách
 * rời, hai khách bấm "Đặt hàng" cùng lúc trên món cuối cùng đều đọc thấy stock=1 và đều ghi
 * xuống 0 — bán mất một món không có thật. Cột version (@Version) chặn được ghi đè nhưng chỉ
 * bằng cách ném OptimisticLockException, tức là khách thua cuộc nhận một lỗi hệ thống khó hiểu
 * thay vì câu "sản phẩm vừa hết hàng".
 *
 * Ở đây dùng MỘT câu UPDATE có điều kiện: chính CSDL vừa kiểm vừa trừ trong một thao tác, ai
 * chạy sau thấy stock đã không còn đủ nên cập nhật 0 dòng và được báo lỗi nghiệp vụ đúng nghĩa.
 * Cột version cũng được tăng tay để mọi thực thể đang giữ bản cũ trong bộ nhớ không ghi đè
 * ngược lại.
 */
@Service
public class TonKhoService {

    @PersistenceContext
    private EntityManager em;

    /**
     * Giữ soLuong đơn vị của biến thể. Trả về false nếu kho không còn đủ (KHÔNG ném lỗi — nơi
     * gọi biết tên sản phẩm nên tự dựng được thông báo dễ hiểu hơn).
     *
     * Chạy trong transaction RIÊNG (REQUIRES_NEW) thì sẽ hỏng ý nghĩa "đặt hàng thất bại thì
     * trả lại hàng", nên cố tình dùng transaction của nơi gọi: đơn hàng rollback thì phần giữ
     * hàng cũng rollback theo.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    public boolean giuHang(ProductVariant variant, int soLuong) {
        if (soLuong <= 0) return true;
        int soDong = em.createNativeQuery(
                        "UPDATE PRODUCT_VARIANT SET stock = stock - :sl, version = version + 1 "
                                + "WHERE id = :id AND stock >= :sl")
                .setParameter("sl", soLuong)
                .setParameter("id", variant.getId())
                .executeUpdate();
        if (soDong == 0) return false;
        napLai(variant);
        return true;
    }

    /** Trả hàng về kho (huỷ đơn, hết hạn giữ hàng, hoàn trả). Luôn thành công. */
    @Transactional(propagation = Propagation.MANDATORY)
    public void traHang(ProductVariant variant, int soLuong) {
        if (soLuong <= 0) return;
        em.createNativeQuery(
                        "UPDATE PRODUCT_VARIANT SET stock = stock + :sl, version = version + 1 WHERE id = :id")
                .setParameter("sl", soLuong)
                .setParameter("id", variant.getId())
                .executeUpdate();
        napLai(variant);
    }

    /** Bản trong bộ nhớ vừa cũ đi một nhịp so với CSDL — nạp lại để mọi chỗ đọc tiếp theo (VD
     * kiểm "còn hàng không" khi hiển thị) thấy đúng con số vừa ghi. Bỏ qua nếu thực thể không
     * thuộc phiên hiện tại: refresh() một thực thể detached sẽ ném lỗi. */
    private void napLai(ProductVariant variant) {
        if (em.contains(variant)) em.refresh(variant);
    }
}
