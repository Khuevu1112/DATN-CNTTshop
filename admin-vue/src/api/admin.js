import http from './http'

export const getDashboard = () => http.get('/admin/dashboard').then(r => r.data)

// Số liệu hiển thị cạnh từng mục sidebar: { <ten-route>: { tong, moi } } — xem
// AdminApiController.sidebarCounts.
export const getSidebarCounts = () => http.get('/admin/sidebar-counts').then(r => r.data)

export const getNotifications = () => http.get('/admin/notifications').then(r => r.data)
export const getUnreadCount = () => http.get('/admin/notifications/unread-count').then(r => r.data.count)
export const markNotificationRead = (id) => http.post(`/admin/notifications/${id}/read`)
export const markAllNotificationsRead = () => http.post('/admin/notifications/read-all')

export const getAdminProducts = () => http.get('/admin/products').then(r => r.data)
export const importProductsExcel = (file) => {
  const form = new FormData()
  form.append('file', file)
  return http.post('/admin/products/import', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }).then(r => r.data)
}
// responseType 'blob' vì đây là file binary tải về, không phải JSON — vẫn cần đi qua http (có gắn
// JWT admin) do endpoint yêu cầu quyền products_manage, thẻ <a href> tải trực tiếp sẽ không kèm token.
export const downloadProductImportTemplate = () =>
  http.get('/admin/products/import/template', { responseType: 'blob' }).then(r => r.data)
export const getAdminOrders = () => http.get('/admin/orders').then(r => r.data)
export const getAdminOrderDetail = (id) => http.get(`/admin/orders/${id}`).then(r => r.data)
export const getAdminCustomers = () => http.get('/admin/customers').then(r => r.data)
export const getAdminCustomerDetail = (id) => http.get(`/admin/customers/${id}`).then(r => r.data)
// Khách vãng lai / khách lẻ — tài khoản do POS tự tạo khi bán tại quầy (auth_provider='pos').
export const getWalkInCustomers = () => http.get('/admin/customers/walk-in').then(r => r.data)
export const updateCustomerRole = (id, role) => http.put(`/admin/customers/${id}/role`, { role }).then(r => r.data)
export const updateCustomerStatus = (id, isActive) => http.put(`/admin/customers/${id}/status`, { isActive }).then(r => r.data)
export const lockCustomer = (id, { reason, lockUntil, evidence }) => {
  const form = new FormData()
  form.append('reason', reason)
  if (lockUntil) form.append('lockUntil', lockUntil)
  if (evidence) form.append('evidence', evidence)
  return http.post(`/admin/customers/${id}/lock`, form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }).then(r => r.data)
}
export const getCustomerActivityLog = (id) => http.get(`/admin/customers/${id}/activity-log`).then(r => r.data)
export const getAdminCoupons = () => http.get('/admin/coupons').then(r => r.data)

export const getAdminProductDetail = (id) => http.get(`/admin/products/${id}`).then(r => r.data)
export const createAdminProduct = (payload) => http.post('/admin/products', payload).then(r => r.data)
export const updateAdminProduct = (id, payload) => http.put(`/admin/products/${id}`, payload).then(r => r.data)
export const deleteAdminProduct = (id) => http.delete(`/admin/products/${id}`).then(r => r.data)
export const uploadProductImage = (file) => {
  const form = new FormData()
  form.append('file', file)
  return http.post('/admin/upload/image', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  }).then(r => r.data.url)
}

export const generateAdminVariants = (options, variants) =>
  http.post('/admin/products/variants/generate', { options, variants }).then(r => r.data)

// Quản lý hội viên (gói trả phí) — CHỈ ADMIN gọi được (feature "membership_admin" không cấp cho
// phòng ban nào, backend trả 422 nếu không phải admin).
export const getMembers = () => http.get('/admin/membership/members').then(r => r.data)
export const getMemberDetail = (userId) => http.get(`/admin/membership/members/${userId}`).then(r => r.data)
export const getSubscriptionPlans = () => http.get('/admin/membership/plans').then(r => r.data)
export const updateSubscriptionPlan = (id, payload) =>
  http.put(`/admin/membership/plans/${id}`, payload).then(r => r.data)

