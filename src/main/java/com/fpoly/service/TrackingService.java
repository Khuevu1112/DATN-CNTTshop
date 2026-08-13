package com.fpoly.service;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fpoly.dto.AfterShipDtos.Checkpoint;
import com.fpoly.dto.AfterShipDtos.Tracking;
import com.fpoly.dto.GhnDtos.GhnLog;
import com.fpoly.dto.GhnDtos.GhnOrderData;
import com.fpoly.dto.TrackingDtos.TrackingEventDto;
import com.fpoly.dto.TrackingDtos.TrackingStatusDto;
import com.fpoly.dto.TrackingDtos.TrangThai;
import com.fpoly.model.Order;

/**
 * Lớp trung gian: nhận vào 1 Order, tự biết phải gọi GHN hay AfterShip dựa theo
 * maTuyChonGiaoHang (code carrier đã lưu lúc đặt đơn), trả về format thống nhất
 * cho Controller — Controller/Frontend không cần biết chi tiết từng hãng.
 */
@Service
public class TrackingService {

    @Autowired private GhnApiService ghnApiService;
    @Autowired private AfterShipApiService afterShipApiService;

    public Optional<TrackingStatusDto> layTrangThai(Order order) {
        if (order.getMaVanDonNgoai() == null || order.getMaVanDonNgoai().isBlank()) {
            return Optional.empty(); // đơn nội thành xe shop, hoặc chưa bàn giao hãng nào
        }

        String carrierCode = order.getMaTuyChonGiaoHang();
        if ("ghn".equalsIgnoreCase(carrierCode)) {
            return layTuGhn(order);
        }
        if ("spx".equalsIgnoreCase(carrierCode) || "shopee_express".equalsIgnoreCase(carrierCode)) {
            return layTuAfterShip(order);
        }
        return Optional.empty(); // GHTK/Viettel Post trong docs bạn gửi không có API tracking riêng
    }

    private Optional<TrackingStatusDto> layTuGhn(Order order) {
        return ghnApiService.layChiTietDon(order.getMaVanDonNgoai())
                .map(data -> new TrackingStatusDto(
                        "ghn",
                        data.orderCode(),
                        ghnApiService.rutGonTrangThai(data.status()),
                        hienThi(ghnApiService.rutGonTrangThai(data.status())),
                        data.leadtime(),
                        mapGhnLog(data)
                ));
    }

    private Optional<TrackingStatusDto> layTuAfterShip(Order order) {
        if (order.getAfterShipTrackingId() == null) return Optional.empty();

        return afterShipApiService.layTracking(order.getAfterShipTrackingId())
                .map(t -> {
                    String trangThai = rutGonTrangThaiSpx(t.tag());
                    return new TrackingStatusDto(
                            "spx",
                            t.trackingNumber(),
                            trangThai,
                            hienThi(trangThai),
                            t.expectedDelivery(),
                            mapSpxCheckpoints(t)
                    );
                });
    }

    private List<TrackingEventDto> mapGhnLog(GhnOrderData data) {
        if (data.log() == null) return List.of();
        return data.log().stream()
                .map(l -> new TrackingEventDto(l.updatedDate(), hienThi(ghnApiService.rutGonTrangThai(l.status()))))
                .toList();
    }

    private List<TrackingEventDto> mapSpxCheckpoints(Tracking t) {
        if (t.checkpoints() == null) return List.of();
        return t.checkpoints().stream()
                .map(cp -> new TrackingEventDto(
                        cp.checkpointTime() != null ? cp.checkpointTime() : cp.createdAt(),
                        cp.message() != null ? cp.message() : cp.subtagMessage()))
                .toList();
    }

    /** AfterShip tag: Pending, InfoReceived, InTransit, OutForDelivery, AttemptFail, Delivered,
     * AvailableForPickup, Exception, Expired — rút gọn về cùng bộ enum với GHN. */
    private String rutGonTrangThaiSpx(String tag) {
        if (tag == null) return TrangThai.KHONG_XAC_DINH;
        return switch (tag) {
            case "Pending", "InfoReceived" -> TrangThai.CHO_LAY_HANG;
            case "InTransit" -> TrangThai.DANG_VAN_CHUYEN;
            case "OutForDelivery", "AvailableForPickup" -> TrangThai.DANG_GIAO;
            case "Delivered" -> TrangThai.DA_GIAO;
            case "AttemptFail", "Exception" -> TrangThai.HOAN_TRA;
            case "Expired" -> TrangThai.KHONG_XAC_DINH;
            default -> TrangThai.KHONG_XAC_DINH;
        };
    }

    private String hienThi(String trangThaiChung) {
        return switch (trangThaiChung) {
            case "cho_lay_hang"     -> "Chờ lấy hàng";
            case "dang_van_chuyen"  -> "Đang vận chuyển";
            case "dang_giao"        -> "Đang giao hàng";
            case "da_giao"          -> "Đã giao thành công";
            case "hoan_tra"         -> "Giao thất bại / Hoàn trả";
            case "da_huy"           -> "Đã huỷ";
            default                 -> "Không xác định";
        };
    }
}
