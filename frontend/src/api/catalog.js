import http from './http'

export const getCategories = () =>
  http.get('/categories').then(r => r.data)

export const getProducts = (params = {}) =>
  http.get('/products', { params }).then(r => r.data)

export const getProductBySlug = (slug) =>
  http.get(`/products/${slug}`).then(r => r.data)
