package com.fpoly.service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Client gọi Anthropic Claude API (endpoint /v1/messages), dùng cho tính năng "AI Phân tích".
 * Tách riêng khỏi AiInsightService để dễ tái sử dụng nếu sau này có thêm tính năng AI khác
 * (VD: chatbox hỏi-đáp ở đợt sau).
 */
@Service
public class AnthropicClient {

    @Value("${anthropic.api.key:}")
    private String apiKey;

    @Value("${anthropic.api.model:claude-sonnet-4-6}")
    private String model;

    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    private final ObjectMapper mapper = new ObjectMapper();

    public boolean daCauHinh() {
        return apiKey != null && !apiKey.isBlank();
    }

    /** Gửi 1 lượt hỏi-đáp đơn giản (không giữ lịch sử hội thoại) tới Claude, trả về text thuần. */
    public String hoi(String systemPrompt, String userPrompt) {
        if (!daCauHinh()) {
            throw new IllegalStateException(
                    "Chưa cấu hình ANTHROPIC_API_KEY — thêm biến môi trường ANTHROPIC_API_KEY rồi khởi động lại server.");
        }
        try {
            Map<String, Object> body = Map.of(
                    "model", model,
                    "max_tokens", 1024,
                    "system", systemPrompt,
                    "messages", List.of(Map.of("role", "user", "content", userPrompt))
            );

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.anthropic.com/v1/messages"))
                    .header("content-type", "application/json")
                    .header("x-api-key", apiKey)
                    .header("anthropic-version", "2023-06-01")
                    .timeout(Duration.ofSeconds(30))
                    .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(body)))
                    .build();

            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());
            JsonNode root = mapper.readTree(response.body());

            if (response.statusCode() != 200) {
                String loi = root.path("error").path("message").asText("Lỗi không xác định từ Anthropic API");
                throw new RuntimeException("Anthropic API lỗi (" + response.statusCode() + "): " + loi);
            }

            JsonNode contentArr = root.path("content");
            StringBuilder text = new StringBuilder();
            for (JsonNode block : contentArr) {
                if ("text".equals(block.path("type").asText())) {
                    text.append(block.path("text").asText());
                }
            }
            return text.toString().trim();
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Không gọi được Anthropic API: " + e.getMessage(), e);
        }
    }
}
