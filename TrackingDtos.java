package com.fpoly.dto;

import java.util.List;

/**
 * DTO tracking thống nhất — Controller/Frontend chỉ cần biết format này, không cần quan tâm
 * đơn đang được GHN hay AfterShip (Shopee Express) trả về phía sau.
 */
public class TrackingDtos {

    public record TrackingStatusDto(
            String carrierCode,      // "ghn" | "spx"
            String maVanDon,         // mã khách tra cứu được (order_code GHN / tracking_number SPX)
            String trangThai,        // đã rút gọn về chung 1 bộ enum, xem TrackingStatus
            String trangThaiHienThi, // text tiếng Việt để show thẳng ra UI
            String duKienGiao,       // ISO date string, có thể null
            List<TrackingEventDto> lichSu
    ) {}

    public record TrackingEventDto(
            String thoiGian,   // ISO datetime string
            String moTa
    ) {}

    /** Bộ trạng thái chung — cả GHN lẫn SPX đều map về đây để UI chỉ cần 1 bộ switch-case. */
    public static final class TrangThai {
        public static final String CHO_LAY_HANG = "cho_lay_hang";
        public static final String DANG_VAN_CHUYEN = "dang_van_chuyen";
        public static final String DANG_GIAO = "dang_giao";
        public static final String DA_GIAO = "da_giao";
        public static final String HOAN_TRA = "hoan_tra";
        public static final String DA_HUY = "da_huy";
        public static final String KHONG_XAC_DINH = "khong_xac_dinh";

        private TrangThai() {}
    }
}
