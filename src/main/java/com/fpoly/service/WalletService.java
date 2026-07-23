package com.fpoly.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.Coupon;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.Wallet;
import com.fpoly.model.WalletTransaction;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.WalletRepository;
import com.fpoly.repository.WalletTransactionRepository;

/** Xu CT — kiếm được khi mua hàng, dùng để đổi coupon/quà trên trang khuyến mãi hoặc giảm
 * thẳng vào bill lúc thanh toán (xem RedemptionService/OrderService). */
@Service
public class WalletService {

    @Autowired
    private WalletRepository walletRepo;

    @Autowired
    private WalletTransactionRepository transactionRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    /** HAI tỉ giá TÁCH RỜI, cố ý khác nhau — đây là toàn bộ biên lợi nhuận của chương trình.
     *
     * Trước đây cả hai chiều dùng chung một hằng số với lập luận "1 xu luôn quy đổi thống nhất",
     * nhưng hệ quả là mua 25 triệu thì nhận lại xu trị giá đúng 25 triệu, tức hoàn tiền 100% và
     * mọi món hàng thực chất bán giảm nửa giá. Tỉ giá phải lệch nhau thì mới ra được tỉ lệ hoàn.
     *
     * Hiện tại: tiêu 10.000đ được 1 xu, 1 xu giảm được 1.000đ -> hoàn 10% giá trị đơn hàng.
     * Muốn đổi tỉ lệ hoàn thì sửa đúng 2 hằng số này (và chạy lại XuEconomyTest để thấy hệ quả
     * lên mốc hạng thành viên + giá quà đổi thưởng). */
    private static final BigDecimal VND_MOI_XU_KIEM = new BigDecimal("10000");
    private static final BigDecimal VND_MOI_XU_TIEU = new BigDecimal("1000");

    @Transactional
    public Wallet layHoacTaoVi(NguoiDung user) {
        return walletRepo.findByNguoiDung(user).orElseGet(() -> {
            Wallet w = new Wallet();
            w.setNguoiDung(user);
            w.setSoDuBac(0);
            return walletRepo.save(w);
        });
    }

    public Wallet layHoacTaoVi(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return layHoacTaoVi(user);
    }

    public List<WalletTransaction> layLichSuGiaoDich(Wallet wallet) {
        return transactionRepo.findByWalletOrderByCreatedAtDesc(wallet);
    }

    /** CHIỀU TIÊU: 1 xu giảm được bao nhiêu đồng vào bill (xem OrderService). */
    public BigDecimal quyDoiXuRaTien(int soXu) {
        return VND_MOI_XU_TIEU.multiply(BigDecimal.valueOf(soXu));
    }

    /** CHIỀU TIÊU, hướng ngược: muốn giảm ngần này tiền thì phải tiêu bao nhiêu xu. Tách khỏi
     * uocTinhXu() vì hai hàm này chạy hai tỉ giá khác nhau — dùng nhầm là sai tiền thật. */
    public int soXuDeGiam(BigDecimal soTien) {
        if (soTien == null || soTien.signum() <= 0) return 0;
        return soTien.divide(VND_MOI_XU_TIEU, 0, RoundingMode.DOWN).intValue();
    }

    /** Kiếm Xu CT từ 1 đơn hàng đã thanh toán — gọi từ OrderService khi payment chuyển sang
     * "paid" (banking/Stripe/VNPay xác nhận, hoặc COD giao hàng thành công). Tính trên số tiền
     * hàng khách THỰC TRẢ, tức đã trừ mọi giảm giá (hạng thành viên, coupon, xu) và không gồm
     * phí vận chuyển — trước đây tính trên tiền hàng gộp, nên khách Kim cương giảm 15% vẫn tích
     * xu như trả đủ, càng giảm sâu càng lệch. Có bảo vệ chống cộng trùng nếu bị gọi 2 lần cho
     * cùng 1 đơn (VD do webhook + return cùng xác nhận). */
    @Transactional
    public void congXuTuDon(Order order) {
        boolean daCong = transactionRepo.findByWalletOrderByCreatedAtDesc(
                layHoacTaoVi(order.getNguoiDung())).stream()
                .anyMatch(t -> "earn".equals(t.getLoaiGiaoDich())
                        && t.getDonHangLienQuan() != null
                        && t.getDonHangLienQuan().getId().equals(order.getId()));
        if (daCong) return;

        // Giảm giá của đơn có thể lớn hơn tiền hàng khi khách dùng xu/coupon phủ hết phần hàng
        // (phần dư coi như bù vào phí ship) — chặn ở 0 để không ra số xu âm.
        BigDecimal tienThucTra = order.getTienHang()
                .subtract(order.getTienGiamGia() == null ? BigDecimal.ZERO : order.getTienGiamGia())
                .max(BigDecimal.ZERO);
        int soXu = tienThucTra
                .divide(VND_MOI_XU_KIEM, 0, RoundingMode.DOWN)
                .intValue();
        if (soXu <= 0) return;

        Wallet wallet = layHoacTaoVi(order.getNguoiDung());
        wallet.setSoDuBac(wallet.getSoDuBac() + soXu);
        walletRepo.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setLoaiToken("silver");
        tx.setLoaiGiaoDich("earn");
        tx.setSoLuong(soXu);
        tx.setGhiChu("Tích lũy từ đơn hàng " + order.getMaDonHang());
        tx.setDonHangLienQuan(order);
        transactionRepo.save(tx);
    }

