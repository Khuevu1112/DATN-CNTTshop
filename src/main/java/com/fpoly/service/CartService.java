package com.fpoly.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.Cart;
import com.fpoly.model.CartItem;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.ProductVariant;
import com.fpoly.repository.CartItemRepository;
import com.fpoly.repository.CartRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ProductVariantRepository;

@Service
public class CartService {

    @Autowired
    private CartRepository cartRepo;

    @Autowired
    private CartItemRepository cartItemRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private ProductVariantRepository variantRepo;

    @Transactional
    public Cart layHoacTaoCart(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        return cartRepo.findByNguoiDung(user).orElseGet(() -> {
            Cart cart = new Cart();
            cart.setNguoiDung(user);
            return cartRepo.save(cart);
        });
    }

    public List<CartItem> layDanhSachItem(String email) {
        Cart cart = layHoacTaoCart(email);
        return cartItemRepo.findByCart(cart);
    }

    public BigDecimal tinhTongTien(String email) {
        return layDanhSachItem(email).stream()
                .map(CartItem::getThanhTien)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public int demSoLuongItem(String email) {
        return layDanhSachItem(email).size();
    }

    @Transactional
    public void themVaoGio(String email, Integer variantId, Integer soLuong) {
        Cart cart = layHoacTaoCart(email);

        ProductVariant variant = variantRepo.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể sản phẩm"));

        if (variant.getStock() != null && variant.getStock() < soLuong) {
            throw new RuntimeException("Số lượng trong kho không đủ");
        }

        CartItem item = cartItemRepo.findByCartAndVariant(cart, variant).orElse(null);

        if (item != null) {
            int tongMoi = item.getSoLuong() + soLuong;
            if (variant.getStock() != null && variant.getStock() < tongMoi) {
                throw new RuntimeException("Số lượng trong kho không đủ");
            }
            item.setSoLuong(tongMoi);
        } else {
            item = new CartItem();
            item.setCart(cart);
            item.setVariant(variant);
            item.setSoLuong(soLuong);
        }

        cartItemRepo.save(item);
    }

    @Transactional
    public void capNhatSoLuong(String email, Integer itemId, Integer soLuongMoi) {
        CartItem item = layItemCuaUser(itemId, email);

        if (soLuongMoi <= 0) {
            cartItemRepo.delete(item);
            return;
        }

        ProductVariant variant = item.getVariant();
        if (variant.getStock() != null && variant.getStock() < soLuongMoi) {
            throw new RuntimeException("Số lượng trong kho không đủ");
        }

        item.setSoLuong(soLuongMoi);
        cartItemRepo.save(item);
    }

    @Transactional
    public void xoaItem(String email, Integer itemId) {
        CartItem item = layItemCuaUser(itemId, email);
        cartItemRepo.delete(item);
    }

    @Transactional
    public void xoaToanBoCart(String email) {
        Cart cart = layHoacTaoCart(email);
        cartItemRepo.deleteByCart(cart);
    }

    private CartItem layItemCuaUser(Integer itemId, String email) {
        CartItem item = cartItemRepo.findById(itemId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm trong giỏ"));

        if (!item.getCart().getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Bạn không có quyền thao tác với giỏ hàng này");
        }
        return item;
    }
}