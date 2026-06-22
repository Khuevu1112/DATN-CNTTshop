<script setup>
const year = new Date().getFullYear()
</script>

<template>
  <footer class="site-footer">
    <div class="wrap footer-grid">
      <div class="footer-col">
        <router-link to="/" class="brand" style="margin-bottom:14px">
          <span class="brand-logo" style="width:26px;height:26px"></span>
          <span class="brand-text" style="font-size:18px">CNTT<span>shop</span></span>
        </router-link>
        <p style="font-size:13px;color:var(--muted);line-height:1.6;max-width:280px">
          Hệ thống bán lẻ PC Gaming, laptop & linh kiện chính hãng. Build theo yêu cầu, bảo hành tận tâm.
        </p>
      </div>
      <div class="footer-col">
        <h6>Sản phẩm</h6>
        <a href="#">Laptop Gaming</a><a href="#">PC dựng sẵn</a><a href="#">Linh kiện</a><a href="#">Màn hình</a>
      </div>
      <div class="footer-col">
        <h6>Hỗ trợ</h6>
        <a href="#">Bảo hành</a><a href="#">Trả góp 0%</a><a href="#">Giao hàng</a><a href="#">Đổi trả</a>
      </div>
      <div class="footer-col">
        <h6>Liên hệ</h6>
        <span>Hotline: 1900 1903</span><span>cskh@cnttshop.vn</span><span>Hà Nội · TP.HCM</span>
      </div>
    </div>
    <div class="footer-bottom">© {{ year }} CNTTshop · Đồ án tốt nghiệp · Phục vụ mục đích học tập</div>
  </footer>
</template>
