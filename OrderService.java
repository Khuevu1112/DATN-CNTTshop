package com.fpoly.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.Cart;
import com.fpoly.model.CartItem;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Payment;
import com.fpoly.model.PaymentMethod;
import com.fpoly.model.ProductVariant;
import com.fpoly.model.UserAddress;
import com.fpoly.repository.CartItemRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.OrderRepository;
import com.fpoly.repository.OrderStatusLogRepository;
import com.fpoly.repository.PaymentMethodRepository;
import com.fpoly.repository.PaymentRepository;
import com.fpoly.repository.UserAddressRepository;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepo;

    @Autowired
    private OrderStatusLogRepository statusLogRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private UserAddressRepository addressRepo;

    @Autowired
    private CartService cartService;

    @Autowired
    private CartItemRepository cartItemRepo;

    @Autowired
    private PaymentRepository paymentRepo;

    @Autowired
    private PaymentMethodRepository paymentMethodRepo;

    private static final BigDecimal PHI_VAN_CHUYEN_MAC_DINH = new BigDecimal("30000");

    @Transactional
    public Order datHangTuGioHang(String email, Integer addressId,Integer paymentMethodId) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        UserAddress address = addressRepo.findById(addressId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy địa chỉ giao hàng"));

        if (!address.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Địa chỉ giao hàng không hợp lệ");
        }

        Cart cart = cartService.layHoacTaoCart(email);
        List<CartItem> items = cartItemRepo.findByCart(cart);

        if (items.isEmpty()) {
            throw new RuntimeException("Giỏ hàng đang trống");
        }

        for (CartItem ci : items) {
            ProductVariant v = ci.getVariant();
            if (v.getStock() != null && v.getStock() < ci.getSoLuong()) {
                throw new RuntimeException("Sản phẩm \"" + v.getProduct().getName() + "\" không đủ hàng trong kho");
            }
        }

        BigDecimal tienHang = items.stream()
                .map(CartItem::getThanhTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal phiVanChuyen = PHI_VAN_CHUYEN_MAC_DINH;
        BigDecimal tongTien = tienHang.add(phiVanChuyen);

        Order order = new Order();
        order.setNguoiDung(user);
        order.setDiaChiGiao(address);
        order.setTienHang(tienHang);
        order.setTienGiamGia(BigDecimal.ZERO);
        order.setPhiVanChuyen(phiVanChuyen);
        order.setTongTien(tongTien);
        order.setTrangThai("pending");

        List<OrderItem> chiTiet = new ArrayList<>();
        for (CartItem ci : items) {
            ProductVariant v = ci.getVariant();

            OrderItem oi = new OrderItem();
            oi.setOrder(order);
            oi.setVariant(v);
            oi.setTenSanPham(v.getProduct().getName());
            oi.setThongTinPhienBan(v.getSku());
            oi.setDonGia(v.getPrice());
            oi.setSoLuong(ci.getSoLuong());

            chiTiet.add(oi);

            v.setStock(v.getStock() - ci.getSoLuong());
        }
        order.setChiTiet(chiTiet);

        Order saved = orderRepo.save(order);

        
        /* =====================
           TẠO PAYMENT
        ===================== */

        PaymentMethod paymentMethod =
                paymentMethodRepo.findById(paymentMethodId)
                .orElseThrow(() ->
                    new RuntimeException("Không tìm thấy phương thức thanh toán"));

        Payment payment = new Payment();

        payment.setOrder(saved);
        payment.setPaymentMethod(paymentMethod);
        payment.setAmount(saved.getTongTien());
        payment.setStatus("pending");

        paymentRepo.save(payment);

        /* =====================
           LOG TRẠNG THÁI
        ===================== */

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(saved);
        log.setTrangThai("pending");
        log.setGhiChu("Đơn hàng được tạo");

        statusLogRepo.save(log);

        cartItemRepo.deleteByCart(cart);

        return saved;
    }

    public List<Order> layDonHangCuaUser(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return orderRepo.findByNguoiDungOrderByCreatedAtDesc(user);
    }

    public Order layChiTietDon(Integer orderId, String email) {
        Order order = orderRepo.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));

        if (!order.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Bạn không có quyền xem đơn hàng này");
        }
        return order;
    }

    @Transactional
    public void huyDon(Integer orderId, String email) {
        Order order = layChiTietDon(orderId, email);

        Payment payment = paymentRepo.findByOrder(order).orElse(null);

        if (payment != null && "paid".equals(payment.getStatus())) {
            throw new RuntimeException(
                "Đơn hàng đã thanh toán, không thể hủy. Vui lòng liên hệ hỗ trợ."
            );
        }

        if (!"pending".equals(order.getTrangThai()) && !"confirmed".equals(order.getTrangThai())) {
            throw new RuntimeException("Đơn hàng đang ở trạng thái không thể hủy");
        }

        for (OrderItem oi : order.getChiTiet()) {
            ProductVariant v = oi.getVariant();
            v.setStock(v.getStock() + oi.getSoLuong());
        }

        order.setTrangThai("cancelled");
        
        orderRepo.save(order);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai("cancelled");
        log.setGhiChu("Khách hàng hủy đơn");
        statusLogRepo.save(log);
    }

    public List<Order> layTatCaDon() {
        return orderRepo.findAllByOrderByCreatedAtDesc();
    }

    public List<Order> layDonTheoTrangThai(String trangThai) {
        return orderRepo.findByTrangThaiOrderByCreatedAtDesc(trangThai);
    }

    public Order layDonById(Integer id) {
        return orderRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng #" + id));
    }

    @Transactional
    public void capNhatTrangThai(Integer orderId, String trangThaiMoi, String ghiChu) {
        Order order = layDonById(orderId);

        if ("cancelled".equals(order.getTrangThai()) || "delivered".equals(order.getTrangThai())) {
            throw new RuntimeException("Không thể thay đổi trạng thái của đơn hàng này");
        }

        if ("cancelled".equals(trangThaiMoi)) {
            for (OrderItem oi : order.getChiTiet()) {
                ProductVariant v = oi.getVariant();
                v.setStock(v.getStock() + oi.getSoLuong());
            }
        }

        order.setTrangThai(trangThaiMoi);
        orderRepo.save(order);

        OrderStatusLog log = new OrderStatusLog();
        log.setOrder(order);
        log.setTrangThai(trangThaiMoi);
        log.setGhiChu(ghiChu);
        statusLogRepo.save(log);
    }
}