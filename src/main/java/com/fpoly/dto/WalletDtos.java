package com.fpoly.dto;

import java.time.LocalDateTime;

public class WalletDtos {

    public record WalletDto(Integer balance) {}

    public record WalletTransactionDto(
            Integer id, String tokenType, String type, Integer amount, String note, LocalDateTime createdAt
    ) {}
}
