package com.fpoly.security;

import java.util.List;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import com.fpoly.model.NguoiDung;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.repository.RolePermissionRepository;

/** Chặn trước mọi method có @RequirePermission: admin luôn được bỏ qua; các phòng ban khác phải
 * có quyền "full" hoặc đúng quyền được yêu cầu cho (phòng ban, feature) đó, tra trực tiếp từ DB
 * mỗi request (không nhúng vào JWT) — vì vậy đổi quyền có hiệu lực ngay từ request kế tiếp,
 * không cần đăng nhập lại. */
@Aspect
@Component
public class PermissionAspect {

    @Autowired private NguoiDungRepository nguoiDungRepo;
    @Autowired private RolePermissionRepository rolePermissionRepo;

    @Before("@annotation(rp)")
    public void check(RequirePermission rp) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) throw new PermissionDeniedException(rp.feature(), rp.action());

        NguoiDung nguoiDung = nguoiDungRepo.findByEmail(auth.getName())
                .orElseThrow(() -> new PermissionDeniedException(rp.feature(), rp.action()));

        if (nguoiDung.getVaiTro() == VaiTro.admin) return;

        String department = nguoiDung.getVaiTro().name();
        boolean coQuyen;
        if (rp.action() == PermissionType.VIEW) {
            // Có BẤT KỲ quyền nào trên feature này là xem được — nhất quán với quy tắc hiện nav
            // phía FE ("có quyền là vào được trang"). VD CSKH chỉ có "perform" trên
            // account_detail (không có "view" riêng) nhưng vẫn phải xem được để mà "thực hiện
            // tác vụ" trên đúng bản ghi đó; Kinh doanh chỉ có "limited" trên accounts_customer
            // vẫn phải vào được trang (dữ liệu trả về giới hạn do code endpoint tự xử lý riêng).
            coQuyen = rolePermissionRepo.existsByDepartmentAndFeatureKey(department, rp.feature());
        } else {
            // Các action khác (add/edit/delete/perform) cần đúng quyền đó, không suy ra từ quyền khác.
            coQuyen = rolePermissionRepo.existsByDepartmentAndFeatureKeyAndPermKeyIn(
                    department, rp.feature(), List.of("full", rp.action().toKey()));
        }

        if (!coQuyen) throw new PermissionDeniedException(rp.feature(), rp.action());
    }
}
