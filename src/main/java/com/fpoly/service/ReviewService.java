package com.fpoly.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.ReviewDtos.DeliveryReviewRequest;
import com.fpoly.dto.ReviewDtos.ProductReviewDto;
import com.fpoly.dto.ReviewDtos.PurchasedItemDto;
import com.fpoly.dto.ReviewDtos.ReviewableItemDto;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderDeliveryReview;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Product;
import com.fpoly.model.Review;
import com.fpoly.model.Warranty;
import com.fpoly.repository.CarrierRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderDeliveryReviewRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.ProductRepository;
import com.fpoly.repository.ReviewRepository;
import com.fpoly.repository.WarrantyRepository;

/** Đánh giá sản phẩm (theo từng đơn đã giao, giới hạn 14 ngày) + đánh giá giao hàng
 * (người giao nội thành Hải Phòng / hãng vận chuyển liên tỉnh thành). */
@Service
public class ReviewService {

    @Autowired private ReviewRepository reviewRepo;
    @Autowired private OrderDeliveryReviewRepository deliveryReviewRepo;
    @Autowired private OrderRepository orderRepo;
    @Autowired private OrderStatusLogRepository statusLogRepo;
    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private CarrierRepository carrierRepo;
    @Autowired private ProductRepository productRepo;
    @Autowired private WarrantyRepository warrantyRepo;

    private static final int HAN_DANH_GIA_NGAY = 14;
    // Giao nội thành Hải Phòng (ShippingService) — còn lại là mã hãng vận chuyển liên tỉnh (CARRIER).
    private static final List<String> MA_TUY_CHON_NOI_THANH = List.of("hoa_toc", "thuong");

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    private Order layDonCuaUser(Integer orderId, NguoiDung user) {
        Order order = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
        if (!order.getNguoiDung().getId().equals(user.getId())) {
            throw new RuntimeException("Bạn không có quyền thao tác với đơn hàng này");
        }
        if (!"delivered".equals(order.getTrangThai())) {
            throw new RuntimeException("Chỉ có thể đánh giá đơn hàng đã giao");
        }
        return order;
    }

    /** Thời điểm đơn chuyển sang 'delivered' — lấy từ log trạng thái, không cần cột riêng trên Order. */
    private LocalDateTime thoiGianGiaoHang(Order order) {
        return statusLogRepo.findByOrderOrderByThoiGianAsc(order).stream()
                .filter(l -> "delivered".equals(l.getTrangThai()))
                .map(OrderStatusLog::getThoiGian)
                .max(LocalDateTime::compareTo)
                .orElse(null);
    }

    private void kiemTraConHanDanhGia(LocalDateTime giaoLuc) {
        if (giaoLuc == null || LocalDateTime.now().isAfter(giaoLuc.plusDays(HAN_DANH_GIA_NGAY))) {
            throw new RuntimeException("Đã hết hạn " + HAN_DANH_GIA_NGAY + " ngày đánh giá cho đơn hàng này");
        }
    }

    /** Danh sách sản phẩm (theo từng đơn đã giao) mà user còn quyền đánh giá. */
    public List<ReviewableItemDto> getReviewableItems(String email) {
        NguoiDung user = layUser(email);
        List<Order> donDaGiao = orderRepo.findByNguoiDungOrderByCreatedAtDesc(user).stream()
                .filter(o -> "delivered".equals(o.getTrangThai()))
                .toList();

        List<ReviewableItemDto> out = new ArrayList<>();
        for (Order o : donDaGiao) {
            LocalDateTime giaoLuc = thoiGianGiaoHang(o);
            if (giaoLuc == null || LocalDateTime.now().isAfter(giaoLuc.plusDays(HAN_DANH_GIA_NGAY))) continue;

            boolean daDanhGiaGiaoHang = deliveryReviewRepo.existsByOrderId(o.getId());
            for (OrderItem oi : o.getChiTiet()) {
                Integer productId = oi.getVariant().getProduct().getId();
                if (reviewRepo.existsByProductIdAndNguoiDungIdAndOrderId(productId, user.getId(), o.getId())) continue;
                out.add(new ReviewableItemDto(
                        o.getId(), o.getMaDonHang(), oi.getId(),
                        productId, oi.getTenSanPham(), oi.getVariant().getProduct().getSlug(),
                        giaoLuc, giaoLuc.plusDays(HAN_DANH_GIA_NGAY), daDanhGiaGiaoHang
                ));
            }
        }
        return out;
    }

