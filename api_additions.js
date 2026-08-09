// ===== Bổ sung vào cuối file api.js hiện tại =====

async function del(path) {
  const res = await fetch(BASE + path, {
    method: 'DELETE',
    headers: { ...authHeaders() },
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

// Chat history (chỉ áp dụng cho user đã đăng nhập - cần JWT trong authHeaders())
export const getChatHistory = () => get('/chat/history');

export const saveChatMessage = (role, content, metadata = null) =>
  post('/chat/messages', { role, content, metadata });

export const clearChatHistory = () => del('/chat/history');
