package com.fpoly.controller.api;

import java.math.BigDecimal;
import java.text.Normalizer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fpoly.dto.AdminProductDtos.AdminProductDetailDto;
import com.fpoly.dto.AdminProductDtos.GenerateVariantsRequest;
import com.fpoly.dto.AdminProductDtos.ProductSaveRequest;
import com.fpoly.dto.AdminProductDtos.VariantRequest;
import com.fpoly.dto.ContactDtos.ContactDetailDto;
import com.fpoly.dto.ContactDtos.ContactReplyRequest;
import com.fpoly.dto.ContactDtos.ContactStatusRequest;
import com.fpoly.dto.ContactDtos.ContactSummaryDto;
import com.fpoly.dto.OrderDtos.AddressDto;
import com.fpoly.dto.WarrantyDtos.UpdateRequestStatusBody;
import com.fpoly.dto.WarrantyDtos.UpdateWarrantyStatusBody;
import com.fpoly.dto.WarrantyDtos.WarrantyDetailDto;
import com.fpoly.dto.WarrantyDtos.WarrantyHistoryDto;
import com.fpoly.dto.WarrantyDtos.WarrantyRequestDto;
import com.fpoly.dto.WarrantyDtos.WarrantySummaryDto;
import com.fpoly.model.Brand;
import com.fpoly.model.Category;
import com.fpoly.model.NguoiDung;
import com.fpoly.model.Order;
import com.fpoly.model.OrderItem;
import com.fpoly.model.OrderStatusLog;
import com.fpoly.model.Product;
import com.fpoly.model.ProductImage;
import com.fpoly.model.Warranty;
import com.fpoly.model.WarrantyRequest;
import com.fpoly.model.enums.PermissionType;
import com.fpoly.model.enums.VaiTro;
import com.fpoly.repository.BrandRepository;
import com.fpoly.repository.CategoryRepository;
import com.fpoly.repository.NguoiDungRepository;
import com.fpoly.security.RequirePermission;
import com.fpoly.service.AccountLogService;
import com.fpoly.service.AddressService;
import com.fpoly.service.AdminProductService;
import com.fpoly.service.ContactService;
import com.fpoly.service.MailService;
import com.fpoly.service.NotificationService;
import com.fpoly.service.OrderService;
import com.fpoly.service.WarrantyService;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

/**
 * REST API cho khu vực ADMIN (Vue admin tiêu thụ).
 * Bảo vệ bằng JWT yêu cầu role ADMIN hoặc 1 trong 6 phòng ban (cấu hình trong SecurityConfig apiSecurityChain).
 */
@RestController
@RequestMapping("/api/admin")
public class AdminApiController {

    @PersistenceContext
    private EntityManager em;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private AdminProductService adminProductService;

    @Autowired
    private ContactService contactService;

    @Autowired
    private BrandRepository brandRepo;

    @Autowired
    private CategoryRepository categoryRepo;

    @Autowired
    private OrderService orderService;

    @Autowired
    private WarrantyService warrantyService;

    @Autowired
    private NguoiDungRepository nguoiDungRepo;

    @Autowired
    private AddressService addressService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AccountLogService accountLogService;

    @Autowired
    private MailService mailService;

