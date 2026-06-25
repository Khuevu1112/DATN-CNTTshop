import http from './http'

export const getDashboard = () => http.get('/admin/dashboard').then(r => r.data)

export const getNotifications = () => http.get('/admin/notifications').then(r => r.data)
export const getUnreadCount = () => http.get('/admin/notifications/unread-count').then(r => r.data.count)
export const markNotificationRead = (id) => http.post(`/admin/notifications/${id}/read`)
export const markAllNotificationsRead = () => http.post('/admin/notifications/read-all')