    /** Tất cả sản phẩm thuộc các đơn đã giao (kể cả đã đánh giá/hết hạn) — cho tab "Sản phẩm đã
     * mua" trong QLTK, gộp sẵn trạng thái đánh giá + bảo hành theo từng dòng sản phẩm. */
    public List<PurchasedItemDto> getPurchasedItems(String email) {
        NguoiDung user = layUser(email);
        List<Order> donDaGiao = orderRepo.findByNguoiDungOrderByCreatedAtDesc(user).stream()
                .filter(o -> "delivered".equals(o.getTrangThai()))
                .toList();

        List<PurchasedItemDto> out = new ArrayList<>();
        for (Order o : donDaGiao) {
            LocalDateTime giaoLuc = thoiGianGiaoHang(o);
            LocalDateTime hanCuoi = giaoLuc == null ? null : giaoLuc.plusDays(HAN_DANH_GIA_NGAY);
            boolean conHan = hanCuoi != null && LocalDateTime.now().isBefore(hanCuoi);

            for (OrderItem oi : o.getChiTiet()) {
                Integer productId = oi.getVariant().getProduct().getId();
                boolean daDanhGia = reviewRepo.existsByProductIdAndNguoiDungIdAndOrderId(productId, user.getId(), o.getId());
                Warranty w = warrantyRepo.findByOrderItem(oi).orElse(null);

                out.add(new PurchasedItemDto(
                        o.getId(), o.getMaDonHang(), oi.getId(),
                        productId, oi.getTenSanPham(), oi.getVariant().getProduct().getSlug(),
                        daDanhGia, !daDanhGia && conHan, hanCuoi,
                        w != null ? w.getId() : null, w != null ? w.getStatus() : null, w != null ? w.getEndDate() : null
                ));
            }
        }
        return out;
    }

    @Transactional
    public void submitProductReview(String email, Integer orderId, Integer productId, Integer rating,
                                     String comment, MultipartFile photo1, MultipartFile photo2) {
        NguoiDung user = layUser(email);
        Order order = layDonCuaUser(orderId, user);
        kiemTraConHanDanhGia(thoiGianGiaoHang(order));

        if (rating == null || rating < 1 || rating > 5) {
            throw new RuntimeException("Số sao đánh giá không hợp lệ");
        }
        if (reviewRepo.existsByProductIdAndNguoiDungIdAndOrderId(productId, user.getId(), orderId)) {
            throw new RuntimeException("Bạn đã đánh giá sản phẩm này cho đơn hàng này rồi");
        }
        Product product = productRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        Review r = new Review();
        r.setProduct(product);
        r.setNguoiDung(user);
        r.setOrder(order);
        r.setRating(rating);
        r.setComment(comment);
        r.setIsVerified(true);
        r.setPhoto1Url(luuAnh(photo1));
        r.setPhoto2Url(luuAnh(photo2));
        reviewRepo.save(r);
    }

    @Transactional
    public void submitDeliveryReview(String email, DeliveryReviewRequest req) {
        NguoiDung user = layUser(email);
        Order order = layDonCuaUser(req.orderId(), user);
        kiemTraConHanDanhGia(thoiGianGiaoHang(order));

        if (deliveryReviewRepo.existsByOrderId(order.getId())) {
            throw new RuntimeException("Bạn đã đánh giá giao hàng cho đơn này rồi");
        }
        Integer rating = req.rating();
        if (rating == null || rating < 1 || rating > 5) {
            throw new RuntimeException("Số sao đánh giá không hợp lệ");
        }

        OrderDeliveryReview r = new OrderDeliveryReview();
        r.setOrder(order);
        r.setNguoiDung(user);
        r.setRating(rating);
        r.setComment(req.comment());

        String maTuyChon = order.getMaTuyChonGiaoHang();
        if (maTuyChon != null && MA_TUY_CHON_NOI_THANH.contains(maTuyChon)) {
            r.setTargetType("shop_shipper");
        } else {
            r.setTargetType("carrier");
            if (maTuyChon != null) {
                carrierRepo.findByCode(maTuyChon).ifPresent(r::setCarrier);
            }
        }
        deliveryReviewRepo.save(r);
    }

    /** Đánh giá công khai của 1 sản phẩm (hiển thị dưới sản phẩm ở trang chi tiết), mới nhất trước. */
    public List<ProductReviewDto> getProductReviews(String slug) {
        Product product = productRepo.findBySlug(slug)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
        return reviewRepo.findByProductOrderByCreatedAtDesc(product).stream()
                .map(r -> new ProductReviewDto(
                        r.getId(), r.getNguoiDung().getHoTen(), r.getRating(), r.getComment(),
                        r.getPhoto1Url(), r.getPhoto2Url(), r.getCreatedAt(), r.getIsVerified()
                ))
                .toList();
    }

    /** Lưu ảnh đánh giá — cùng quy ước với PaymentApiController.uploadProof (UUID + tên file gốc đã lọc). */
    private String luuAnh(MultipartFile file) {
        if (file == null || file.isEmpty()) return null;
        try {
            String uploadDir = "uploads/review/";
            Files.createDirectories(Paths.get(uploadDir));

            String originalName = file.getOriginalFilename();
            if (originalName == null || originalName.isBlank()) originalName = "review.jpg";
            String safeName = originalName.replaceAll("\\s+", "_").replaceAll("[^a-zA-Z0-9._-]", "");
            String fileName = UUID.randomUUID() + "_" + safeName;

            Path path = Paths.get(uploadDir).resolve(fileName);
            Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);
            return "/uploads/review/" + fileName;
        } catch (IOException e) {
            throw new RuntimeException("Lỗi khi lưu ảnh đánh giá: " + e.getMessage());
        }
    }
}
