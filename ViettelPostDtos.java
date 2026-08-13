package com.fpoly.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DTO cho Viettel Post POST /v2/order/getPrice
 * Docs: mục "Tính cước sử dụng địa chỉ ID"
 */
public class ViettelPostDtos {

    // Request body gửi lên VTP — field names giữ UPPERCASE khớp docs, không đổi format JSON.
    public record VtpPriceRequest(
            @JsonProperty("PRODUCT_WEIGHT")     long productWeight,   // gram
            @JsonProperty("PRODUCT_PRICE")      long productPrice,    // VNĐ
            @JsonProperty("MONEY_COLLECTION")   long moneyCollection, // COD, 0 nếu không thu hộ
            @JsonProperty("ORDER_SERVICE")      String orderService,
            @JsonProperty("ORDER_SERVICE_ADD")  String orderServiceAdd,
            @JsonProperty("SENDER_DISTRICT")    Long senderDistrict,
            @JsonProperty("SENDER_PROVINCE")    Long senderProvince,
            @JsonProperty("SENDER_WARD")        Long senderWard,
            @JsonProperty("RECEIVER_DISTRICT")  Long receiverDistrict,
            @JsonProperty("RECEIVER_PROVINCE")  Long receiverProvince,
            @JsonProperty("RECEIVER_WARD")      Long receiverWard,
            @JsonProperty("PRODUCT_LENGTH")     int productLength,
            @JsonProperty("PRODUCT_WIDTH")      int productWidth,
            @JsonProperty("PRODUCT_HEIGHT")     int productHeight,
            @JsonProperty("PRODUCT_TYPE")       String productType,   // "HH" = hàng hoá
            @JsonProperty("NATIONAL_TYPE")      int nationalType      // 1 = trong nước
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record VtpPriceResponse(
            int status,
            boolean error,
            String message,
            VtpPriceData data
    ) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record VtpPriceData(
            @JsonProperty("MONEY_TOTAL")           long moneyTotal,       // tổng cước
            @JsonProperty("MONEY_TOTAL_FEE")       long moneyTotalFee,    // cước dịch vụ chính
            @JsonProperty("MONEY_FEE")             long moneyFee,         // phụ phí xăng dầu
            @JsonProperty("MONEY_COLLECTION_FEE")  long moneyCollectionFee,
            @JsonProperty("MONEY_OTHER_FEE")       long moneyOtherFee,
            @JsonProperty("MONEY_VAT")             long moneyVat,
            @JsonProperty("KPI_HT")                Double kpiHt          // tổng thời gian giao (giờ)
    ) {}
}
