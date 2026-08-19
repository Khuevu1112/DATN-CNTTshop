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

    /** Số lượng tối thiểu mỗi dòng giỏ hàng. Không có chốt này thì client gọi thẳng API với
     * quantity = 0 (dòng rác, tính tiền 0đ) hoặc số ÂM (thành tiền âm, kéo tổng đơn xuống —
     * tức là được trả tiền để lấy hàng). */
    public static final int SO_LUONG_TOI_THIEU = 1;

    /** Trần mỗi dòng. Shop bán lẻ; đơn số lượng lớn đi qua kênh báo giá doanh nghiệp, không đặt
     * thẳng trên web. Cũng chặn luôn kiểu nghịch nhập 999999 làm vỡ hiển thị/tính tiền. */
    public static final int SO_LUONG_TOI_DA = 20;

    /** Kiểm số lượng khách gửi lên trước khi đụng tới kho. Trả về số đã chuẩn hoá. */
    private int kiemTraSoLuong(Integer soLuong) {
        int sl = soLuong == null ? SO_LUONG_TOI_THIEU : soLuong;
        if (sl < SO_LUONG_TOI_THIEU) {
            throw new RuntimeException("Số lượng phải từ " + SO_LUONG_TOI_THIEU + " trở lên");
        }
        if (sl > SO_LUONG_TOI_DA) {
            throw new RuntimeException("Mỗi sản phẩm chỉ đặt tối đa " + SO_LUONG_TOI_DA
                    + " cái/đơn. Cần số lượng lớn hơn, vui lòng liên hệ 0835 344 974 để được báo giá.");
        }
        return sl;
    }

    /** Kiểm tồn kho, phân biệt rõ "hết sạch" với "còn nhưng không đủ" — hai tình huống khách
     * phải xử lý khác nhau (bỏ khỏi giỏ vs giảm số lượng). */
    private void kiemTraTonKho(ProductVariant variant, int soLuongCan) {
        Integer ton = variant.getStock();
        if (ton == null) return; // biến thể không quản lý tồn
        String ten = variant.getProduct() != null ? variant.getProduct().getName() : "Sản phẩm";
        if (ton <= 0) {
            throw new RuntimeException("\"" + ten + "\" đang tạm hết hàng.");
        }
        if (ton < soLuongCan) {
            throw new RuntimeException("\"" + ten + "\" chỉ còn " + ton + " cái, không đủ số lượng bạn chọn.");
        }
    }

    @Transactional
    public void themVaoGio(String email, Integer variantId, Integer soLuong) {
        int sl = kiemTraSoLuong(soLuong);
        Cart cart = layHoacTaoCart(email);

        ProductVariant variant = variantRepo.findById(variantId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy biến thể sản phẩm"));

        kiemTraTonKho(variant, sl);

        CartItem item = cartItemRepo.findByCartAndVariant(cart, variant).orElse(null);

        if (item != null) {
            // Cộng dồn phải kiểm lại CẢ hai chốt trên tổng mới, không chỉ trên phần thêm vào.
            int tongMoi = kiemTraSoLuong(item.getSoLuong() + sl);
            kiemTraTonKho(variant, tongMoi);
            item.setSoLuong(tongMoi);
        } else {
            item = new CartItem();
            item.setCart(cart);
            item.setVariant(variant);
            item.setSoLuong(sl);
        }

        cartItemRepo.save(item);
    }

    /**
     * Đặt lại số lượng của 1 dòng giỏ hàng.
     *
     * KHÔNG còn coi "số lượng <= 0" là lệnh xoá dòng như trước: xoá là hành động riêng
     * (xoaItem / DELETE /api/cart/items/{id}), gộp vào đây thì một lỗi client gửi nhầm số 0 sẽ
     * âm thầm xoá hàng khách đã chọn mà không ai biết. Nay báo lỗi rõ ràng.
     */
    @Transactional
    public void capNhatSoLuong(String email, Integer itemId, Integer soLuongMoi) {
        int sl = kiemTraSoLuong(soLuongMoi);
        CartItem item = layItemCuaUser(itemId, email);

        kiemTraTonKho(item.getVariant(), sl);

        item.setSoLuong(sl);
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