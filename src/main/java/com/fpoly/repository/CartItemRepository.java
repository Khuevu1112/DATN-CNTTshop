package com.fpoly.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.fpoly.model.Cart;
import com.fpoly.model.CartItem;
import com.fpoly.model.ProductVariant;

public interface CartItemRepository extends JpaRepository<CartItem, Integer> {

    List<CartItem> findByCart(Cart cart);

    Optional<CartItem> findByCartAndVariant(Cart cart, ProductVariant variant);

    void deleteByCart(Cart cart);
}