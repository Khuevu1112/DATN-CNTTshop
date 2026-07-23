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
        Order order = orderService.datHangTuGioHang(auth.getName(), req.addressId(), code, req.cartItemIds(),
                req.couponCode(), req.xuSuDung(), req.shippingOptionCode(), req.tradeInCreditId());

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
        // Đơn bán tại quầy không có địa chỉ giao (address_id NULL) -> trả null, client tự ẩn
        // khối "Địa chỉ nhận hàng" thay vì vỡ.
        UserAddress diaChiGiao = o.getDiaChiGiao();
        AddressDto addr = diaChiGiao == null ? null : new AddressDto(
                diaChiGiao.getId(), diaChiGiao.getTenNguoiNhan(), diaChiGiao.getSoDienThoai(),
                diaChiGiao.getDiaChiCuThe(),
                diaChiGiao.getProvince() != null ? diaChiGiao.getProvince().getId() : null, diaChiGiao.getTinhThanh(),
                diaChiGiao.getWard() != null ? diaChiGiao.getWard().getId() : null, diaChiGiao.getPhuongXa(),
                diaChiGiao.getDiaChiDayDu(), diaChiGiao.getIsDefault(),
                diaChiGiao.getLatitude(), diaChiGiao.getLongitude());

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
                o.getTongTien(), o.getCreatedAt(), addr, items, history, paymentDto);
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
