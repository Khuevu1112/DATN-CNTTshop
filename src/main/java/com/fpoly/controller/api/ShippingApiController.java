package com.fpoly.controller.api;

import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import com.fpoly.dto.ShippingDtos.ShippingOptionsDto;
import com.fpoly.service.ShippingService;

/** Tuỳ chọn + phí giao hàng theo địa chỉ (Phường) — dùng ở Checkout để khách chọn hoả tốc/thường
 * (trong Hải Phòng) hoặc đơn vị vận chuyển (ngoài Hải Phòng) trước khi đặt hàng. Công khai. */
@RestController
@RequestMapping("/api/shipping")
public class ShippingApiController {

    @Autowired private ShippingService shippingService;

    /** Endpoint công khai (khách chưa đăng nhập vẫn xem được phí), nhưng nếu có token hợp lệ thì
     * phí trả về đã trừ ưu đãi bậc thành viên của khách đó — khớp đúng với phí backend tính lại
     * lúc tạo đơn (xem OrderService.datHangTuGioHang). */
    /** lat/lng = điểm khách đã cắm trên bản đồ cho địa chỉ đang chọn — có thì phí nội thành Hải
     * Phòng tính theo quãng đường thật từ kho, không có thì rơi về bảng phí phẳng cũ. */
    @GetMapping("/options")
    public ShippingOptionsDto options(@RequestParam Integer wardId,
                                      @RequestParam(required = false) BigDecimal lat,
                                      @RequestParam(required = false) BigDecimal lng,
                                      Authentication auth) {
        return shippingService.layTuyChon(wardId, lat, lng, auth == null ? null : auth.getName());
    }
}
