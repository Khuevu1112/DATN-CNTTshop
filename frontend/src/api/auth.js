import http from './http'

export const login = (payload) =>
  http.post('/auth/login', payload).then(r => r.data)

export const register = (payload) =>
  http.post('/auth/register', payload).then(r => r.data)

export const me = () =>
  http.get('/auth/me').then(r => r.data)
