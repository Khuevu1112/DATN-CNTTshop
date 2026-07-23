package com.fpoly.dto;

import java.util.List;

public class MembershipDtos {

    /** Ưu đãi của 1 bậc — dùng cho cả bậc hiện tại lẫn danh sách đầy đủ 4 bậc trong popup
     * "Chi tiết" ở trang cá nhân. */
    public record TierBenefitDto(
            String code,
            String name,
            int xuToiThieu,
            Integer xuToiDa,
            boolean mienPhiNoiThanh,
            int phanTramGiamPhiLienTinh,
            int phanTramGiamDon
    ) {}

    /** Trạng thái thành viên của khách đang đăng nhập — đủ dữ liệu để vẽ thanh tiến độ:
     * xuTichLuy nằm giữa moc[Dau|Cuoi], phanTram là % đã đi được tới bậc kế tiếp. */
    public record MembershipStatusDto(
            int xuTichLuy,
            TierBenefitDto bacHienTai,
            TierBenefitDto bacKeTiep,
            int mocDau,
            Integer mocCuoi,
            int phanTram,
            int xuConThieu,
            List<TierBenefitDto> tatCaBac
    ) {}
}
