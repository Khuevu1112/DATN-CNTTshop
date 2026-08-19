package com.fpoly.controller.api;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.OrderDtos.AddressDto;
import com.fpoly.dto.OrderDtos.OrderDetailDto;
import com.fpoly.dto.OrderDtos.OrderItemDto;
import com.fpoly.dto.OrderDtos.OrderStatusLogDto;
import com.fpoly.dto.OrderDtos.OrderSummaryDto;
import com.fpoly.dto.OrderDtos.PaymentDto;
import com.fpoly.dto.OrderDtos.PlaceOrderRequest;
import com.fpoly.dto.OrderDtos.PlaceOrderResultDto;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.UserAddress;
import com.fpoly.service.OrderService;

/** Đặt hàng + tra cứu đơn hàng thật — dùng cho cnttshop-vue. */
@RestController
@RequestMapping("/api/orders")
public class OrderApiController {

    @Autowired private OrderService orderService;

    @GetMapping
    public List<OrderSummaryDto> myOrders(Authentication auth) {
        return orderService.layDonHangCuaUser(auth.getName()).stream().map(this::toSummary).toList();
    }

    @GetMapping("/{id}")
    public OrderDetailDto detail(@PathVariable Integer id, Authentication auth) {
        return toDetail(orderService.layChiTietDon(id, auth.getName()));
    }

    @PostMapping
    public PlaceOrderResultDto place(@RequestBody PlaceOrderRequest req, Authentication auth) {
        String code = req.paymentMethodCode() == null ? "cod" : req.paymentMethodCode();
        // Ưu tiên couponCodes (nhiều mã, tính năng mới) — nếu client chưa cập nhật và chỉ gửi
        // couponCode (1 mã, cũ) thì fallback bọc thành danh sách 1 phần tử.
        List<String> maCouponList = (req.couponCodes() != null && !req.couponCodes().isEmpty())
                ? req.couponCodes()
                : (req.couponCode() != null && !req.couponCode().isBlank() ? List.of(req.couponCode()) : List.of());
        Order order = orderService.datHangTuGioHang(auth.getName(), req.addressId(), code, req.cartItemIds(),
                maCouponList, req.xuSuDung(), req.shippingOptionCode(), req.tradeInCreditId());

        String redirectUrl = null;
        if (orderService.laCongThanhToanRedirect(code)) {
            Payment payment = orderService.layPaymentCuaDon(order);
            String duongDan = code.startsWith("vnpay") ? "/payment/vnpay/pay" : "/payment/stripe/pay";
            redirectUrl = "http://localhost:8080" + duongDan + "?paymentId=" + payment.getId();
        }
        return new PlaceOrderResultDto(toDetail(order), redirectUrl);
    }

    @PostMapping("/{id}/cancel")
    public void cancel(@PathVariable Integer id, @RequestBody(required = false) Map<String, String> body, Authentication auth) {
        String lyDo = body != null ? body.get("reason") : null;
        orderService.huyDon(id, auth.getName(), lyDo);
    }

    private OrderSummaryDto toSummary(Order o) {
        return new OrderSummaryDto(o.getId(), o.getMaDonHang(), o.getTrangThai(), o.getTongTien(),
                o.getCreatedAt(), o.getChiTiet() == null ? 0 : o.getChiTiet().size());
    }

    private OrderDetailDto toDetail(Order o) {
        // Đọc từ bản CHỤP trên đơn, không từ FK — khách có thể đã sửa/xoá địa chỉ trong sổ sau
        // khi đặt (xem AddressService.xoa). FK chỉ còn dùng để lấy provinceId/wardId khi địa
        // chỉ vẫn tồn tại. Đơn bán tại quầy không có địa chỉ giao -> trả null, client tự ẩn
        // khối "Địa chỉ nhận hàng" thay vì vỡ.
        UserAddress diaChiGiao = o.getDiaChiGiao();
        String diaChiDayDu = o.getDiaChiNhanHangHienThi();
        AddressDto addr = diaChiDayDu == null ? null : new AddressDto(
                diaChiGiao != null ? diaChiGiao.getId() : null,
                o.getTenNguoiNhanHienThi(), o.getSoDienThoaiNhanHienThi(),
                diaChiGiao != null ? diaChiGiao.getDiaChiCuThe() : diaChiDayDu,
                diaChiGiao != null && diaChiGiao.getProvince() != null ? diaChiGiao.getProvince().getId() : null,
                diaChiGiao != null ? diaChiGiao.getTinhThanh() : null,
                diaChiGiao != null && diaChiGiao.getWard() != null ? diaChiGiao.getWard().getId() : null,
                diaChiGiao != null ? diaChiGiao.getPhuongXa() : null,
                diaChiDayDu, diaChiGiao != null ? diaChiGiao.getIsDefault() : Boolean.FALSE,
                o.getViDoGiao(), o.getKinhDoGiao());

        List<OrderItemDto> items = (o.getChiTiet() == null ? List.<OrderItem>of() : o.getChiTiet()).stream()
                .map(this::toItemDto).toList();

        List<OrderStatusLogDto> history = (o.getLichSuTrangThai() == null ? List.<OrderStatusLog>of() : o.getLichSuTrangThai())
                .stream().map(l -> new OrderStatusLogDto(l.getTrangThai(), l.getGhiChu(), l.getThoiGian())).toList();

        Payment payment = orderService.layPaymentCuaDon(o);
        PaymentDto paymentDto = payment == null ? null : new PaymentDto(
                payment.getId(), payment.getPaymentMethod().getCode(), payment.getPaymentMethod().getName(),
                payment.getAmount(), payment.getStatus(), payment.getPaidAt(), payment.getProofImage());

        return new OrderDetailDto(o.getId(), o.getMaDonHang(), o.getTrangThai(), o.getTienHang(),
                o.getTienGiamGia(), o.getPhiVanChuyen(), o.getNhanTuyChonGiaoHang(), o.getThoiGianGiaoDuKien(),
                o.getTongTien(), o.getCreatedAt(), addr, items, history, paymentDto,
                // Chỉ gửi khi hạn còn hiệu lực — hạn đã qua thì đơn sắp bị tác vụ quét huỷ, hiện
                // đồng hồ âm chỉ làm khách hoang mang.
                o.dangGiuHang() ? o.getHanGiuHang() : null);
    }

    private OrderItemDto toItemDto(OrderItem oi) {
        Product p = oi.getVariant().getProduct();
        String img = (p.getImages() != null && !p.getImages().isEmpty())
                ? p.getImages().stream().filter(i -> Boolean.TRUE.equals(i.getIsPrimary()))
                    .map(ProductImage::getUrl).findFirst().orElse(p.getImages().get(0).getUrl())
                : null;
        return new OrderItemDto(oi.getId(), oi.getTenSanPham(), oi.getThongTinPhienBan(),
                oi.getDonGia(), oi.getSoLuong(), oi.getThanhTien(), img);
    }
}
