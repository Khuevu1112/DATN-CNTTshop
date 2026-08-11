/**
 * Kiểm thử thang điểm so sánh linh kiện (src/data/compareRank.js).
 *
 * Chạy: npm test   (dùng test runner có sẵn của Node, không cần cài thêm gì)
 *
 * Thang điểm ở đây quyết định mũi tên ▲/▼ trong bảng So sánh, tức là trực tiếp nói với khách
 * "cái nào mạnh hơn" — sai một chỗ là tư vấn sai. Các ca dưới đây khoá lại những quan hệ mà
 * dân phần cứng đều biết chắc, để lần sau sửa công thức không âm thầm làm hỏng.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { chamDiem, soSanhO, goiY } from '../src/data/compareRank.js';

function manhHon(loai, a, b) {
  const da = chamDiem(loai, a);
  const db = chamDiem(loai, b);
  assert.notEqual(da, null, `không chấm được điểm: ${a}`);
  assert.notEqual(db, null, `không chấm được điểm: ${b}`);
  assert.ok(da > db, `"${a}" (${da}) phải mạnh hơn "${b}" (${db})`);
}

test('GPU: đời mới và phân khúc cao hơn thì mạnh hơn', () => {
  manhHon('GPU', 'NVIDIA RTX 4060 8GB', 'NVIDIA RTX 3050 8GB');
  manhHon('GPU', 'ASUS ROG Astral RTX 5080 16GB', 'RTX 4060 Ti');
  manhHon('GPU', 'RTX 4070 Ti', 'RTX 4070');
  // Bẫy dễ sai: 1660 phải hiểu là đời 16 phân khúc 60, không phải phân khúc 660.
  manhHon('GPU', 'RTX 3060', 'GTX 1660 Super');
  manhHon('GPU', 'RTX 3050', 'Intel UHD');
  manhHon('GPU', 'AMD Radeon RX 7600 XT', 'RX 6600');
});

test('GPU: lùi 1 đời nhưng lên 1 phân khúc thì xấp xỉ nhau', () => {
  const a = chamDiem('GPU', 'RTX 4070');
  const b = chamDiem('GPU', 'RTX 3080');
  assert.ok(Math.abs(a - b) <= 60, `RTX 4070 (${a}) và RTX 3080 (${b}) phải xấp xỉ nhau`);
});

test('CPU: bậc và thế hệ cao hơn thì mạnh hơn', () => {
  manhHon('CPU', 'Intel Core i7-13700K', 'Intel Core i5-13400F');
  manhHon('CPU', 'Intel Core i5-13400F', 'Intel Core i5-10400');
  manhHon('CPU', 'AMD Ryzen 9 7950X', 'AMD Ryzen 5 7600X');
  manhHon('CPU', 'Intel Core i3-12100F', 'Intel Pentium Gold G6405 (4.1GHz, 2 nhân 4 luồng)');
});

test('RAM / ổ cứng / nguồn / màn hình / chipset', () => {
  manhHon('RAM', 'G.Skill 32GB (2x16GB) DDR5 6000MHz', 'Corsair 16GB DDR4 3200MHz');
  manhHon('RAM', '16GB DDR5 5600MHz', '16GB DDR4 3200MHz');
  manhHon('SSD', 'Kingston SNV3S 1TB NVMe Gen4', 'Samsung 256GB SATA III');
  manhHon('PSU', 'ASUS ROG Thor 1200W Platinum III', 'MSI MAG A750BN 750W');
  manhHon('MONITOR', '27 inch 2K 165Hz', '23.8 inch 1080p 75Hz');
  manhHon('MAINBOARD', 'Chipset Z790', 'Chipset H610');
});

test('xếp hạng trong một hàng: cao nhất ▲, thấp nhất ▼, ở giữa —', () => {
  const ds = ['RTX 4080', 'RTX 4060', 'RTX 3050'].map((s) => chamDiem('GPU', s));
  const max = Math.max(...ds);
  const min = Math.min(...ds);
  assert.equal(soSanhO(ds[0], max, min), 'hon');
  assert.equal(soSanhO(ds[1], max, min), 'bang');
  assert.equal(soSanhO(ds[2], max, min), 'kem');
});

test('hai cột giống hệt nhau thì tương đương, thiếu dữ liệu thì không kết luận', () => {
  const d = chamDiem('GPU', 'RTX 4060');
  assert.equal(soSanhO(d, d, d), 'bang');
  assert.equal(soSanhO(null, 100, 50), null);
});

test('cảnh báo socket CPU không khớp chipset mainboard', () => {
  const g = goiY([
    { key: 'CPU', name: 'Intel Core i5-13400F' },
    { key: 'MAINBOARD', name: 'Mainboard Chipset B550' },
  ], false);
  assert.ok(g.some((x) => x.loai === 'canh_bao' && /LGA1700/.test(x.text)));
});

test('chipset khớp socket thì không cảnh báo', () => {
  const g = goiY([
    { key: 'CPU', name: 'Intel Core i5-13400F' },
    { key: 'MAINBOARD', name: 'Mainboard B760M' },
  ], false);
  assert.ok(!g.some((x) => x.loai === 'canh_bao' && /socket/.test(x.text)));
});

test('cảnh báo nguồn yếu so với card đồ hoạ', () => {
  const g = goiY([
    { key: 'GPU', name: 'RTX 4080' },
    { key: 'PSU', name: 'Nguồn 450W' },
  ], false);
  assert.ok(g.some((x) => x.loai === 'canh_bao' && /450W/.test(x.text)));
});

test('máy hoàn chỉnh: cảnh báo lệch CPU/GPU và gợi ý nâng RAM', () => {
  const g = goiY([
    { key: 'CPU', name: 'Intel Core i9-13900K' },
    { key: 'GPU', name: 'RTX 3050' },
    { key: 'RAM', name: '8GB DDR4' },
  ], true);
  assert.ok(g.some((x) => x.loai === 'canh_bao'), 'phải cảnh báo nghẽn ở GPU');
  assert.ok(g.some((x) => x.loai === 'nang_cap'), 'phải gợi ý nâng RAM 8GB');
});

test('cấu hình cân đối thì không cảnh báo lệch CPU/GPU', () => {
  const g = goiY([
    { key: 'CPU', name: 'Intel Core i5-13400F' },
    { key: 'GPU', name: 'RTX 4060' },
    { key: 'RAM', name: '16GB DDR5' },
  ], true);
  assert.ok(!g.some((x) => /nghẽn|kìm hiệu năng/.test(x.text)));
});