    /** Tài khoản admin/nhân viên đang đăng nhập (người thực hiện thao tác khoá/mở khoá) — dùng cho
     * cột performed_by_id ở ACCOUNT_LOG. */
    private NguoiDung currentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return nguoiDungRepo.findByEmail(email).orElse(null);
    }

    @GetMapping("/dashboard")
    @RequirePermission(feature = "dashboard", action = PermissionType.VIEW)
    public Map<String, Object> dashboard() {
        Map<String, Object> r = new HashMap<>();

        r.put("todayOrders", em.createNativeQuery(
                "SELECT COUNT(*) FROM [ORDER] WHERE CAST(created_at AS DATE)=CAST(GETDATE() AS DATE)"
        ).getSingleResult());

        r.put("todayRevenue", em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] " +
                "WHERE CAST(created_at AS DATE)=CAST(GETDATE() AS DATE) AND status!='cancelled'"
        ).getSingleResult());

        r.put("totalRevenue", em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] WHERE status!='cancelled'"
        ).getSingleResult());

        r.put("totalCustomers", em.createNativeQuery(
                "SELECT COUNT(*) FROM [USER] WHERE role='customer'"
        ).getSingleResult());

        r.put("newCustomersToday", em.createNativeQuery(
                "SELECT COUNT(*) FROM [USER] WHERE role='customer' AND CAST(created_at AS DATE)=CAST(GETDATE() AS DATE)"
        ).getSingleResult());

        r.put("totalProducts", em.createNativeQuery(
                "SELECT COUNT(*) FROM PRODUCT WHERE is_active=1"
        ).getSingleResult());

        r.put("totalOrders", em.createNativeQuery(
                "SELECT COUNT(*) FROM [ORDER]"
        ).getSingleResult());

        // [order_code, full_name, total_amount, status]
        r.put("recentOrders", em.createNativeQuery(
                "SELECT TOP 8 o.order_code, u.full_name, o.total_amount, o.status " +
                "FROM [ORDER] o JOIN [USER] u ON o.user_id=u.id ORDER BY o.created_at DESC"
        ).getResultList());

        // [dd/MM/yyyy, count] — 7 ngày gần nhất
        r.put("last7Days", em.createNativeQuery(
                "SELECT CONVERT(VARCHAR,CAST(created_at AS DATE),103), COUNT(*) " +
                "FROM [ORDER] WHERE created_at>=DATEADD(DAY,-6,CAST(GETDATE() AS DATE)) " +
                "GROUP BY CAST(created_at AS DATE) ORDER BY CAST(created_at AS DATE) ASC"
        ).getResultList());

        // [dd/MM/yyyy, doanh thu] — 7 ngày gần nhất, loại đơn đã huỷ
        r.put("last7Revenue", em.createNativeQuery(
                "SELECT CONVERT(VARCHAR,CAST(created_at AS DATE),103), ISNULL(SUM(total_amount),0) " +
                "FROM [ORDER] WHERE created_at>=DATEADD(DAY,-6,CAST(GETDATE() AS DATE)) AND status!='cancelled' " +
                "GROUP BY CAST(created_at AS DATE) ORDER BY CAST(created_at AS DATE) ASC"
        ).getResultList());

        // [status, count]
        r.put("statusBreakdown", em.createNativeQuery(
                "SELECT status, COUNT(*) FROM [ORDER] GROUP BY status"
        ).getResultList());

        // [id, name, brand_name, stock] — top 6 sắp hết hàng (stock thấp nhất theo biến thể)
        r.put("lowStock", em.createNativeQuery(
                "SELECT TOP 6 p.id, p.name, b.name, MIN(v.stock) " +
                "FROM PRODUCT p JOIN PRODUCT_VARIANT v ON v.product_id=p.id " +
                "LEFT JOIN BRAND b ON p.brand_id=b.id " +
                "WHERE p.is_active=1 GROUP BY p.id, p.name, b.name ORDER BY MIN(v.stock) ASC"
        ).getResultList());

        return r;
    }

    @GetMapping("/products")
    @RequirePermission(feature = "products_view", action = PermissionType.VIEW)
    public List<Map<String, Object>> products() {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT p.id, p.name, c.name, c.slug, b.name, " +
            "  (SELECT TOP 1 v.price FROM PRODUCT_VARIANT v WHERE v.product_id=p.id ORDER BY v.is_default DESC, v.id ASC), " +
            "  (SELECT TOP 1 v.original_price FROM PRODUCT_VARIANT v WHERE v.product_id=p.id ORDER BY v.is_default DESC, v.id ASC), " +
            "  (SELECT TOP 1 v.sku FROM PRODUCT_VARIANT v WHERE v.product_id=p.id ORDER BY v.is_default DESC, v.id ASC), " +
            "  (SELECT ISNULL(SUM(v2.stock),0) FROM PRODUCT_VARIANT v2 WHERE v2.product_id=p.id), " +
            "  p.is_active, " +
            "  (SELECT STRING_AGG(spec_value, ' · ') FROM (" +
            "      SELECT TOP 3 spec_value FROM PRODUCT_SPEC WHERE product_id=p.id ORDER BY sort_order ASC" +
            "  ) top3), " +
            "  (SELECT TOP 1 url FROM PRODUCT_IMAGE WHERE product_id=p.id ORDER BY is_primary DESC, sort_order ASC) " +
            "FROM PRODUCT p " +
            "JOIN CATEGORY c ON p.category_id=c.id " +
            "LEFT JOIN BRAND b ON p.brand_id=b.id " +
            "ORDER BY p.id DESC"
        ).getResultList();

        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]);
            m.put("name", r[1]);
            m.put("categoryName", r[2]);
            m.put("categorySlug", r[3]);
            m.put("brandName", r[4]);
            m.put("price", r[5]);
            m.put("originalPrice", r[6]);
            m.put("sku", r[7]);
            m.put("stock", r[8]);
            m.put("isActive", r[9]);
            m.put("spec", r[10]);
            m.put("imageUrl", r[11]);
            out.add(m);
        }
        return out;
    }

    @GetMapping("/products/{id}")
    @RequirePermission(feature = "products_view", action = PermissionType.VIEW)
    public AdminProductDetailDto productDetail(@PathVariable Integer id) {
        return adminProductService.getDetail(id);
    }

    @GetMapping("/brands")
    @RequirePermission(feature = "products_manage", action = PermissionType.VIEW)
    public List<Map<String, Object>> brands() {
        return brandRepo.findAll().stream().map(b -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", b.getId());
            m.put("name", b.getName());
            return m;
        }).toList();
    }

    @PostMapping("/brands")
    @RequirePermission(feature = "products_manage", action = PermissionType.ADD)
    public Map<String, Object> createBrand(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        if (name == null || name.isBlank()) {
            throw new RuntimeException("Tên thương hiệu không được để trống");
        }
        Brand brand = new Brand();
        brand.setName(name.trim());
        brand = brandRepo.save(brand);
        return Map.of("id", brand.getId(), "name", brand.getName());
    }

    @PostMapping("/products")
    @RequirePermission(feature = "products_manage", action = PermissionType.ADD)
    public Map<String, Object> createProduct(@RequestBody ProductSaveRequest req) {
        Product saved = adminProductService.create(req);
        return Map.of("id", saved.getId());
    }

    @PutMapping("/products/{id}")
    @RequirePermission(feature = "products_manage", action = PermissionType.EDIT)
    public Map<String, Object> updateProduct(@PathVariable Integer id, @RequestBody ProductSaveRequest req) {
        Product saved = adminProductService.update(id, req);
        return Map.of("id", saved.getId());
    }

    @DeleteMapping("/products/{id}")
    @RequirePermission(feature = "products_manage", action = PermissionType.DELETE)
    public Map<String, Object> deleteProduct(@PathVariable Integer id) {
        boolean hardDeleted = adminProductService.delete(id);
        return Map.of("hardDeleted", hardDeleted);
    }

    @PostMapping("/products/variants/generate")
    @RequirePermission(feature = "products_manage", action = PermissionType.EDIT)
    public List<VariantRequest> generateVariants(@RequestBody GenerateVariantsRequest req) {
        return adminProductService.generateVariantSkeletons(req.options(), req.variants());
    }

    @PostMapping("/upload/image")
    @RequirePermission(feature = "products_manage", action = PermissionType.ADD)
    public Map<String, Object> uploadImage(@RequestParam("file") MultipartFile file) {
        return Map.of("url", adminProductService.storeImage(file));
    }

    @GetMapping("/contacts")
    @RequirePermission(feature = "contacts", action = PermissionType.VIEW)
    public List<ContactSummaryDto> contacts() {
        return contactService.findAll();
    }

    @GetMapping("/contacts/{id}")
    @RequirePermission(feature = "contacts", action = PermissionType.VIEW)
    public ContactDetailDto contactDetail(@PathVariable Integer id) {
        return contactService.findById(id);
    }

    @PutMapping("/contacts/{id}/status")
    @RequirePermission(feature = "contacts", action = PermissionType.PERFORM)
    public ContactDetailDto updateContactStatus(@PathVariable Integer id, @RequestBody ContactStatusRequest req) {
        return contactService.updateStatus(id, req.status());
    }

    @PostMapping("/contacts/{id}/reply")
    @RequirePermission(feature = "contacts", action = PermissionType.PERFORM)
    public ContactDetailDto replyContact(@PathVariable Integer id, @RequestBody ContactReplyRequest req) {
        return contactService.reply(id, req.reply());
    }

    @GetMapping("/orders")
    @RequirePermission(feature = "orders", action = PermissionType.VIEW)
    public List<Map<String, Object>> orders() {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT o.id, o.order_code, u.full_name, u.email, o.total_amount, o.status, o.created_at, " +
            "  (SELECT TOP 1 oi.product_name FROM ORDER_ITEM oi WHERE oi.order_id=o.id), " +
            "  (SELECT COUNT(*) FROM ORDER_ITEM oi2 WHERE oi2.order_id=o.id), " +
            "  pm.code, p.status, p.proof_image " +
            "FROM [ORDER] o JOIN [USER] u ON o.user_id=u.id " +
            "LEFT JOIN PAYMENT p ON p.order_id=o.id " +
            "LEFT JOIN PAYMENT_METHOD pm ON pm.id=p.payment_method_id " +
            "ORDER BY o.created_at DESC"
        ).getResultList();

        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]);
            m.put("code", r[1]);
            m.put("customerName", r[2]);
            m.put("customerEmail", r[3]);
            m.put("total", r[4]);
            m.put("status", r[5]);
            m.put("createdAt", r[6]);
            int itemCount = ((Number) r[8]).intValue();
            m.put("itemSummary", r[7] + (itemCount > 1 ? " và " + (itemCount - 1) + " sản phẩm khác" : ""));
            m.put("paymentMethod", r[9]);
            m.put("paymentStatus", r[10]);
            m.put("proofImage", r[11]);
            out.add(m);
        }
        return out;
    }

    @PutMapping("/orders/{id}/status")
    @RequirePermission(feature = "orders", action = PermissionType.PERFORM)
    public Map<String, Object> updateOrderStatus(@PathVariable Integer id, @RequestBody Map<String, String> body) {
        orderService.capNhatTrangThai(id, body.get("status"), body.getOrDefault("note", "Admin cập nhật trạng thái"));
        return Map.of("id", id, "status", body.get("status"));
    }

    @PutMapping("/orders/{id}/confirm-payment")
    @RequirePermission(feature = "orders", action = PermissionType.PERFORM)
    public Map<String, Object> confirmOrderPayment(@PathVariable Integer id) {
        orderService.xacNhanThanhToan(id);
        return Map.of("id", id, "paymentStatus", "paid");
    }

    /** Chi tiết 1 đơn hàng cho admin: danh sách sản phẩm + lịch sử trạng thái theo thời gian
     * (đặt hàng -> thanh toán -> xác nhận -> đóng gói -> giao -> hoàn tất/huỷ). Tách riêng khỏi
     * {@link #orders()} (danh sách) để không phải join thêm bảng cho từng dòng khi chỉ hiển thị
     * danh sách. */
    @GetMapping("/orders/{id}")
    @RequirePermission(feature = "orders", action = PermissionType.VIEW)
    public Map<String, Object> orderDetail(@PathVariable Integer id) {
        Order order = orderService.layDonById(id);

        List<Map<String, Object>> items = (order.getChiTiet() == null ? List.<OrderItem>of() : order.getChiTiet())
                .stream().map(oi -> {
                    Product p = oi.getVariant().getProduct();
                    String img = (p.getImages() != null && !p.getImages().isEmpty())
                            ? p.getImages().stream().filter(ProductImage::getIsPrimary).findFirst()
                                    .map(ProductImage::getUrl).orElse(p.getImages().get(0).getUrl())
                            : null;
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", oi.getId());
                    m.put("productName", oi.getTenSanPham());
                    m.put("variantInfo", oi.getThongTinPhienBan());
                    m.put("unitPrice", oi.getDonGia());
                    m.put("quantity", oi.getSoLuong());
                    m.put("lineTotal", oi.getThanhTien());
                    m.put("imageUrl", img);
                    return m;
                }).toList();

        List<Map<String, Object>> history = (order.getLichSuTrangThai() == null ? List.<OrderStatusLog>of() : order.getLichSuTrangThai())
                .stream()
                .sorted((a, b) -> a.getThoiGian().compareTo(b.getThoiGian()))
                .map(l -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("status", l.getTrangThai());
                    m.put("note", l.getGhiChu());
                    m.put("changedAt", l.getThoiGian());
                    return m;
                }).toList();

        Map<String, Object> result = new HashMap<>();
        result.put("id", order.getId());
        result.put("items", items);
        result.put("statusHistory", history);
        result.put("subtotal", order.getTienHang());
        result.put("discountAmount", order.getTienGiamGia());
        result.put("shippingFee", order.getPhiVanChuyen());
        result.put("shippingOptionLabel", order.getNhanTuyChonGiaoHang());
        result.put("totalAmount", order.getTongTien());
        // Toạ độ khách cắm lúc đặt đơn + quãng đường đã dùng để tính phí ship — để shipper biết
        // chính xác điểm giao và admin đối chiếu được phí. NULL với đơn đặt trước khi có tính
        // năng cắm mốc, Orders.vue tự ẩn khối bản đồ khi đó.
        result.put("deliveryLat", order.getViDoGiao());
        result.put("deliveryLng", order.getKinhDoGiao());
        result.put("shippingDistanceKm", order.getKhoangCachGiaoKm());
        return result;
    }

    /** Widget khách hàng ở "Quản lý tài khoản" — CHỈ trả tài khoản role=customer. "Giới hạn hiển
     * thị" của CSKH/Kinh doanh cho accounts_customer chính là việc chỉ có thể gọi được API này
     * (không gọi được {@link #staffAccounts()}), không cần lọc gì thêm ở đây. */
    /** Khách TỰ ĐĂNG KÝ tài khoản (web hoặc Google/Facebook). Tách khỏi khách vãng lai mua tại
     * quầy vì hai nhóm này khác hẳn nhau về dữ liệu: nhóm này có email thật, đăng nhập được;
     * nhóm kia chỉ có số điện thoại nhân viên nhập hộ. */
    @GetMapping("/customers")
    @RequirePermission(feature = "accounts_customer", action = PermissionType.VIEW)
    public List<Map<String, Object>> customers() {
        return layDanhSachTaiKhoan("u.role = 'customer' AND ISNULL(u.auth_provider,'local') <> 'pos'");
    }

    /** Khách vãng lai / khách lẻ — tài khoản do POS tự tạo khi bán tại quầy (auth_provider='pos',
     * xem PosService.timHoacTaoKhach). Email của nhóm này là email nội bộ sinh theo số điện thoại
     * nên KHÔNG hiển thị; định danh đối với nhân viên là mã KH*** + số điện thoại. */
    @GetMapping("/customers/walk-in")
    @RequirePermission(feature = "accounts_customer", action = PermissionType.VIEW)
    public List<Map<String, Object>> walkInCustomers() {
        List<Map<String, Object>> ds = layDanhSachTaiKhoan("u.role = 'customer' AND u.auth_provider = 'pos'");
        for (Map<String, Object> m : ds) {
            // Mã hiển thị KH0001 — dùng thay tên vì phần lớn khách lẻ không cho tên, và tên tự
            // sinh ("Khách 0912...") lặp lại số điện thoại đã có ở cột bên cạnh.
            m.put("maKhach", String.format("KH%04d", ((Number) m.get("id")).intValue()));
            m.remove("email");
        }
        return ds;
    }

    /** Widget nhân sự — mọi phòng ban + admin, chỉ admin có quyền accounts_staff nên chỉ admin gọi được. */
    @GetMapping("/customers/staff")
    @RequirePermission(feature = "accounts_staff", action = PermissionType.VIEW)
    public List<Map<String, Object>> staffAccounts() {
        return layDanhSachTaiKhoan("u.role != 'customer'");
    }

    private List<Map<String, Object>> layDanhSachTaiKhoan(String whereClause) {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT u.id, u.full_name, u.email, u.phone, u.role, u.is_active, u.created_at, " +
            "  (SELECT COUNT(*) FROM [ORDER] o WHERE o.user_id=u.id), " +
            "  (SELECT ISNULL(SUM(o.total_amount),0) FROM [ORDER] o WHERE o.user_id=u.id AND o.status!='cancelled') " +
            "FROM [USER] u WHERE " + whereClause + " ORDER BY u.created_at DESC"
        ).getResultList();

        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]);
            m.put("name", r[1]);
            m.put("email", r[2]);
            m.put("phone", r[3]);
            m.put("role", r[4]);
            m.put("isActive", r[5]);
            m.put("joinedAt", r[6]);
            m.put("orderCount", r[7]);
            m.put("totalSpent", r[8]);
            out.add(m);
        }
        return out;
    }

    /** Admin tạo tài khoản nhân viên mới, gán luôn phòng ban (= toàn bộ quyền của phòng ban đó,
     * không phân quyền riêng từng người ở bản này). */
    @PostMapping("/customers")
    @RequirePermission(feature = "accounts_staff", action = PermissionType.ADD)
    public Map<String, Object> createStaffAccount(@RequestBody Map<String, String> body) {
        String hoTen = body.get("hoTen");
        String email = body.get("email");
        String soDienThoai = body.get("soDienThoai");
        String ghiChu = body.get("ghiChu");
        String phongBanRaw = body.get("phongBan");
        if (hoTen == null || hoTen.isBlank()) throw new RuntimeException("Vui lòng nhập họ tên");
        if (email == null || email.isBlank()) throw new RuntimeException("Vui lòng nhập email");
        if (soDienThoai == null || soDienThoai.isBlank()) throw new RuntimeException("Vui lòng nhập số điện thoại");
        if (nguoiDungRepo.existsByEmail(email)) throw new RuntimeException("Email \"" + email + "\" đã được dùng");

        VaiTro phongBan;
        try {
            phongBan = VaiTro.valueOf(String.valueOf(phongBanRaw));
        } catch (Exception e) {
            throw new RuntimeException("Phòng ban không hợp lệ");
        }
        if (phongBan == VaiTro.customer) throw new RuntimeException("Phòng ban không hợp lệ");

        String matKhauGoc = taoMatKhauNgauNhien();

        NguoiDung u = new NguoiDung();
        u.setHoTen(hoTen.trim());
        u.setEmail(email.trim());
        u.setSoDienThoai(soDienThoai.trim());
        u.setGhiChu(ghiChu != null && !ghiChu.isBlank() ? ghiChu.trim() : null);
        u.setMatKhau(passwordEncoder.encode(matKhauGoc));
        u.setVaiTro(phongBan);
        u.setIsActive(true);
        u.setAuthProvider("local");
        u.setCreatedAt(java.time.LocalDateTime.now());
        u = nguoiDungRepo.save(u);
        // Mật khẩu gốc chỉ trả về đúng 1 lần trong response này (không lưu plaintext, không log lại) -
        // admin phải copy/gửi cho nhân viên ngay, không xem lại được sau khi đóng modal.
        return Map.of("id", u.getId(), "email", u.getEmail(), "role", u.getVaiTro().name(), "generatedPassword", matKhauGoc);
    }

    private static final String BANG_CHU_MAT_KHAU = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";

    /** Sinh mật khẩu ngẫu nhiên 10 ký tự, bỏ các ký tự dễ nhầm (0/O, 1/l/I) cho dễ gõ lại khi admin đọc/gửi cho nhân viên. */
    private String taoMatKhauNgauNhien() {
        java.security.SecureRandom rnd = new java.security.SecureRandom();
        StringBuilder sb = new StringBuilder(10);
        for (int i = 0; i < 10; i++) {
            sb.append(BANG_CHU_MAT_KHAU.charAt(rnd.nextInt(BANG_CHU_MAT_KHAU.length())));
        }
        return sb.toString();
    }

    @GetMapping("/customers/{id}")
    @RequirePermission(feature = "account_detail", action = PermissionType.VIEW)
    public Map<String, Object> customerDetail(@PathVariable Integer id) {
        NguoiDung u = nguoiDungRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));

        Object[] stats = (Object[]) em.createNativeQuery(
            "SELECT COUNT(*), ISNULL(SUM(CASE WHEN status!='cancelled' THEN total_amount ELSE 0 END),0) " +
            "FROM [ORDER] WHERE user_id=:id"
        ).setParameter("id", id).getSingleResult();

        Map<String, Object> m = new HashMap<>();
        m.put("id", u.getId());
        m.put("name", u.getHoTen());
        m.put("email", u.getEmail());
        m.put("phone", u.getSoDienThoai());
        m.put("role", u.getVaiTro().name());
        m.put("isActive", u.getIsActive());
        m.put("joinedAt", u.getCreatedAt());
        m.put("orderCount", ((Number) stats[0]).intValue());
        m.put("totalSpent", stats[1]);
        m.put("addresses", addressService.layDanhSachTheoEmail(u.getEmail()).stream()
                .map(a -> new AddressDto(a.getId(), a.getTenNguoiNhan(), a.getSoDienThoai(), a.getDiaChiCuThe(),
                        a.getProvince() != null ? a.getProvince().getId() : null, a.getTinhThanh(),
                        a.getWard() != null ? a.getWard().getId() : null, a.getPhuongXa(),
                        a.getDiaChiDayDu(), a.getIsDefault(), a.getLatitude(), a.getLongitude()))
                .toList());

        List<Object[]> orderRows = em.createNativeQuery(
            "SELECT TOP 8 id, order_code, total_amount, status, created_at FROM [ORDER] WHERE user_id=:id ORDER BY created_at DESC"
        ).setParameter("id", id).getResultList();
        List<Map<String, Object>> recentOrders = new ArrayList<>();
        for (Object[] r : orderRows) {
            Map<String, Object> om = new HashMap<>();
            om.put("id", r[0]);
            om.put("code", r[1]);
            om.put("total", r[2]);
            om.put("status", r[3]);
            om.put("createdAt", r[4]);
            recentOrders.add(om);
        }
        m.put("recentOrders", recentOrders);
        return m;
    }

    @PutMapping("/customers/{id}/role")
    @RequirePermission(feature = "accounts_staff", action = PermissionType.EDIT)
    public Map<String, Object> updateCustomerRole(@PathVariable Integer id, @RequestBody Map<String, String> body) {
        NguoiDung u = nguoiDungRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
        VaiTro role;
        try {
            role = VaiTro.valueOf(String.valueOf(body.get("role")).toLowerCase());
        } catch (Exception e) {
            throw new RuntimeException("Vai trò không hợp lệ");
        }
        u.setVaiTro(role);
        nguoiDungRepo.save(u);
        return Map.of("id", u.getId(), "role", u.getVaiTro().name());
    }

    /** Mở khoá (isActive=true) — khoá thật giờ đi qua {@link #lockCustomer} vì cần lý do/hạn/ảnh
     * chứng minh; endpoint này giữ lại cho chiều mở khoá, không yêu cầu xác nhận gì thêm. */
    @PutMapping("/customers/{id}/status")
    @RequirePermission(feature = "account_detail", action = PermissionType.PERFORM)
    public Map<String, Object> updateCustomerStatus(@PathVariable Integer id, @RequestBody Map<String, Object> body) {
        NguoiDung u = nguoiDungRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));
        boolean next = Boolean.TRUE.equals(body.get("isActive"));
        boolean dangBiKhoa = !Boolean.TRUE.equals(u.getIsActive());
        u.setIsActive(next);
        nguoiDungRepo.save(u);
        if (next && dangBiKhoa) {
            accountLogService.logUnlock(u, currentAdmin());
        }
        return Map.of("id", u.getId(), "isActive", u.getIsActive());
    }

    /** Khoá tài khoản kèm xác nhận: lý do (bắt buộc), hạn khoá (không chọn = vĩnh viễn), ảnh chứng
     * minh (không bắt buộc) — ghi log ACCOUNT_LOG và gửi mail báo cho chủ tài khoản. */
    @PostMapping("/customers/{id}/lock")
    @RequirePermission(feature = "account_detail", action = PermissionType.PERFORM)
    public Map<String, Object> lockCustomer(
            @PathVariable Integer id,
            @RequestParam("reason") String reason,
            @RequestParam(value = "lockUntil", required = false) String lockUntilStr,
            @RequestParam(value = "evidence", required = false) MultipartFile evidence) {
        if (reason == null || reason.isBlank()) throw new RuntimeException("Vui lòng nhập lý do khoá");

        NguoiDung u = nguoiDungRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản"));

        LocalDateTime lockUntil = null;
        if (lockUntilStr != null && !lockUntilStr.isBlank()) {
            try {
                lockUntil = java.time.LocalDate.parse(lockUntilStr).atStartOfDay();
            } catch (Exception e) {
                throw new RuntimeException("Hạn khoá không hợp lệ");
            }
        }

        String evidenceUrl = (evidence != null && !evidence.isEmpty()) ? adminProductService.storeImage(evidence) : null;

        u.setIsActive(false);
        nguoiDungRepo.save(u);

        String lyDo = reason.trim();
        accountLogService.logLock(u, currentAdmin(), lyDo, lockUntil, evidenceUrl);

        try {
            mailService.sendAccountLockedEmail(u.getEmail(), u.getHoTen(), lyDo, lockUntil);
        } catch (Exception e) {
            // Không chặn luồng khoá tài khoản nếu gửi mail thất bại
        }

        return Map.of("id", u.getId(), "isActive", u.getIsActive());
    }

    /** Timeline đăng nhập + khoá/mở khoá của 1 tài khoản, mới nhất trước — hiển thị dưới phần
     * "Trạng thái tài khoản" ở trang chi tiết tài khoản. */
    @GetMapping("/customers/{id}/activity-log")
    @RequirePermission(feature = "account_detail", action = PermissionType.VIEW)
    public List<Map<String, Object>> customerActivityLog(@PathVariable Integer id) {
        return accountLogService.getRecentLogs(id, 50);
    }

    @GetMapping("/coupons")
    @RequirePermission(feature = "coupons", action = PermissionType.VIEW)
    public List<Map<String, Object>> coupons() {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT id, code, discount_type, discount_value, min_order_value, max_uses, used_count, expires_at, is_active, xu_cost " +
            "FROM COUPON ORDER BY id DESC"
        ).getResultList();

        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]);
            m.put("code", r[1]);
            m.put("discountType", r[2]);
            m.put("discountValue", r[3]);
            m.put("minOrderValue", r[4]);
            m.put("maxUses", r[5]);
            m.put("usedCount", r[6]);
            m.put("expiresAt", r[7]);
            m.put("isActive", r[8]);
            m.put("xuCost", r[9]);
            out.add(m);
        }
        return out;
    }

    @PostMapping("/coupons")
    @Transactional
    @RequirePermission(feature = "coupons", action = PermissionType.ADD)
    public Map<String, Object> createCoupon(@RequestBody Map<String, Object> body) {
        String code = String.valueOf(body.get("code")).toUpperCase().trim();
        if (code.isBlank() || code.equals("NULL")) {
            throw new RuntimeException("Mã coupon không được để trống");
        }
        try {
            em.createNativeQuery(
                "INSERT INTO COUPON (code, discount_type, discount_value, min_order_value, max_uses, expires_at, is_active, xu_cost) " +
                "VALUES (:code, :type, :val, :min, :max, :exp, 1, :xuCost)")
                .setParameter("code", code)
                .setParameter("type", String.valueOf(body.getOrDefault("discountType", "percent")))
                .setParameter("val", new BigDecimal(String.valueOf(body.get("discountValue"))))
                .setParameter("min", body.get("minOrderValue") != null ? new BigDecimal(String.valueOf(body.get("minOrderValue"))) : BigDecimal.ZERO)
                .setParameter("max", body.get("maxUses") != null && !String.valueOf(body.get("maxUses")).isBlank() ? Integer.valueOf(String.valueOf(body.get("maxUses"))) : null)
                .setParameter("exp", body.get("expiresAt") != null && !String.valueOf(body.get("expiresAt")).isBlank() ? LocalDate.parse(String.valueOf(body.get("expiresAt"))) : null)
                .setParameter("xuCost", body.get("xuCost") != null && !String.valueOf(body.get("xuCost")).isBlank() ? Integer.valueOf(String.valueOf(body.get("xuCost"))) : null)
                .executeUpdate();
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new RuntimeException("Mã coupon \"" + code + "\" đã tồn tại");
        }
        return Map.of("code", code);
    }

    @DeleteMapping("/coupons/{id}")
    @Transactional
    @RequirePermission(feature = "coupons", action = PermissionType.DELETE)
    public void deleteCoupon(@PathVariable Integer id) {
        em.createNativeQuery("DELETE FROM COUPON WHERE id = :id").setParameter("id", id).executeUpdate();
    }

    // Phí nội thành Hải Phòng (2 tier cố định: cùng Phường Hải An / phường khác) — chỉ sửa phí,
    // không thêm/xoá tier vì công thức tính (ShippingService) đang gắn cứng 2 tier_key này.
    @GetMapping("/shipping/hp-tiers")
    @RequirePermission(feature = "shipping", action = PermissionType.VIEW)
    public List<Map<String, Object>> hpTiers() {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT id, tier_key, label, fee FROM SHIPPING_HP_TIER ORDER BY id ASC"
        ).getResultList();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]); m.put("tierKey", r[1]); m.put("label", r[2]); m.put("fee", r[3]);
            out.add(m);
        }
        return out;
    }

    @PutMapping("/shipping/hp-tiers/{id}")
    @Transactional
    @RequirePermission(feature = "shipping", action = PermissionType.EDIT)
    public Map<String, Object> updateHpTier(@PathVariable Integer id, @RequestBody Map<String, Object> body) {
        em.createNativeQuery("UPDATE SHIPPING_HP_TIER SET fee=:fee WHERE id=:id")
            .setParameter("fee", new BigDecimal(String.valueOf(body.get("fee"))))
            .setParameter("id", id)
            .executeUpdate();
        return Map.of("id", id);
    }

    // Đơn vị vận chuyển ngoài Hải Phòng — phí "liên tỉnh/liên miền" gộp 1 mức, thời gian giao
    // tách theo cùng miền/khác miền (xem ShippingService).
    @GetMapping("/shipping/carriers")
    @RequirePermission(feature = "shipping", action = PermissionType.VIEW)
    public List<Map<String, Object>> carriers() {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT id, code, name, fee_lien_tinh, time_cung_mien, time_khac_mien, is_active, thu_tu " +
            "FROM CARRIER ORDER BY thu_tu ASC"
        ).getResultList();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", r[0]); m.put("code", r[1]); m.put("name", r[2]);
            m.put("feeLienTinh", r[3]); m.put("timeCungMien", r[4]); m.put("timeKhacMien", r[5]);
            m.put("isActive", r[6]); m.put("thuTu", r[7]);
            out.add(m);
        }
        return out;
    }

    @PostMapping("/shipping/carriers")
    @Transactional
    @RequirePermission(feature = "shipping", action = PermissionType.ADD)
    public Map<String, Object> createCarrier(@RequestBody Map<String, Object> body) {
        String code = String.valueOf(body.get("code")).toLowerCase().trim();
        if (code.isBlank() || code.equals("null")) {
            throw new RuntimeException("Mã đơn vị vận chuyển không được để trống");
        }
        try {
            em.createNativeQuery(
                "INSERT INTO CARRIER (code, name, fee_lien_tinh, time_cung_mien, time_khac_mien, thu_tu) " +
                "VALUES (:code, :name, :fee, :tcm, :tkm, " +
                "(SELECT ISNULL(MAX(thu_tu), 0) + 1 FROM CARRIER))")
                .setParameter("code", code)
                .setParameter("name", String.valueOf(body.get("name")))
                .setParameter("fee", new BigDecimal(String.valueOf(body.get("feeLienTinh"))))
                .setParameter("tcm", String.valueOf(body.get("timeCungMien")))
                .setParameter("tkm", String.valueOf(body.get("timeKhacMien")))
                .executeUpdate();
        } catch (org.springframework.dao.DataIntegrityViolationException e) {
            throw new RuntimeException("Mã đơn vị vận chuyển \"" + code + "\" đã tồn tại");
        }
        return Map.of("code", code);
    }

    @PutMapping("/shipping/carriers/{id}")
    @Transactional
    @RequirePermission(feature = "shipping", action = PermissionType.EDIT)
    public Map<String, Object> updateCarrier(@PathVariable Integer id, @RequestBody Map<String, Object> body) {
        em.createNativeQuery(
            "UPDATE CARRIER SET name=:name, fee_lien_tinh=:fee, time_cung_mien=:tcm, time_khac_mien=:tkm, " +
            "is_active=:active WHERE id=:id")
            .setParameter("name", String.valueOf(body.get("name")))
            .setParameter("fee", new BigDecimal(String.valueOf(body.get("feeLienTinh"))))
            .setParameter("tcm", String.valueOf(body.get("timeCungMien")))
            .setParameter("tkm", String.valueOf(body.get("timeKhacMien")))
            .setParameter("active", !Boolean.FALSE.equals(body.get("isActive")))
            .setParameter("id", id)
            .executeUpdate();
        return Map.of("id", id);
    }

    @DeleteMapping("/shipping/carriers/{id}")
    @Transactional
    @RequirePermission(feature = "shipping", action = PermissionType.DELETE)
    public void deleteCarrier(@PathVariable Integer id) {
        em.createNativeQuery("DELETE FROM CARRIER WHERE id = :id").setParameter("id", id).executeUpdate();
    }

    @PostMapping("/categories")
    @RequirePermission(feature = "categories", action = PermissionType.ADD)
    public Map<String, Object> createCategory(@RequestBody Map<String, String> body) {
        String name = body.get("name");
        if (name == null || name.isBlank()) {
            throw new RuntimeException("Tên danh mục không được để trống");
        }
        String slug = normalizeSlug(name);
        if (categoryRepo.existsBySlug(slug)) {
            throw new RuntimeException("Danh mục \"" + name + "\" đã tồn tại");
        }
        Category c = new Category();
        c.setName(name.trim());
        c.setSlug(slug);
        c.setSortOrder(categoryRepo.findAll().size() + 1);
        c = categoryRepo.save(c);
        return Map.of("id", c.getId(), "name", c.getName(), "slug", c.getSlug());
    }

    @GetMapping("/analytics")
    @RequirePermission(feature = "analytics", action = PermissionType.VIEW)
    public Map<String, Object> analytics() {
        List<String> monthLabels = new ArrayList<>();
        List<BigDecimal> totalSeries = new ArrayList<>();
        Map<String, List<BigDecimal>> catSeries = new LinkedHashMap<>();

        List<Object[]> catNameRows = em.createNativeQuery("SELECT name FROM CATEGORY ORDER BY sort_order ASC").getResultList();
        for (Object row : catNameRows) {
            catSeries.put((String) row, new ArrayList<>());
        }

        LocalDate today = LocalDate.now();
        LocalDate windowStart = today.withDayOfMonth(1).minusMonths(8);

        for (int i = 0; i < 9; i++) {
            LocalDate monthStart = windowStart.plusMonths(i);
            LocalDate monthEnd = monthStart.plusMonths(1);
            monthLabels.add("Th" + monthStart.getMonthValue());

            BigDecimal total = (BigDecimal) em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] WHERE status != 'cancelled' AND created_at >= :from AND created_at < :to"
            ).setParameter("from", monthStart).setParameter("to", monthEnd).getSingleResult();
            totalSeries.add(total);

            List<Object[]> catRows = em.createNativeQuery(
                "SELECT c.name, ISNULL(SUM(oi.unit_price*oi.quantity),0) " +
                "FROM ORDER_ITEM oi JOIN PRODUCT_VARIANT v ON oi.variant_id=v.id JOIN PRODUCT p ON v.product_id=p.id " +
                "JOIN CATEGORY c ON p.category_id=c.id JOIN [ORDER] o ON oi.order_id=o.id " +
                "WHERE o.status != 'cancelled' AND o.created_at >= :from AND o.created_at < :to " +
                "GROUP BY c.name"
            ).setParameter("from", monthStart).setParameter("to", monthEnd).getResultList();

            Map<String, BigDecimal> thisMonth = new HashMap<>();
            for (Object[] r : catRows) thisMonth.put((String) r[0], (BigDecimal) r[1]);
            for (Map.Entry<String, List<BigDecimal>> e : catSeries.entrySet()) {
                e.getValue().add(thisMonth.getOrDefault(e.getKey(), BigDecimal.ZERO));
            }
        }

        LocalDate prevWindowStart = windowStart.minusMonths(9);

        Map<String, Object> result = new HashMap<>();
        result.put("monthLabels", monthLabels);
        result.put("totalSeries", totalSeries);
        result.put("categorySeries", catSeries);
        result.put("metrics", windowMetrics(windowStart, today.plusDays(1), prevWindowStart, windowStart));
        result.put("topProducts", topProducts(windowStart));

        // ===== Bán tại quầy (POS) =====
        // Doanh thu POS ĐÃ nằm trong totalSeries/metrics ở trên (query tổng không lọc theo
        // channel, và đơn POS luôn có status='delivered'). Các số dưới đây là bóc tách RIÊNG để
        // vẽ biểu đồ so sánh online / tại quầy, KHÔNG phải cộng thêm lần nữa.
        result.put("posSeries", posRevenueSeries(windowStart));
        result.put("posTopProducts", topProductsTheoKenh(windowStart, "pos"));
        result.put("posMetrics", posMetrics(windowStart, today.plusDays(1)));
        return result;
    }

    /** Doanh thu bán tại quầy theo từng tháng, khớp đúng 9 mốc tháng của totalSeries. */
    private List<BigDecimal> posRevenueSeries(LocalDate windowStart) {
        List<BigDecimal> series = new ArrayList<>();
        for (int i = 0; i < 9; i++) {
            LocalDate monthStart = windowStart.plusMonths(i);
            BigDecimal v = (BigDecimal) em.createNativeQuery(
                "SELECT ISNULL(SUM(total_amount),0) FROM [ORDER] " +
                "WHERE status != 'cancelled' AND channel = 'pos' AND created_at >= :from AND created_at < :to"
            ).setParameter("from", monthStart).setParameter("to", monthStart.plusMonths(1)).getSingleResult();
            series.add(v);
        }
        return series;
    }

    /** Tổng quan riêng cho kênh bán tại quầy: doanh thu, số đơn, giá trị đơn trung bình. */
    private Map<String, Object> posMetrics(LocalDate from, LocalDate to) {
        Object[] r = (Object[]) em.createNativeQuery(
            "SELECT ISNULL(SUM(total_amount),0), COUNT(*) FROM [ORDER] " +
            "WHERE status != 'cancelled' AND channel = 'pos' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", from).setParameter("to", to).getSingleResult();

        BigDecimal doanhThu = (BigDecimal) r[0];
        long soDon = ((Number) r[1]).longValue();

        Map<String, Object> m = new HashMap<>();
        m.put("revenue", doanhThu);
        m.put("orders", soDon);
        m.put("avgOrder", soDon == 0 ? BigDecimal.ZERO
                : doanhThu.divide(BigDecimal.valueOf(soDon), 0, java.math.RoundingMode.HALF_UP));
        return m;
    }

    /** Top sản phẩm bán chạy CỦA MỘT KÊNH (kèm doanh thu của chính sản phẩm đó). Dùng lại được
     * cho kênh online nếu sau này cần so sánh hai bên. */
    private List<Map<String, Object>> topProductsTheoKenh(LocalDate from, String kenh) {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT TOP 7 p.name, SUM(oi.quantity), SUM(oi.unit_price*oi.quantity) " +
            "FROM ORDER_ITEM oi JOIN PRODUCT_VARIANT v ON oi.variant_id=v.id JOIN PRODUCT p ON v.product_id=p.id " +
            "JOIN [ORDER] o ON oi.order_id=o.id " +
            "WHERE o.status != 'cancelled' AND o.channel = :kenh AND o.created_at >= :from " +
            "GROUP BY p.name ORDER BY SUM(oi.unit_price*oi.quantity) DESC"
        ).setParameter("from", from).setParameter("kenh", kenh).getResultList();

        List<Map<String, Object>> out = new ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("name", r[0]);
            m.put("sold", r[1]);
            m.put("revenue", r[2]);
            out.add(m);
        }
        return out;
    }

    private Map<String, Object> windowMetrics(LocalDate from, LocalDate to, LocalDate prevFrom, LocalDate prevTo) {
        Map<String, Object> m = new HashMap<>();

        Object[] cur = (Object[]) em.createNativeQuery(
            "SELECT ISNULL(SUM(total_amount),0), COUNT(*) FROM [ORDER] WHERE status != 'cancelled' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", from).setParameter("to", to).getSingleResult();
        Object[] prev = (Object[]) em.createNativeQuery(
            "SELECT ISNULL(SUM(total_amount),0), COUNT(*) FROM [ORDER] WHERE status != 'cancelled' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", prevFrom).setParameter("to", prevTo).getSingleResult();

        BigDecimal curRevenue = (BigDecimal) cur[0];
        long curOrders = ((Number) cur[1]).longValue();
        BigDecimal prevRevenue = (BigDecimal) prev[0];
        long prevOrders = ((Number) prev[1]).longValue();

        long newCustomers = ((Number) em.createNativeQuery(
            "SELECT COUNT(*) FROM [USER] WHERE role='customer' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", from).setParameter("to", to).getSingleResult()).longValue();
        long prevNewCustomers = ((Number) em.createNativeQuery(
            "SELECT COUNT(*) FROM [USER] WHERE role='customer' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", prevFrom).setParameter("to", prevTo).getSingleResult()).longValue();

        long deliveredCount = ((Number) em.createNativeQuery(
            "SELECT COUNT(*) FROM [ORDER] WHERE status='delivered' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", from).setParameter("to", to).getSingleResult()).longValue();
        long prevDeliveredCount = ((Number) em.createNativeQuery(
            "SELECT COUNT(*) FROM [ORDER] WHERE status='delivered' AND created_at >= :from AND created_at < :to"
        ).setParameter("from", prevFrom).setParameter("to", prevTo).getSingleResult()).longValue();

        BigDecimal avgOrder = curOrders > 0 ? curRevenue.divide(BigDecimal.valueOf(curOrders), 0, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO;
        BigDecimal prevAvgOrder = prevOrders > 0 ? prevRevenue.divide(BigDecimal.valueOf(prevOrders), 0, java.math.RoundingMode.HALF_UP) : BigDecimal.ZERO;
        double deliveredRate = curOrders > 0 ? (deliveredCount * 100.0 / curOrders) : 0;
        double prevDeliveredRate = prevOrders > 0 ? (prevDeliveredCount * 100.0 / prevOrders) : 0;

        m.put("totalRevenue", curRevenue);
        m.put("totalRevenueDeltaPct", pctDelta(curRevenue.doubleValue(), prevRevenue.doubleValue(), prevOrders));
        m.put("totalOrders", curOrders);
        m.put("totalOrdersDeltaPct", pctDelta(curOrders, prevOrders, prevOrders));
        m.put("newCustomers", newCustomers);
        m.put("newCustomersDeltaPct", pctDelta(newCustomers, prevNewCustomers, prevNewCustomers));
        m.put("avgOrderValue", avgOrder);
        m.put("avgOrderValueDeltaPct", pctDelta(avgOrder.doubleValue(), prevAvgOrder.doubleValue(), prevOrders));
        m.put("deliveredRate", Math.round(deliveredRate * 10) / 10.0);
        m.put("deliveredRateDeltaPct", pctDelta(deliveredRate, prevDeliveredRate, prevOrders));
        return m;
    }

    /** Số mẫu tối thiểu ở kỳ trước để % so sánh còn ý nghĩa thống kê (dưới mức này, dao động
     * ngẫu nhiên nhỏ cũng tạo ra % khổng lồ — VD 7 lên 100 đơn ra +1328%, gây hiểu nhầm). */
    private static final long MIN_BASELINE_SAMPLE = 10;

    /** null khi kỳ trước chưa đủ dữ liệu để so sánh (0 hoặc quá ít mẫu) — tránh hiện % ảo. */
    private Double pctDelta(double cur, double prev, long baselineSampleCount) {
        if (prev == 0 || baselineSampleCount < MIN_BASELINE_SAMPLE) return null;
        return Math.round(((cur - prev) / prev) * 1000) / 10.0;
    }

    private List<Map<String, Object>> topProducts(LocalDate from) {
        List<Object[]> rows = em.createNativeQuery(
            "SELECT TOP 7 p.name, SUM(oi.quantity), SUM(oi.unit_price*oi.quantity) " +
            "FROM ORDER_ITEM oi JOIN PRODUCT_VARIANT v ON oi.variant_id=v.id JOIN PRODUCT p ON v.product_id=p.id " +
            "JOIN [ORDER] o ON oi.order_id=o.id " +
            "WHERE o.status != 'cancelled' AND o.created_at >= :from " +
            "GROUP BY p.name ORDER BY SUM(oi.unit_price*oi.quantity) DESC"
        ).setParameter("from", from).getResultList();

        List<Map<String, Object>> out = new ArrayList<>();
        for (Object[] r : rows) {
            Map<String, Object> m = new HashMap<>();
            m.put("name", r[0]);
            m.put("sold", r[1]);
            m.put("revenue", r[2]);
            out.add(m);
        }
        return out;
    }

    @GetMapping("/notifications")
    public List<Map<String, Object>> notifications() {
        return notificationService.layGanDay().stream().map(n -> {
            Map<String, Object> m = new HashMap<>();
            m.put("id", n.getId());
            m.put("type", n.getLoai());
            m.put("title", n.getTieuDe());
            m.put("message", n.getNoiDung());
            m.put("link", n.getLink());
            m.put("isRead", n.getDaDoc());
            m.put("createdAt", n.getCreatedAt());
            return m;
        }).toList();
    }

    @GetMapping("/notifications/unread-count")
    public Map<String, Object> unreadCount() {
        return Map.of("count", notificationService.soChuaDoc());
    }

    @PostMapping("/notifications/{id}/read")
    public void markRead(@PathVariable Integer id) {
        notificationService.danhDauDaDoc(id);
    }

    @PostMapping("/notifications/read-all")
    public void markAllRead() {
        notificationService.danhDauTatCaDaDoc();
    }

    @GetMapping("/warranties")
    @RequirePermission(feature = "warranty", action = PermissionType.VIEW)
    public List<WarrantySummaryDto> warranties(@RequestParam(required = false) String status) {
        List<Warranty> list = (status == null || status.isBlank())
                ? warrantyService.getAllWarranty()
                : warrantyService.getWarrantyByStatus(status);
        return list.stream().map(this::toWarrantySummary).toList();
    }

    @GetMapping("/warranties/{id}")
    @RequirePermission(feature = "warranty", action = PermissionType.VIEW)
    public WarrantyDetailDto warrantyDetail(@PathVariable Integer id) {
        return toWarrantyDetail(warrantyService.getById(id));
    }

    @PutMapping("/warranties/{id}/status")
    @RequirePermission(feature = "warranty", action = PermissionType.PERFORM)
    public WarrantyDetailDto updateWarrantyStatus(@PathVariable Integer id, @RequestBody UpdateWarrantyStatusBody body) {
        warrantyService.updateStatus(id, body.status());
        return toWarrantyDetail(warrantyService.getById(id));
    }

    @GetMapping("/warranty-requests")
    @RequirePermission(feature = "warranty", action = PermissionType.VIEW)
    public List<WarrantyRequestDto> warrantyRequests() {
        return warrantyService.getAllRequest().stream().map(this::toWarrantyRequestDto).toList();
    }

    @GetMapping("/warranty-requests/{id}")
    @RequirePermission(feature = "warranty", action = PermissionType.VIEW)
    public WarrantyRequestDto warrantyRequestDetail(@PathVariable Integer id) {
        return toWarrantyRequestDto(warrantyService.getRequest(id));
    }

    @PutMapping("/warranty-requests/{id}/status")
    @RequirePermission(feature = "warranty", action = PermissionType.PERFORM)
    public WarrantyRequestDto updateWarrantyRequestStatus(@PathVariable Integer id, @RequestBody UpdateRequestStatusBody body) {
        warrantyService.updateRequestStatus(id, body.status(), body.note());
        return toWarrantyRequestDto(warrantyService.getRequest(id));
    }

    private WarrantySummaryDto toWarrantySummary(Warranty w) {
        return new WarrantySummaryDto(
                w.getId(), w.getOrderItem().getTenSanPham(), w.getSerialNumber(),
                w.getStartDate(), w.getEndDate(), w.getStatus(),
                w.getNguoiDung().getHoTen(), w.getNguoiDung().getEmail());
    }

    private WarrantyDetailDto toWarrantyDetail(Warranty w) {
        List<WarrantyRequestDto> requests = warrantyService.getRequests(w.getId()).stream()
                .map(this::toWarrantyRequestDto).toList();
        return new WarrantyDetailDto(
                w.getId(), w.getOrderItem().getTenSanPham(), w.getOrderItem().getOrder().getMaDonHang(),
                w.getSerialNumber(), w.getStartDate(), w.getEndDate(), w.getStatus(),
                w.getNguoiDung().getHoTen(), w.getNguoiDung().getEmail(), requests);
    }

    private WarrantyRequestDto toWarrantyRequestDto(WarrantyRequest r) {
        List<WarrantyHistoryDto> history = warrantyService.getHistory(r).stream()
                .map(h -> new WarrantyHistoryDto(h.getStatus(), h.getNote(), h.getCreatedAt())).toList();
        return new WarrantyRequestDto(
                r.getId(), r.getIssueDescription(), r.getRequestStatus(), r.getCreatedAt(),
                r.getWarranty().getId(), r.getWarranty().getOrderItem().getTenSanPham(),
                r.getWarranty().getNguoiDung().getHoTen(), r.getWarranty().getNguoiDung().getEmail(), history);
    }

    private String normalizeSlug(String raw) {
        String noAccent = Normalizer.normalize(raw, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D');
        String slug = noAccent.trim().toLowerCase()
                .replaceAll("[^a-z0-9]+", "-")
                .replaceAll("(^-+|-+$)", "");
        return slug.isBlank() ? "dm-" + System.currentTimeMillis() : slug;
    }
}
