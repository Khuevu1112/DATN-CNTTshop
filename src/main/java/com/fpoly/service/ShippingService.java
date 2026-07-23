package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.dto.ShippingDtos.ShippingOptionDto;
import com.fpoly.dto.ShippingDtos.ShippingOptionsDto;
import com.fpoly.model.MembershipTier;
import com.fpoly.model.Province;
import com.fpoly.model.UserAddress;
import com.fpoly.model.Ward;
import com.fpoly.repository.CarrierRepository;
import com.fpoly.repository.ShippingHpTierRepository;
import com.fpoly.repository.WardRepository;
import com.fpoly.service.SubscriptionService.UuDaiGiaoHangGoi;

/** Tính phí + thời gian giao hàng. Mốc tính là kho 118 Cát Bi, Phường Hải An, Hải Phòng.
 *
 * Trong Hải Phòng: phí theo QUÃNG ĐƯỜNG THỰC TẾ từ kho tới điểm khách cắm trên bản đồ, luỹ tiến
 * theo vòng bán kính (xem phiTheoKhoangCach). Địa chỉ chưa cắm mốc (tạo trước khi có tính năng
 * này, hoặc tạo qua trang Thymeleaf cũ) rơi về bảng phí phẳng SHIPPING_HP_TIER như trước.
 *
 * Ngoài Hải Phòng: khách chọn 1 trong 5 đơn vị vận chuyển, phí theo bảng admin cấu hình, thời
 * gian theo miền — không tính theo km vì đó là giá hãng vận chuyển thu, không phải xe của shop. */
@Service
public class ShippingService {

    // Mã Phường Hải An / Tỉnh Hải Phòng trong bảng WARD/PROVINCE (xem database/40_province_ward.sql).
    private static final String MA_PHUONG_MOC = "11413";
    private static final String MA_TINH_HAI_PHONG = "31";
    private static final BigDecimal HE_SO_HOA_TOC = new BigDecimal("1.3");

    // Toạ độ kho: 118 Cát Bi, Phường Hải An, Hải Phòng.
    private static final BigDecimal VI_DO_KHO = new BigDecimal("20.8248000");
    private static final BigDecimal KINH_DO_KHO = new BigDecimal("106.7169000");

    // Đơn giá luỹ tiến theo vòng bán kính tính từ kho, giống cách tính bậc thuế: mỗi km chỉ bị
    // tính theo đơn giá của vòng mà chính km đó nằm trong. VD 15km = 10km đầu x250 + 5km sau
    // x500 = 5.000đ, KHÔNG phải 15km x 500.
    private static final BigDecimal MOC_VONG_1_KM = new BigDecimal("10");
    private static final BigDecimal MOC_VONG_2_KM = new BigDecimal("20");
    private static final BigDecimal GIA_VONG_1 = new BigDecimal("250");   // 0 -> 10km
    private static final BigDecimal GIA_VONG_2 = new BigDecimal("500");   // 10 -> 20km
    private static final BigDecimal GIA_VONG_3 = new BigDecimal("1000");  // vượt 20km

    @Autowired private WardRepository wardRepo;
    @Autowired private ShippingHpTierRepository hpTierRepo;
    @Autowired private CarrierRepository carrierRepo;
    @Autowired private MembershipService membershipService;
    @Autowired private SubscriptionService subscriptionService;
    @Autowired private DistanceService distanceService;

    /** Phí cho khách vãng lai / chưa đăng nhập, địa chỉ chưa cắm mốc. */
    public ShippingOptionsDto layTuyChon(Integer wardId) {
        return layTuyChon(wardId, null, null, null);
    }

    /** Tuỳ chọn giao hàng cho 1 địa chỉ cụ thể — dùng toạ độ đã cắm của địa chỉ đó. */
    public ShippingOptionsDto layTuyChonChoDiaChi(UserAddress address, String email) {
        Integer wardId = address.getWard() == null ? null : address.getWard().getId();
        return layTuyChon(wardId, address.getLatitude(), address.getLongitude(), email);
    }

