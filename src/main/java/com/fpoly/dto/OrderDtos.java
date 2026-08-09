package com.fpoly.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDtos {

    public record AddressDto(
            Integer id, String tenNguoiNhan, String soDienThoai, String diaChiCuThe,
            Integer provinceId, String tinhThanh, Integer wardId, String phuongXa,
            String diaChiDayDu, Boolean isDefault,
            BigDecimal latitude, BigDecimal longitude
    ) {}

    // provinceId/wardId chọn qua dropdown 2 tầng (xem /api/provinces) — không còn Quận/Huyện
    // (Việt Nam đã bỏ cấp huyện sau sáp nhập 1/7/2025). latitude/longitude là điểm khách cắm
    // trên bản đồ, BẮT BUỘC với địa chỉ tạo/sửa qua cnttshop-vue (xem AddressService).
    public record SaveAddressRequest(
            String tenNguoiNhan, String soDienThoai, String diaChiCuThe,
            Integer provinceId, Integer wardId, Boolean isDefault,
            BigDecimal latitude, BigDecimal longitude
    ) {}

    public record CartItemDto(
            Integer id, Integer variantId, Integer productId, String productSlug, String productName,
            String optionsText, String sku, String imageUrl, BigDecimal unitPrice, Integer quantity,
            BigDecimal lineTotal, Integer stock
    ) {}

    public record CartDto(List<CartItemDto> items, BigDecimal subtotal, Integer itemCount) {}

    public record AddCartItemRequest(Integer variantId, Integer quantity) {}
    public record UpdateCartItemRequest(Integer quantity) {}

    public record PaymentMethodDto(Integer id, String code, String name, String logoUrl) {}

    public record PaymentDto(
            Integer id, String methodCode, String methodName, BigDecimal amount,
            String status, LocalDateTime paidAt, String proofImage
    ) {}

    public record OrderItemDto(
            Integer id, String productName, String variantInfo, BigDecimal unitPrice,
            Integer quantity, BigDecimal lineTotal, String imageUrl
    ) {}

    public record OrderStatusLogDto(String status, String note, LocalDateTime changedAt) {}

    public record OrderSummaryDto(
            Integer id, String orderCode, String status, BigDecimal totalAmount,
            LocalDateTime createdAt, Integer itemCount
    ) {}

    public record OrderDetailDto(
            Integer id, String orderCode, String status, BigDecimal subtotal, BigDecimal discountAmount,
            BigDecimal shippingFee, String shippingOptionLabel, String shippingEta,
            BigDecimal totalAmount, LocalDateTime createdAt, AddressDto address,
            List<OrderItemDto> items, List<OrderStatusLogDto> statusHistory, PaymentDto payment
    ) {}

    // cartItemIds null/rỗng = thanh toán toàn bộ giỏ hàng (giữ tương thích cũ); có giá trị =
    // chỉ thanh toán các dòng được tick chọn ở CartView, các dòng còn lại vẫn nằm trong giỏ.
    // couponCode (CŨ, giữ tương thích ngược) null/rỗng = không áp mã. couponCodes (MỚI) = danh
    // sách nhiều mã cùng áp — nếu có giá trị thì ƯU TIÊN dùng couponCodes, bỏ qua couponCode
    // (xem OrderApiController.place). xuSuDung null/0 = không dùng Xu CT giảm trực tiếp vào
    // bill. shippingOptionCode = mã tuỳ chọn giao hàng (xem /api/shipping/options — hoa_toc/thuong
    // trong Hải Phòng, hoặc mã hãng ngoài Hải Phòng).
    // tradeInCreditId = tín dụng thu cũ khách chọn dùng cho đơn này (xem TradeInService).
    // Áp SONG SONG với coupon + xu, không tranh chỗ couponCode/couponCodes.
    public record PlaceOrderRequest(
            Integer addressId, String paymentMethodCode, List<Integer> cartItemIds, String couponCode,
            List<String> couponCodes,
            Integer xuSuDung, String shippingOptionCode, Integer tradeInCreditId
    ) {}

    public record PlaceOrderResultDto(OrderDetailDto order, String redirectUrl) {}
}
