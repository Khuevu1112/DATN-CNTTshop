// ============================================================
//  PATCH cho SecurityConfig.java
// ============================================================
//
// Trong apiSecurityChain(), thêm dòng này VÀO TRƯỚC .anyRequest().authenticated():
// (đặt cạnh .requestMatchers("/api/shipping/**").permitAll())
//
//     .requestMatchers("/api/orders/*/tracking").authenticated()
//
// Route /api/orders/{id}/tracking đã rơi vào .anyRequest().authenticated() ở cuối rồi (không
// có matcher permitAll nào bắt trúng /api/orders/**), nên thực ra KHÔNG BẮT BUỘC phải thêm —
// chỉ thêm nếu bạn muốn matcher này hiện rõ tường minh trong danh sách thay vì rơi vào catch-all.
//
// Không cần sửa gì thêm trong SecurityConfig.