    /** lat/lng != null -> phí nội thành tính theo quãng đường thật từ kho tới điểm cắm.
     * email != null -> phí đã trừ ưu đãi bậc thành viên (xem MembershipTier). Phí gốc vẫn được
     * giữ trong feeGoc để UI hiển thị phần đã tiết kiệm. */
    public ShippingOptionsDto layTuyChon(Integer wardId, BigDecimal lat, BigDecimal lng, String email) {
        // Địa chỉ tạo qua trang Thymeleaf cũ chỉ có Phường dạng text, không có FK — findById(null)
        // sẽ ném lỗi hạ tầng khó hiểu thay vì thông báo cho khách, nên chặn trước ở đây.
        if (wardId == null) {
            throw new RuntimeException("Địa chỉ này chưa có Phường/Xã chuẩn hoá, vui lòng cập nhật lại địa chỉ");
        }
        Ward ward = wardRepo.findById(wardId)
                .orElseThrow(() -> new RuntimeException("Địa chỉ giao hàng không hợp lệ"));
        Province province = ward.getProvince();

        // Tra bậc thành viên + gói hội viên ĐÚNG MỘT LẦN cho cả danh sách — tra theo từng tuỳ
        // chọn sẽ lặp lại truy vấn user + ví + tổng xu cho mỗi hãng vận chuyển (5 hãng = 15 truy
        // vấn thừa). Đây chỉ là HIỂN THỊ phí; lượt free ship liên tỉnh của gói chỉ thực sự bị trừ
        // khi đặt đơn (xem OrderService + SubscriptionService.ghiNhanGiaoHangLienTinh), không trừ
        // mỗi lần xem phí.
        MembershipTier bac = membershipService.bacCua(email);
        UuDaiGiaoHangGoi goi = subscriptionService.uuDaiGiaoHang(email);

        if (MA_TINH_HAI_PHONG.equals(province.getCode())) {
            return tuyChonHaiPhong(ward, lat, lng, bac, goi);
        }
        return tuyChonCarrier(province, bac, goi);
    }

    private ShippingOptionsDto tuyChonHaiPhong(Ward ward, BigDecimal lat, BigDecimal lng,
                                               MembershipTier bac, UuDaiGiaoHangGoi goi) {
        BigDecimal khoangCach = null;
        BigDecimal baseFee;

        if (lat != null && lng != null) {
            khoangCach = distanceService.khoangCachKm(VI_DO_KHO, KINH_DO_KHO, lat, lng);
            baseFee = phiTheoKhoangCach(khoangCach);
        } else {
            // Địa chỉ chưa cắm mốc -> giữ nguyên bảng phí phẳng cũ để không chặn khách đặt hàng.
            boolean cungPhuongMoc = MA_PHUONG_MOC.equals(ward.getCode());
            baseFee = hpTierRepo.findByTierKey(cungPhuongMoc ? "same_ward" : "other_ward")
                    .orElseThrow(() -> new RuntimeException("Chưa cấu hình phí giao hàng nội thành Hải Phòng"))
                    .getFee();
        }

        BigDecimal hoaTocFee = baseFee.multiply(HE_SO_HOA_TOC).setScale(0, RoundingMode.HALF_UP);

        List<ShippingOptionDto> options = List.of(
                uuDai("hoa_toc", "Hoả tốc", hoaTocFee, "Trong ngày (trong vòng 5 tiếng)", bac, true, goi),
                uuDai("thuong", "Thường", baseFee, "Trước 9h sáng hôm sau", bac, true, goi)
        );
        return new ShippingOptionsDto("hai_phong", options, khoangCach);
    }

