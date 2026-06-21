package com.fpoly.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import com.fpoly.model.NguoiDung;
import com.fpoly.repository.NguoiDungRepository;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private NguoiDungRepository repo;

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        NguoiDung user = repo.findByEmail(username)
                .or(() -> repo.findBySoDienThoai(username))
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "Không tìm thấy tài khoản"
                        )
                );

        if (Boolean.FALSE.equals(user.getIsActive())) {
            throw new UsernameNotFoundException(
                    "Tài khoản đã bị khóa"
            );
        }

        return new User(
                user.getEmail(),
                user.getMatKhau(),
                List.of(
                        new SimpleGrantedAuthority(
                                "ROLE_" + user.getVaiTro()
                                        .name()
                                        .toUpperCase()
                        )
                )
        );
    }
}