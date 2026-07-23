package com.fpoly.service;

import java.time.LocalDate;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.dto.CheckinDtos.CheckinResultDto;
import com.fpoly.dto.CheckinDtos.CheckinStatusDto;
import com.fpoly.model.CheckinLog;
import com.fpoly.model.NguoiDung;
import com.fpoly.repository.CheckinLogRepository;
import com.fpoly.repository.NguoiDungRepository;

/** Điểm danh định kỳ (trang khuyến mãi) — thưởng Xu CT tăng dần theo chu kỳ 7 ngày liên
 * tiếp, kiểu Shopee. Bỏ lỡ 1 ngày thì chuỗi ngày reset về 1. */
@Service
public class CheckinService {

    @Autowired
    private CheckinLogRepository checkinRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private WalletService walletService;

    /** Thưởng Xu CT theo ngày thứ mấy trong chu kỳ 7 ngày (index 0 = ngày 1). */
    private static final int[] THUONG_THEO_NGAY = { 5, 5, 10, 10, 15, 15, 50 };

    private int thuongChoStreak(int streak) {
        return THUONG_THEO_NGAY[(streak - 1) % THUONG_THEO_NGAY.length];
    }

    private NguoiDung layUser(String email) {
        return nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
    }

    /** Chuỗi ngày hiện tại NẾU điểm danh hôm nay — dựa vào lần điểm danh gần nhất: hôm qua ->
     * nối chuỗi (+1), hôm nay -> đã điểm danh rồi (giữ nguyên), còn lại -> chuỗi mới (= 1). */
    private int tinhStreakTiepTheo(NguoiDung user) {
        Optional<CheckinLog> ganDay = checkinRepo.findTopByNguoiDungOrderByNgayDiemDanhDesc(user);
        if (ganDay.isEmpty()) return 1;

        LocalDate ngayGanDay = ganDay.get().getNgayDiemDanh();
        LocalDate homNay = LocalDate.now();
        if (ngayGanDay.equals(homNay)) return ganDay.get().getSoNgayLienTiep();
        if (ngayGanDay.equals(homNay.minusDays(1))) return ganDay.get().getSoNgayLienTiep() + 1;
        return 1;
    }

    public CheckinStatusDto trangThaiHomNay(String email) {
        NguoiDung user = layUser(email);
        boolean daDiemDanh = checkinRepo.findByNguoiDungAndNgayDiemDanh(user, LocalDate.now()).isPresent();
        int streakTiepTheo = tinhStreakTiepTheo(user);
        return new CheckinStatusDto(
                daDiemDanh, streakTiepTheo, thuongChoStreak(streakTiepTheo), THUONG_THEO_NGAY
        );
    }

    @Transactional
    public CheckinResultDto diemDanh(String email) {
        NguoiDung user = layUser(email);
        LocalDate homNay = LocalDate.now();

        if (checkinRepo.findByNguoiDungAndNgayDiemDanh(user, homNay).isPresent()) {
            throw new RuntimeException("Bạn đã điểm danh hôm nay rồi");
        }

        int streak = tinhStreakTiepTheo(user);
        int thuong = thuongChoStreak(streak);

        CheckinLog log = new CheckinLog();
        log.setNguoiDung(user);
        log.setNgayDiemDanh(homNay);
        log.setSoNgayLienTiep(streak);
        log.setThuongTokenBac(thuong);
        checkinRepo.save(log);

        walletService.congXu(user, thuong, "Điểm danh ngày thứ " + streak);

        return new CheckinResultDto(streak, thuong);
    }
}
