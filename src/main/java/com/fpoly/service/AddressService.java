package com.fpoly.service;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.Province;
import com.fpoly.model.UserAddress;
import com.fpoly.model.Ward;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.ProvinceRepository;
import com.fpoly.repository.UserAddressRepository;
import com.fpoly.repository.WardRepository;

@Service
public class AddressService {

    @Autowired
    private UserAddressRepository addressRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private ProvinceRepository provinceRepo;

    @Autowired
    private WardRepository wardRepo;

    @Autowired
    private com.fpoly.repository.OrderRepository orderRepo;

    public List<UserAddress> layDanhSachTheoEmail(String email) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        return addressRepo.findByNguoiDung(user);
    }

    public UserAddress layTheoId(Integer id, String email) {
        UserAddress address = addressRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy địa chỉ"));
        if (!address.getNguoiDung().getEmail().equals(email)) {
            throw new RuntimeException("Bạn không có quyền truy cập địa chỉ này");
        }
        return address;
    }

    @Transactional
    public UserAddress them(String email, String tenNguoiNhan, String soDienThoai,
                             String diaChiCuThe, String tinhThanh, String phuongXa,
                             Double latitude, Double longitude, boolean isDefault) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));

        if (isDefault) {
            boThamChieuMacDinhCu(user);
        }

        UserAddress address = new UserAddress();
        address.setNguoiDung(user);
        address.setTenNguoiNhan(tenNguoiNhan);
        address.setSoDienThoai(soDienThoai);
        address.setDiaChiCuThe(diaChiCuThe);
        address.setTinhThanh(tinhThanh);
        address.setPhuongXa(phuongXa);
        address.setLatitude(latitude != null ? BigDecimal.valueOf(latitude) : null);
        address.setLongitude(longitude != null ? BigDecimal.valueOf(longitude) : null);

        List<UserAddress> existing = addressRepo.findByNguoiDung(user);
        address.setIsDefault(isDefault || existing.isEmpty());

        return addressRepo.save(address);
    }

    @Transactional
    public UserAddress sua(Integer id, String email, String tenNguoiNhan, String soDienThoai,
                            String diaChiCuThe, String tinhThanh, String phuongXa,
                            Double latitude, Double longitude, boolean isDefault) {
        UserAddress address = layTheoId(id, email);

        if (isDefault && !Boolean.TRUE.equals(address.getIsDefault())) {
            boThamChieuMacDinhCu(address.getNguoiDung());
        }

        address.setTenNguoiNhan(tenNguoiNhan);
        address.setSoDienThoai(soDienThoai);
        address.setDiaChiCuThe(diaChiCuThe);
        address.setTinhThanh(tinhThanh);
        address.setPhuongXa(phuongXa);
        address.setLatitude(latitude != null ? BigDecimal.valueOf(latitude) : null);
        address.setLongitude(longitude != null ? BigDecimal.valueOf(longitude) : null);
        address.setIsDefault(isDefault);

        return addressRepo.save(address);
    }

    /** Tạo địa chỉ qua dropdown Tỉnh/Phường chuẩn hoá (cnttshop-vue) — ghi đồng thời province/ward
     * (FK, dùng để tính phí ship) lẫn cột text cũ tinhThanh/phuongXa (lấy từ tên Tỉnh/Phường vừa
     * chọn) để tương thích ngược với mọi chỗ đang đọc getTinhThanh()/getPhuongXa()/getDiaChiDayDu(). */
    @Transactional
    public UserAddress themTheoDiaDanh(String email, String tenNguoiNhan, String soDienThoai,
                                        String diaChiCuThe, Integer provinceId, Integer wardId, boolean isDefault,
                                        BigDecimal latitude, BigDecimal longitude) {
        NguoiDung user = nguoiDungRepo.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng"));
        Ward ward = layWardHopLe(provinceId, wardId);
        kiemTraToaDo(latitude, longitude);

        if (isDefault) {
            boThamChieuMacDinhCu(user);
        }

        UserAddress address = new UserAddress();
        address.setNguoiDung(user);
        address.setTenNguoiNhan(tenNguoiNhan);
        address.setSoDienThoai(soDienThoai);
        address.setDiaChiCuThe(diaChiCuThe);
        address.setProvince(ward.getProvince());
        address.setWard(ward);
        address.setTinhThanh(ward.getProvince().getName());
        address.setPhuongXa(ward.getName());
        address.setLatitude(latitude);
        address.setLongitude(longitude);

        List<UserAddress> existing = addressRepo.findByNguoiDung(user);
        address.setIsDefault(isDefault || existing.isEmpty());

        return addressRepo.save(address);
    }

    @Transactional
    public UserAddress suaTheoDiaDanh(Integer id, String email, String tenNguoiNhan, String soDienThoai,
                                       String diaChiCuThe, Integer provinceId, Integer wardId, boolean isDefault,
                                       BigDecimal latitude, BigDecimal longitude) {
        UserAddress address = layTheoId(id, email);
        Ward ward = layWardHopLe(provinceId, wardId);
        kiemTraToaDo(latitude, longitude);

        if (isDefault && !Boolean.TRUE.equals(address.getIsDefault())) {
            boThamChieuMacDinhCu(address.getNguoiDung());
        }

        address.setTenNguoiNhan(tenNguoiNhan);
        address.setSoDienThoai(soDienThoai);
        address.setDiaChiCuThe(diaChiCuThe);
        address.setProvince(ward.getProvince());
        address.setWard(ward);
        address.setTinhThanh(ward.getProvince().getName());
        address.setPhuongXa(ward.getName());
        address.setLatitude(latitude);
        address.setLongitude(longitude);
        address.setIsDefault(isDefault);

        return addressRepo.save(address);
    }

    // Khung toạ độ Việt Nam (rộng rãi) — chặn toạ độ rác/nhầm thứ tự lat-lng ngay ở cửa vào,
    // vì sai lệch chỉ lộ ra sau đó ở phí ship hoặc khi shipper tới nhầm nơi.
    private static final BigDecimal VI_DO_MIN = new BigDecimal("8.0");
    private static final BigDecimal VI_DO_MAX = new BigDecimal("23.5");
    private static final BigDecimal KINH_DO_MIN = new BigDecimal("102.0");
    private static final BigDecimal KINH_DO_MAX = new BigDecimal("110.0");

    /** Cắm mốc là BẮT BUỘC với địa chỉ tạo/sửa qua cnttshop-vue — phí giao nội thành Hải Phòng
     * tính theo quãng đường từ kho tới điểm cắm (xem ShippingService), không có toạ độ thì không
     * ra được phí đúng. Địa chỉ cũ tạo trước tính năng này vẫn để trống và dùng bảng phí phẳng. */
    private void kiemTraToaDo(BigDecimal latitude, BigDecimal longitude) {
        if (latitude == null || longitude == null) {
            throw new RuntimeException("Vui lòng cắm mốc vị trí giao hàng trên bản đồ");
        }
        if (latitude.compareTo(VI_DO_MIN) < 0 || latitude.compareTo(VI_DO_MAX) > 0
                || longitude.compareTo(KINH_DO_MIN) < 0 || longitude.compareTo(KINH_DO_MAX) > 0) {
            throw new RuntimeException("Vị trí đã cắm nằm ngoài lãnh thổ Việt Nam, vui lòng cắm lại");
        }
    }

    private Ward layWardHopLe(Integer provinceId, Integer wardId) {
        Ward ward = wardRepo.findById(wardId)
                .orElseThrow(() -> new RuntimeException("Phường/Xã không hợp lệ"));
        if (!ward.getProvince().getId().equals(provinceId)) {
            throw new RuntimeException("Phường/Xã không thuộc Tỉnh/Thành đã chọn");
        }
        return ward;
    }

    /**
     * Xoá địa chỉ khỏi sổ địa chỉ.
     *
     * ORDER.address_id là FK trỏ vào đây, nên xoá thẳng sẽ vỡ ràng buộc khoá ngoại với bất kỳ
     * địa chỉ nào đã từng dùng để đặt đơn — khách chỉ nhận được "Xoá địa chỉ thất bại" và không
     * bao giờ xoá được. Xử lý: chụp lại text địa chỉ vào các đơn cũ (nếu đơn tạo trước
     * 81_order_address_snapshot.sql nên còn trống) rồi gỡ FK về NULL. Đơn vẫn hiển thị đúng
     * địa chỉ đã giao vì từ nay mọi nơi đọc qua Order.getDiaChiNhanHangHienThi().
     */
    @Transactional
    public void xoa(Integer id, String email) {
        UserAddress address = layTheoId(id, email);
        boolean wasDefault = Boolean.TRUE.equals(address.getIsDefault());
        NguoiDung user = address.getNguoiDung();

        for (com.fpoly.model.Order o : orderRepo.findByDiaChiGiao(address)) {
            if (o.getDiaChiNhanHang() == null || o.getDiaChiNhanHang().isBlank()) {
                o.chupLaiDiaChi(address);
            }
            o.setDiaChiGiao(null);
            // saveAndFlush chứ không phải save: lệnh UPDATE gỡ FK phải xuống CSDL TRƯỚC lệnh
            // DELETE bên dưới, nếu không vẫn vỡ ràng buộc khoá ngoại.
            orderRepo.saveAndFlush(o);
        }

        addressRepo.delete(address);

        if (wasDefault) {
            List<UserAddress> remaining = addressRepo.findByNguoiDung(user);
            if (!remaining.isEmpty()) {
                UserAddress first = remaining.get(0);
                first.setIsDefault(true);
                addressRepo.save(first);
            }
        }
    }

    @Transactional
    public void datLamMacDinh(Integer id, String email) {
        UserAddress address = layTheoId(id, email);
        boThamChieuMacDinhCu(address.getNguoiDung());
        address.setIsDefault(true);
        addressRepo.save(address);
    }

    private void boThamChieuMacDinhCu(NguoiDung user) {
        addressRepo.findByNguoiDungAndIsDefaultTrue(user).ifPresent(old -> {
            old.setIsDefault(false);
            addressRepo.save(old);
        });
    }
}