export const getMyPermissions = () => http.get('/admin/permissions/me').then(r => r.data)
export const getPermissionMeta = () => http.get('/admin/permissions/meta').then(r => r.data)
export const getPermissionMatrix = () => http.get('/admin/permissions/matrix').then(r => r.data)
export const updatePermissionCell = (department, featureKey, permKeys) =>
  http.put(`/admin/permissions/matrix/${department}/${featureKey}`, { permKeys }).then(r => r.data)

export const getStaffAccounts = () => http.get('/admin/customers/staff').then(r => r.data)
export const createStaffAccount = (payload) => http.post('/admin/customers', payload).then(r => r.data)

// ===== Nhập kho theo chứng từ: nhà cung cấp + phiếu nhập nhiều dòng =====
// Xem GoodsReceiptService / AdminGoodsReceiptApiController.
export const getSuppliers = (tatCa = false) =>
  http.get('/admin/suppliers', { params: tatCa ? { tatCa: true } : {} }).then(r => r.data)
export const createSupplier = (payload) => http.post('/admin/suppliers', payload).then(r => r.data)
export const updateSupplier = (id, payload) => http.put(`/admin/suppliers/${id}`, payload).then(r => r.data)

export const getGoodsReceipts = () => http.get('/admin/goods-receipts').then(r => r.data)
export const getGoodsReceiptDetail = (id) => http.get(`/admin/goods-receipts/${id}`).then(r => r.data)
export const createGoodsReceipt = (payload) => http.post('/admin/goods-receipts', payload).then(r => r.data)

export const searchStockVariants = (keyword) =>
  http.get('/admin/stock-movements/variant-search', { params: { keyword } }).then(r => r.data)
export const createStockMovement = (payload) =>
  http.post('/admin/stock-movements', payload).then(r => r.data)
export const getRecentStockMovements = (limit = 50) =>
  http.get('/admin/stock-movements', { params: { limit } }).then(r => r.data)
export const getStockMovementsByVariant = (variantId) =>
  http.get(`/admin/stock-movements/variant/${variantId}`).then(r => r.data)

export const getAdminBrands = () => http.get('/admin/brands').then(r => r.data)
export const createAdminBrand = (name) => http.post('/admin/brands', { name }).then(r => r.data)
export const getCategories = () => http.get('/categories').then(r => r.data)

export const getAdminContacts = () => http.get('/admin/contacts').then(r => r.data)
export const getAdminContactDetail = (id) => http.get(`/admin/contacts/${id}`).then(r => r.data)
export const updateContactStatus = (id, status) => http.put(`/admin/contacts/${id}/status`, { status }).then(r => r.data)
export const replyContact = (id, reply) => http.post(`/admin/contacts/${id}/reply`, { reply }).then(r => r.data)

export const updateOrderStatus = (id, status, note) => http.put(`/admin/orders/${id}/status`, { status, note }).then(r => r.data)
export const confirmOrderPayment = (id) => http.put(`/admin/orders/${id}/confirm-payment`).then(r => r.data)

export const createCoupon = (payload) => http.post('/admin/coupons', payload).then(r => r.data)
export const deleteCoupon = (id) => http.delete(`/admin/coupons/${id}`)

export const getHpTiers = () => http.get('/admin/shipping/hp-tiers').then(r => r.data)
export const updateHpTier = (id, payload) => http.put(`/admin/shipping/hp-tiers/${id}`, payload).then(r => r.data)
export const getCarriers = () => http.get('/admin/shipping/carriers').then(r => r.data)
export const createCarrier = (payload) => http.post('/admin/shipping/carriers', payload).then(r => r.data)
export const updateCarrier = (id, payload) => http.put(`/admin/shipping/carriers/${id}`, payload).then(r => r.data)
export const deleteCarrier = (id) => http.delete(`/admin/shipping/carriers/${id}`)

export const createCategory = (name) => http.post('/admin/categories', { name }).then(r => r.data)

