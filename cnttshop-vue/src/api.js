// ===== Lớp gọi REST API backend (Spring Boot :8080) =====
const BASE = 'http://localhost:8080/api';

function authHeaders() {
  const t = localStorage.getItem('token');
  return t ? { Authorization: 'Bearer ' + t } : {};
}

async function get(path) {
  const res = await fetch(BASE + path, { headers: { ...authHeaders() } });
  if (!res.ok) throw new Error('HTTP ' + res.status);
  return res.json();
}

export const fetchCategories = () => get('/categories');

export const fetchProducts = (params = {}) => {
  const q = new URLSearchParams();
  if (params.categorySlug) q.set('categorySlug', params.categorySlug);
  if (params.keyword) q.set('keyword', params.keyword);
  if (params.sort) q.set('sort', params.sort);
  const qs = q.toString();
  return get('/products' + (qs ? '?' + qs : ''));
};

export const fetchProductBySlug = (slug) =>
  get('/products/' + encodeURIComponent(slug));

async function post(path, body) {
  const res = await fetch(BASE + path, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...authHeaders() },
    body: JSON.stringify(body),
  });
  if (!res.ok) {
    let msg = 'HTTP ' + res.status;
    try {
      const j = await res.json();
      if (j && j.message) msg = j.message;
    } catch (e) {}
    throw new Error(msg);
  }
  return res.json().catch(() => ({}));
}

// Auth (JWT)
export const login = (payload) => post('/auth/login', payload);
export const register = (payload) => post('/auth/register', payload);
export const me = () => get('/auth/me');
