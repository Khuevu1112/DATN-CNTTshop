package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.UserAddress;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.UserAddressRepository;

@Service
public class AddressService {

    @Autowired
    private UserAddressRepository addressRepo;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

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
                             String diaChiCuThe, String tinhThanh, String quanHuyen,
                             String phuongXa, boolean isDefault) {
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
        address.setQuanHuyen(quanHuyen);
        address.setPhuongXa(phuongXa);

        List<UserAddress> existing = addressRepo.findByNguoiDung(user);
        address.setIsDefault(isDefault || existing.isEmpty());

        return addressRepo.save(address);
    }

    @Transactional
    public UserAddress sua(Integer id, String email, String tenNguoiNhan, String soDienThoai,
                            String diaChiCuThe, String tinhThanh, String quanHuyen,
                            String phuongXa, boolean isDefault) {
        UserAddress address = layTheoId(id, email);

        if (isDefault && !Boolean.TRUE.equals(address.getIsDefault())) {
            boThamChieuMacDinhCu(address.getNguoiDung());
        }

        address.setTenNguoiNhan(tenNguoiNhan);
        address.setSoDienThoai(soDienThoai);
        address.setDiaChiCuThe(diaChiCuThe);
        address.setTinhThanh(tinhThanh);
        address.setQuanHuyen(quanHuyen);
        address.setPhuongXa(phuongXa);
        address.setIsDefault(isDefault);

        return addressRepo.save(address);
    }

    @Transactional
    public void xoa(Integer id, String email) {
        UserAddress address = layTheoId(id, email);
        boolean wasDefault = Boolean.TRUE.equals(address.getIsDefault());
        NguoiDung user = address.getNguoiDung();

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