    /** Phí giao nội thành theo quãng đường, luỹ tiến theo vòng bán kính tính từ kho:
     *   - 10km đầu:        250đ/km
     *   - km thứ 10 -> 20: 500đ/km
     *   - vượt 20km:       1.000đ/km
     * VD: 5km = 1.250đ; 10km = 2.500đ; 15km = 5.000đ; 20km = 7.500đ; 30km = 17.500đ. */
    public BigDecimal phiTheoKhoangCach(BigDecimal km) {
        if (km == null || km.signum() <= 0) return BigDecimal.ZERO;

        BigDecimal phi = BigDecimal.ZERO;

        BigDecimal trongVong1 = km.min(MOC_VONG_1_KM);
        phi = phi.add(trongVong1.multiply(GIA_VONG_1));

        if (km.compareTo(MOC_VONG_1_KM) > 0) {
            BigDecimal trongVong2 = km.min(MOC_VONG_2_KM).subtract(MOC_VONG_1_KM);
            phi = phi.add(trongVong2.multiply(GIA_VONG_2));
        }
        if (km.compareTo(MOC_VONG_2_KM) > 0) {
            BigDecimal ngoaiVong2 = km.subtract(MOC_VONG_2_KM);
            phi = phi.add(ngoaiVong2.multiply(GIA_VONG_3));
        }

        return phi.setScale(0, RoundingMode.HALF_UP);
    }

    private ShippingOptionsDto tuyChonCarrier(Province province, MembershipTier bac, UuDaiGiaoHangGoi goi) {
        boolean cungMienHaiPhong = "bac".equals(province.getRegion());
        List<ShippingOptionDto> options = carrierRepo.findByIsActiveTrueOrderByThuTuAsc().stream()
                .map(c -> uuDai(
                        c.getCode(), c.getName(), c.getFeeLienTinh(),
                        cungMienHaiPhong ? c.getTimeCungMien() : c.getTimeKhacMien(), bac, false, goi))
                .toList();
        return new ShippingOptionsDto("carrier", options, null);
    }

    /** Phí sau ưu đãi = ưu đãi TỐT HƠN giữa hạng tích luỹ và gói dịch vụ (không cộng dồn):
     *   - nội thành thường: gói free_inner -> 0; nếu không thì theo hạng.
     *   - nội thành hoả tốc: gói free_express -> 0; nếu không thì theo hạng.
     *   - liên tỉnh: gói còn lượt free -> 0 (hạng chỉ giảm %, không bao giờ về 0); nếu hết
     *     lượt/không có gói thì theo hạng. Lượt free liên tỉnh chỉ TRỪ khi đặt đơn thật, đây
     *     chỉ hiển thị mức phí khách sẽ trả. */
    private ShippingOptionDto uuDai(String code, String label, BigDecimal feeGoc, String eta,
                                    MembershipTier bac, boolean noiThanh, UuDaiGiaoHangGoi goi) {
        BigDecimal fee = bac.phiVanChuyenSauUuDai(feeGoc, noiThanh);
        if (feeGoc != null && feeGoc.signum() > 0) {
            boolean goiFree = noiThanh
                    ? ("hoa_toc".equals(code) ? goi.freeHoaToc() : goi.freeNoiThanh())
                    : goi.conLuotLienTinh();
            if (goiFree) fee = BigDecimal.ZERO;
        }
        return new ShippingOptionDto(code, label, fee, eta, feeGoc);
    }

    /** Dùng khi tạo đơn thật (OrderService) — không tin phí client gửi lên, tính lại từ chính
     * địa chỉ đã lưu (kèm toạ độ đã cắm) + mã tuỳ chọn, kèm ưu đãi bậc thành viên của khách đặt
     * đơn. Ném lỗi nếu mã tuỳ chọn không còn hợp lệ (VD hãng bị admin tắt giữa lúc khách chọn). */
    public KetQuaPhiGiaoHang layPhiTheoOption(UserAddress address, String maTuyChon, String email) {
        ShippingOptionsDto tuyChon = layTuyChonChoDiaChi(address, email);
        ShippingOptionDto option = tuyChon.options().stream()
                .filter(o -> o.code().equals(maTuyChon))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Tuỳ chọn giao hàng không hợp lệ, vui lòng chọn lại"));
        return new KetQuaPhiGiaoHang(option, tuyChon.khoangCachKm());
    }

    /** Gói kèm quãng đường đã dùng để tính phí, để OrderService lưu lại vào đơn cho admin đối chiếu. */
    public record KetQuaPhiGiaoHang(ShippingOptionDto option, BigDecimal khoangCachKm) {}
}
