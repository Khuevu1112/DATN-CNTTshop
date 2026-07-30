package com.fpoly.service;

import com.fpoly.dto.ShippingFeeResponse;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;


@Service
public class ShippingService {

    // ĐIỀN THÔNG TIN TÀI KHOẢN GHTK VÀO ĐÂY
    private final String API_TOKEN = "MÃ_TOKEN_CỦA_BẠN"; 
    private final String PARTNER_CODE = "MÃ_ĐỐI_TÁC_CỦA_BẠN";
    private final String BASE_URL = "https://services.ghtk.vn/services/shipment/fee";

    public ShippingFeeResponse calculateShippingFee(String pickProvince, String pickWard, 
                                                    String province, String ward, int weight) {
        
        RestTemplate restTemplate = new RestTemplate();
        
        HttpHeaders headers = new HttpHeaders();
        headers.set("Token", API_TOKEN);
        headers.set("X-Client-Source", PARTNER_CODE);

        String urlTemplate = UriComponentsBuilder.fromUriString(BASE_URL)
                .queryParam("pick_province", pickProvince)
                .queryParam("pick_ward", pickWard)
                .queryParam("province", province)
                .queryParam("ward", ward)
                .queryParam("weight", weight)
                .encode()
                .toUriString();

        HttpEntity<?> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<ShippingFeeResponse> response = restTemplate.exchange(
                    urlTemplate, 
                    HttpMethod.GET, 
                    entity, 
                    ShippingFeeResponse.class
            );
            return response.getBody();
        } catch (Exception e) {
            System.err.println("Lỗi gọi API tính phí: " + e.getMessage());
            return null;
        }
    }
}