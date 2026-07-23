// Hiệu ứng "bay vào giỏ hàng" khi thêm sản phẩm — tạo 1 element clone bay từ vị trí nút bấm
// tới icon giỏ hàng trên header, không cần Pinia/event-bus: icon giỏ hàng chỉ cần có id cố định
// (#app-cart-icon, xem AppHeader.vue) để tìm toạ độ đích tại đúng thời điểm bay.

export function flyToCart(sourceEl, imageUrl) {
  const cartEl = document.getElementById('app-cart-icon');
  if (!sourceEl || !cartEl) return;

  const startRect = sourceEl.getBoundingClientRect();
  const endRect = cartEl.getBoundingClientRect();
  const SIZE = 46;

  const flyer = document.createElement('div');
  flyer.className = 'fly-to-cart-ghost';
  flyer.style.left = startRect.left + startRect.width / 2 - SIZE / 2 + 'px';
  flyer.style.top = startRect.top + startRect.height / 2 - SIZE / 2 + 'px';
  flyer.style.width = SIZE + 'px';
  flyer.style.height = SIZE + 'px';
  if (imageUrl) {
    flyer.style.backgroundImage = `url(${imageUrl})`;
  } else {
    flyer.style.background = 'var(--acc, #c6ff4a)';
  }
  document.body.appendChild(flyer);

  const dx = endRect.left + endRect.width / 2 - (startRect.left + startRect.width / 2);
  const dy = endRect.top + endRect.height / 2 - (startRect.top + startRect.height / 2);

  requestAnimationFrame(() => {
    flyer.style.transform = `translate(${dx}px, ${dy}px) scale(0.15)`;
    flyer.style.opacity = '0.25';
  });

  const cleanup = () => {
    flyer.remove();
    cartEl.classList.add('cart-icon-bump');
    setTimeout(() => cartEl.classList.remove('cart-icon-bump'), 320);
  };
  flyer.addEventListener('transitionend', cleanup, { once: true });
  setTimeout(cleanup, 750); // phòng khi transitionend không bắn (tab ẩn, v.v.)
}