    /** CHIỀU KIẾM: số xu nhận được nếu chi tiêu đúng số tiền này — dùng để hiển thị ước tính ở
     * trang sản phẩm/giỏ hàng trước khi thực sự đặt hàng (xem thêm silverTokensFor() bên
     * cnttshop-vue/src/data/products.js, phải khớp công thức với hàm này). KHÔNG dùng hàm này
     * để quy tiền ngược thành xu lúc thanh toán — đó là chiều tiêu, xem soXuDeGiam(). */
    public int uocTinhXu(BigDecimal soTien) {
        if (soTien == null || soTien.signum() <= 0) return 0;
        return soTien.divide(VND_MOI_XU_KIEM, 0, RoundingMode.DOWN).intValue();
    }

    /** Trừ xu khi đổi quà vật lý trên trang khuyến mãi (xem RedemptionService.doiQua) — donHang
     * khác null vì luôn gắn với 1 đơn đổi quà cụ thể, để có thể hoàn lại nếu đơn đó bị huỷ. */
    @Transactional
    public void truXuDoiThuong(NguoiDung user, int soLuong, String ghiChu, Order donHang) {
        truXu(user, soLuong, "redeem", ghiChu, donHang, null);
    }

    /** Trừ xu khi đổi 1 mã coupon do admin tạo (xem RedemptionService.doiCoupon) — gắn
     * ref_coupon_id để hiển thị lại đúng mã đã đổi ở "Mã giảm giá của tôi" (AccountView). */
    @Transactional
    public void truXuDoiCoupon(NguoiDung user, int soLuong, String ghiChu, Coupon coupon) {
        truXu(user, soLuong, "redeem", ghiChu, null, coupon);
    }

    /** Trừ xu dùng trực tiếp giảm bill lúc thanh toán (xem OrderService.datHangTuGioHang) —
     * luôn gắn với đơn hàng vừa tạo, để hoàn lại nếu đơn bị huỷ/hết hạn trước khi thanh toán. */
    @Transactional
    public void chiXuTaiThanhToan(NguoiDung user, int soLuong, Order donHang) {
        truXu(user, soLuong, "spend", "Dùng xu giảm giá đơn " + donHang.getMaDonHang(), donHang, null);
    }

    private void truXu(NguoiDung user, int soLuong, String loaiGiaoDich, String ghiChu, Order donHang, Coupon coupon) {
        Wallet wallet = layHoacTaoVi(user);
        if (wallet.getSoDuBac() < soLuong) {
            throw new RuntimeException("Không đủ Xu CT");
        }
        wallet.setSoDuBac(wallet.getSoDuBac() - soLuong);
        walletRepo.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setLoaiToken("silver");
        tx.setLoaiGiaoDich(loaiGiaoDich);
        tx.setSoLuong(-soLuong);
        tx.setGhiChu(ghiChu);
        tx.setDonHangLienQuan(donHang);
        tx.setCouponLienQuan(coupon);
        transactionRepo.save(tx);
    }

    /** Đơn có gắn giao dịch trừ xu (đổi quà HOẶC dùng xu giảm bill lúc thanh toán) mà bị huỷ/hết
     * hạn -> hoàn lại đúng số xu đã trừ, không để khách mất xu mà không nhận được gì đổi lại.
     * Không làm gì nếu đơn này chưa từng có giao dịch trừ xu nào gắn với nó. */
    @Transactional
    public void hoanXuNeuDonBiHuy(Order order) {
        layLichSuGiaoDich(layHoacTaoVi(order.getNguoiDung())).stream()
                .filter(t -> ("redeem".equals(t.getLoaiGiaoDich()) || "spend".equals(t.getLoaiGiaoDich()))
                        && t.getDonHangLienQuan() != null
                        && t.getDonHangLienQuan().getId().equals(order.getId()))
                .forEach(t -> {
                    int soHoan = -t.getSoLuong();
                    Wallet wallet = layHoacTaoVi(order.getNguoiDung());
                    wallet.setSoDuBac(wallet.getSoDuBac() + soHoan);
                    walletRepo.save(wallet);

                    WalletTransaction hoanTra = new WalletTransaction();
                    hoanTra.setWallet(wallet);
                    hoanTra.setLoaiToken("silver");
                    hoanTra.setLoaiGiaoDich("adjust");
                    hoanTra.setSoLuong(soHoan);
                    hoanTra.setGhiChu("Hoàn xu do đơn " + order.getMaDonHang() + " bị huỷ");
                    hoanTra.setDonHangLienQuan(order);
                    transactionRepo.save(hoanTra);
                });
    }

    /** Cộng xu trực tiếp (điểm danh, xem CheckinService) — không gắn với đơn hàng nào. */
    @Transactional
    public void congXu(NguoiDung user, int soLuong, String ghiChu) {
        Wallet wallet = layHoacTaoVi(user);
        wallet.setSoDuBac(wallet.getSoDuBac() + soLuong);
        walletRepo.save(wallet);

        WalletTransaction tx = new WalletTransaction();
        tx.setWallet(wallet);
        tx.setLoaiToken("silver");
        tx.setLoaiGiaoDich("earn");
        tx.setSoLuong(soLuong);
        tx.setGhiChu(ghiChu);
        transactionRepo.save(tx);
    }
}
