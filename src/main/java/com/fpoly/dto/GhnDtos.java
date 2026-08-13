package com.fpoly.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * DTO cho GHN POST /shiip/public-api/v2/shipping-order/detail
 * Chỉ map các field thật sự dùng để hiển thị tracking cho khách/admin — GHN trả về rất nhiều
 * field nội bộ (id kho, ip, nhân viên...) không cần thiết cho use case này.
 */
public class GhnDtos {

    public record GhnOrderDetailRequest(
            @JsonProperty("order_code") String orderCode
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record GhnOrderDetailResponse(
            int code,
            String message,
            GhnOrderData data
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record GhnOrderData(
            @JsonProperty("order_code")   String orderCode,
            String status,
            @JsonProperty("to_name")      String toName,
            @JsonProperty("to_address")   String toAddress,
            @JsonProperty("to_phone")     String toPhone,
            @JsonProperty("cod_amount")   long codAmount,
            @JsonProperty("leadtime")     String leadtime,       // hạn giao dự kiến (ISO string)
            @JsonProperty("order_date")   String orderDate,
            @JsonProperty("finish_date")  String finishDate,
            List<GhnLog> log
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record GhnLog(
            String status,
            @JsonProperty("updated_date") String updatedDate
    ) {}
}
