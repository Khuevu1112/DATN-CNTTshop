package com.fpoly.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * DTO cho AfterShip Shopee Express Tracking API.
 * Chỉ map field thực sự dùng — AfterShip trả về ~70 field/tracking, phần lớn không cần cho
 * trang "Theo dõi đơn hàng" của khách/admin.
 */
public class AfterShipDtos {

    // ---------------------------------------------------------------
    //  Create tracking — POST /trackings
    // ---------------------------------------------------------------

    public record CreateTrackingBody(TrackingInput tracking) {}

    /** slug cố định "spx" cho Shopee Express — theo docs bạn gửi. */
    public record TrackingInput(
            String slug,
            @JsonProperty("tracking_number") String trackingNumber,
            String title,
            @JsonProperty("order_id") String orderId,
            @JsonProperty("order_promised_delivery_date") String orderPromisedDeliveryDate
    ) {
        public TrackingInput(String trackingNumber, String title, String orderId) {
            this("spx", trackingNumber, title, orderId, null);
        }
    }

    // ---------------------------------------------------------------
    //  Response (dùng chung cho create/get/update)
    // ---------------------------------------------------------------

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record AfterShipResponse(Meta meta, TrackingData data) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Meta(int code, String type, String message) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record TrackingData(Tracking tracking) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Tracking(
            String id,
            String tag,              // Pending, InfoReceived, InTransit, OutForDelivery,
                                      // AttemptFail, Delivered, AvailableForPickup, Exception, Expired
            String subtag,
            @JsonProperty("subtag_message") String subtagMessage,
            @JsonProperty("tracking_number") String trackingNumber,
            @JsonProperty("order_id") String orderId,
            @JsonProperty("expected_delivery") String expectedDelivery,
            List<Checkpoint> checkpoints
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Checkpoint(
            String tag,
            String subtag,
            @JsonProperty("subtag_message") String subtagMessage,
            String message,
            String city,
            String state,
            @JsonProperty("checkpoint_time") String checkpointTime,
            @JsonProperty("created_at") String createdAt
    ) {}

    // ---------------------------------------------------------------
    //  Update tracking — PUT /trackings/{id}
    // ---------------------------------------------------------------

    public record UpdateTrackingBody(UpdateFields tracking) {}

    public record UpdateFields(String title, String note) {}

    // ---------------------------------------------------------------
    //  Mark as completed — POST /trackings/{id}/mark-as-completed
    // ---------------------------------------------------------------

    public record MarkCompletedBody(String reason) {}  // DELIVERED | LOST | RETURNED_TO_SENDER
}