export const getAnalytics = () => http.get('/admin/analytics').then(r => r.data)
export const getCashFlow = (from, to, groupBy) =>
  http.get('/admin/cashflow', { params: { from, to, groupBy } }).then(r => r.data)
export const getCashFlowDetail = (from, to) =>
  http.get('/admin/cashflow/detail', { params: { from, to } }).then(r => r.data)
export const exportCashFlow = (from, to, groupBy) =>
  http.get('/admin/cashflow/export', { params: { from, to, groupBy }, responseType: 'blob' }).then(r => r.data)

export const getAdminWarranties = (status) => http.get('/admin/warranties', { params: status ? { status } : {} }).then(r => r.data)
export const getAdminWarrantyDetail = (id) => http.get(`/admin/warranties/${id}`).then(r => r.data)
export const updateWarrantyStatus = (id, status) => http.put(`/admin/warranties/${id}/status`, { status }).then(r => r.data)
export const getAdminWarrantyRequests = () => http.get('/admin/warranty-requests').then(r => r.data)
export const getAdminWarrantyRequestDetail = (id) => http.get(`/admin/warranty-requests/${id}`).then(r => r.data)
export const updateWarrantyRequestStatus = (id, status, note) => http.put(`/admin/warranty-requests/${id}/status`, { status, note }).then(r => r.data)
export const updateWarrantyRequestSchedule = (id, ngayHen) => http.put(`/admin/warranty-requests/${id}/schedule`, { ngayHen }).then(r => r.data)

export const getKitTemplates = () => http.get('/admin/kit-templates').then(r => r.data)
export const getKitTemplateDetail = (id) => http.get(`/admin/kit-templates/${id}`).then(r => r.data)
export const createKitTemplate = (payload) => http.post('/admin/kit-templates', payload).then(r => r.data)
export const updateKitTemplate = (id, payload) => http.put(`/admin/kit-templates/${id}`, payload).then(r => r.data)
export const deleteKitTemplate = (id) => http.delete(`/admin/kit-templates/${id}`)
export const searchKitVariants = (keyword, componentType) =>
  http.get('/admin/kit-templates/variant-search', { params: { keyword, componentType } }).then(r => r.data)

// ===== Flash sale (thuộc Quản lý khuyến mãi — quyền "coupons" bên backend) =====
// Lưu ý: create/update chỉ ghi BẢN NHÁP. Khách chỉ thấy sau khi gọi publishFlashSale().
export const getFlashSaleAdmin = () => http.get('/flash-sale/admin').then(r => r.data)
export const createFlashSale = (payload) => http.post('/flash-sale/admin', payload).then(r => r.data)
export const updateFlashSale = (id, payload) => http.put(`/flash-sale/admin/${id}`, payload).then(r => r.data)
export const publishFlashSale = (id) => http.post(`/flash-sale/admin/${id}/publish`).then(r => r.data)
export const unpublishFlashSale = (id) => http.post(`/flash-sale/admin/${id}/unpublish`).then(r => r.data)
export const searchProductsForSale = (q) =>
  http.get('/flash-sale/admin/products', { params: { q } }).then(r => r.data)

// ===== Thu cũ đổi mới (quyền "trade_in") =====
export const getTradeIns = (trangThai) =>
  http.get('/admin/trade-in', { params: trangThai ? { trangThai } : {} }).then(r => r.data)
export const getTradeIn = (id) => http.get(`/admin/trade-in/${id}`).then(r => r.data)
export const baoGiaTradeIn = (id, payload) => http.post(`/admin/trade-in/${id}/bao-gia`, payload).then(r => r.data)
export const chotGiaTradeIn = (id, payload) => http.post(`/admin/trade-in/${id}/chot-gia`, payload).then(r => r.data)
export const capTinDungTradeIn = (id) => http.post(`/admin/trade-in/${id}/cap-tin-dung`).then(r => r.data)
export const doiTrangThaiTradeIn = (id, trangThai, ghiChu) =>
  http.post(`/admin/trade-in/${id}/trang-thai/${trangThai}`, { ghiChu }).then(r => r.data)

