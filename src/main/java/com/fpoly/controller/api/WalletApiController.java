package com.fpoly.controller.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.WalletDtos.WalletDto;
import com.fpoly.dto.WalletDtos.WalletTransactionDto;
import com.fpoly.model.Wallet;
import com.fpoly.service.WalletService;

/** Xu CT — số dư + sổ giao dịch. */
@RestController
@RequestMapping("/api/wallet")
public class WalletApiController {

    @Autowired
    private WalletService walletService;

    @GetMapping
    public WalletDto balance(Authentication auth) {
        Wallet w = walletService.layHoacTaoVi(auth.getName());
        return new WalletDto(w.getSoDuBac());
    }

    @GetMapping("/transactions")
    public List<WalletTransactionDto> transactions(Authentication auth) {
        Wallet w = walletService.layHoacTaoVi(auth.getName());
        return walletService.layLichSuGiaoDich(w).stream()
                .map(t -> new WalletTransactionDto(
                        t.getId(), t.getLoaiToken(), t.getLoaiGiaoDich(), t.getSoLuong(), t.getGhiChu(), t.getCreatedAt()))
                .toList();
    }
}