// ===== Trung tâm hỗ trợ =====
// Hai quyền tách bạch bên backend (xem 66_support_center.sql):
//   support_content     -> trung tâm bảo hành, bảng giá, chính sách, FAQ (việc biên tập)
//   service_appointment -> lịch hẹn dịch vụ (việc trực hằng ngày của kỹ thuật)
export const getSupportCenters = () => http.get('/admin/support/trung-tam').then(r => r.data)
export const createSupportCenter = (payload) => http.post('/admin/support/trung-tam', payload).then(r => r.data)
export const updateSupportCenter = (id, payload) => http.put(`/admin/support/trung-tam/${id}`, payload).then(r => r.data)
export const deleteSupportCenter = (id) => http.delete(`/admin/support/trung-tam/${id}`)

export const getRepairPrices = () => http.get('/admin/support/bang-gia').then(r => r.data)
export const createRepairPrice = (payload) => http.post('/admin/support/bang-gia', payload).then(r => r.data)
export const updateRepairPrice = (id, payload) => http.put(`/admin/support/bang-gia/${id}`, payload).then(r => r.data)
export const deleteRepairPrice = (id) => http.delete(`/admin/support/bang-gia/${id}`)

export const getWarrantyPolicies = () => http.get('/admin/support/chinh-sach').then(r => r.data)
export const createWarrantyPolicy = (payload) => http.post('/admin/support/chinh-sach', payload).then(r => r.data)
export const updateWarrantyPolicy = (id, payload) => http.put(`/admin/support/chinh-sach/${id}`, payload).then(r => r.data)
export const deleteWarrantyPolicy = (id) => http.delete(`/admin/support/chinh-sach/${id}`)

export const getFaqItems = () => http.get('/admin/support/faq').then(r => r.data)
export const getFaqCategories = () => http.get('/admin/support/faq/danh-muc').then(r => r.data)
export const createFaqItem = (payload) => http.post('/admin/support/faq', payload).then(r => r.data)
export const updateFaqItem = (id, payload) => http.put(`/admin/support/faq/${id}`, payload).then(r => r.data)
export const deleteFaqItem = (id) => http.delete(`/admin/support/faq/${id}`)

export const getServiceAppointments = (trangThai) =>
  http.get('/admin/support/lich-hen', { params: trangThai ? { trangThai } : {} }).then(r => r.data)
// chiPhi chỉ có tác dụng khi trangThai='hoan_thanh' — backend bỏ qua ở các bước khác.
export const updateAppointmentStatus = (id, trangThai, ghiChu, chiPhi) =>
  http.post(`/admin/support/lich-hen/${id}/trang-thai`, { trangThai, ghiChu, chiPhi }).then(r => r.data)

// Tỉnh/thành cho form trung tâm bảo hành — endpoint công khai, dùng chung với phía khách.
export const getProvinces = () => http.get('/provinces').then(r => r.data)

// ===== Đổi trả hàng (quyền "return_request") =====
export const getReturns = (trangThai) =>
  http.get('/admin/returns', { params: trangThai ? { trangThai } : {} }).then(r => r.data)
export const updateReturnStatus = (id, trangThai, ghiChu) =>
  http.post(`/admin/returns/${id}/trang-thai`, { trangThai, ghiChu }).then(r => r.data)
// CSKH tự khởi tạo yêu cầu hộ khách: tra cứu đơn để chọn đúng dòng sản phẩm, rồi tạo.
export const lookupOrderForReturn = (maDon) =>
  http.get('/admin/returns/tra-cuu-don', { params: { maDon } }).then(r => r.data)
export const createReturn = (payload) =>
  http.post('/admin/returns', payload).then(r => r.data)

// ===== Tin tức / bài viết (quyền "articles") =====
export const getArticles = () => http.get('/admin/articles').then(r => r.data)
export const getArticleCategories = () => http.get('/admin/articles/categories').then(r => r.data)
export const createArticle = (payload) => http.post('/admin/articles', payload).then(r => r.data)
export const updateArticle = (id, payload) => http.put(`/admin/articles/${id}`, payload).then(r => r.data)
export const deleteArticle = (id) => http.delete(`/admin/articles/${id}`)
