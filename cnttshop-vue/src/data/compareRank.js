/**
 * Chấm điểm & so sánh linh kiện cho bảng So sánh cấu hình.
 *
 * Thông số sản phẩm trong DB là TEXT TỰ DO do admin nhập (PRODUCT_SPEC.spec_value, ví dụ
 * "NVIDIA RTX 4060 8GB", "Intel Core i5-13400F", "16GB DDR5 6000MHz") nên không thể so sánh
 * bằng phép so sánh chuỗi. Ở đây bóc số hiệu/thông số từ chuỗi rồi quy về THANG ĐIỂM chung để
 * biết cái nào mạnh hơn.
 *
 * Điểm chỉ dùng để XẾP THỨ TỰ tương đối trong bảng so sánh, không phải điểm benchmark thật —
 * mục tiêu là trả lời đúng "cái nào mạnh hơn", không phải "mạnh hơn bao nhiêu phần trăm".
 */

// ── GPU ────────────────────────────────────────────────────────────────────────
// Điểm = đời × 100 + phân khúc × 10. Cách này giữ đúng thực tế "lùi 1 đời nhưng lên 1 phân
// khúc thì xấp xỉ nhau" (RTX 4070 ≈ RTX 3080, RTX 4060 ≈ RTX 3070) — nếu cộng thêm một hằng
// số lớn theo dòng (RTX/GTX) thì mọi khoảng cách bị nén lại và card yếu trông ngang card mạnh.
function diemGpu(s) {
  const t = s.toLowerCase();
  // NVIDIA RTX/GTX: RTX 5080, RTX 4060 Ti, GTX 1660 Super...
  let m = t.match(/\b(rtx|gtx)\s*-?\s*(\d{3,4})\s*(ti|super)?/);
  if (m) {
    const so = parseInt(m[2], 10);
    let doi;
    let phanKhuc;
    if (so >= 2000) {
      doi = Math.floor(so / 1000); // 5080 -> 5, 4060 -> 4, 3050 -> 3, 2060 -> 2
      phanKhuc = (so % 1000) / 10; // 5080 -> 8, 4060 -> 6
    } else {
      // Dòng GTX 16xx/10xx: 1660 -> đời 1.6 phân khúc 60, KHÔNG phải phân khúc 660.
      doi = so >= 1600 ? 1.6 : 1;
      phanKhuc = (so % 100) / 10;
    }
    let d = doi * 100 + phanKhuc * 100;
    if (m[3] === 'ti') d += 60;
    if (m[3] === 'super') d += 40;
    return d;
  }
  // AMD Radeon RX 7600 / RX 6600 XT — quy về cùng thang với NVIDIA.
  m = t.match(/\brx\s*-?\s*(\d{3,4})\s*(xt|xtx)?/);
  if (m) {
    const so = parseInt(m[1], 10);
    // RX 7000 ngang đời RTX 4000, RX 6000 ngang RTX 3000...
    const doi = so >= 7000 ? 4 : so >= 6000 ? 3 : so >= 5000 ? 2 : 1;
    let d = doi * 100 + ((so % 1000) / 10) * 100;
    if (m[2] === 'xt') d += 60;
    if (m[2] === 'xtx') d += 110;
    return d;
  }
  // Intel Arc A770 / A750 — phân khúc tầm trung thấp.
  m = t.match(/\barc\s*a?(\d{3})/);
  if (m) return 200 + (parseInt(m[1], 10) % 100) * 8;
  // Card tích hợp — luôn yếu hơn card rời.
  if (/(uhd|iris|vega|tích hợp|onboard|igpu)/.test(t)) return 150;
  return null;
}

// Trần thang điểm của từng loại, dùng để quy về 0–100 khi cần SO CHÉO hai loại khác nhau
// (vd CPU mạnh hơn GPU bao nhiêu). Điểm thô của CPU và GPU không cùng đơn vị nên so trực tiếp
// là sai.
const TRAN_DIEM = { GPU: 1500, CPU: 2200 };
function chuanHoa(loai, diem) {
  if (diem == null) return null;
  return (diem / (TRAN_DIEM[loai] || 1)) * 100;
}

// ── CPU ────────────────────────────────────────────────────────────────────────
// Intel Core i3/i5/i7/i9 + thế hệ (2 số đầu của SKU), AMD Ryzen 3/5/7/9 + thế hệ.
function diemCpu(s) {
  const t = s.toLowerCase();
  // Intel Core i5-13400F / Core i7 12700K / Core Ultra 7 155H
  let m = t.match(/\bi([3579])\s*-?\s*(\d{4,5})/);
  if (m) {
    const bac = { 3: 1, 5: 2, 7: 3, 9: 4 }[m[1]];
    const sku = m[2];
    const doi = sku.length === 5 ? parseInt(sku.slice(0, 2), 10) : parseInt(sku.slice(0, 1), 10);
    return 500 + doi * 40 + bac * 260;
  }
  m = t.match(/\bcore\s+ultra\s+([3579])\b/);
  if (m) return 500 + 14 * 40 + { 3: 1, 5: 2, 7: 3, 9: 4 }[m[1]] * 260;
  // AMD Ryzen 5 7600X / Ryzen 9 5900X
  m = t.match(/\bryzen\s*([3579])\s*-?\s*(\d{4})/);
  if (m) {
    const bac = { 3: 1, 5: 2, 7: 3, 9: 4 }[m[1]];
    const doi = parseInt(m[2].slice(0, 1), 10);
    return 500 + doi * 60 + bac * 260;
  }
  // Dòng phổ thông: Pentium / Celeron / Athlon — luôn dưới Core i3 / Ryzen 3.
  if (/(pentium|celeron|athlon)/.test(t)) return 380;
  // Không rõ SKU thì bám vào số nhân nếu có: "24 nhân / 32 luồng"
  m = t.match(/(\d+)\s*nh[âa]n/);
  if (m) return 400 + parseInt(m[1], 10) * 22;
  return null;
}

// ── RAM ────────────────────────────────────────────────────────────────────────
// Dung lượng là yếu tố chính, thế hệ DDR và bus là phụ.
function diemRam(s) {
  const t = s.toLowerCase();
  const gb = t.match(/(\d+)\s*gb/);
  const ddr = t.match(/ddr\s*(\d)/);
  const bus = t.match(/(\d{4,5})\s*mhz/);
  if (!gb && !ddr && !bus) return null;
  let d = 0;
  if (gb) d += parseInt(gb[1], 10) * 20;
  if (ddr) d += parseInt(ddr[1], 10) * 60;
  if (bus) d += parseInt(bus[1], 10) / 100;
  return d;
}

// ── Ổ cứng ─────────────────────────────────────────────────────────────────────
// NVMe/PCIe nhanh hơn SATA; dung lượng và tốc độ đọc cộng thêm.
function diemO(s) {
  const t = s.toLowerCase();
  let d = null;
  const tb = t.match(/(\d+(?:[.,]\d+)?)\s*tb/);
  const gb = t.match(/(\d+)\s*gb/);
  if (tb) d = parseFloat(tb[1].replace(',', '.')) * 1024 * 0.35;
  else if (gb) d = parseInt(gb[1], 10) * 0.35;
  const doc = t.match(/(\d{3,5})\s*mb\/s/);
  if (doc) d = (d || 0) + parseInt(doc[1], 10) / 12;
  if (/nvme|pcie\s*5/.test(t)) d = (d || 0) + 220;
  else if (/pcie\s*4/.test(t)) d = (d || 0) + 180;
  else if (/pcie/.test(t)) d = (d || 0) + 120;
  else if (/sata/.test(t)) d = (d || 0) + 40;
  return d;
}

// ── Thông số dạng "số + đơn vị" ────────────────────────────────────────────────
function diemTheoSo(s, regex, heSo = 1) {
  const m = String(s).toLowerCase().match(regex);
  return m ? parseFloat(m[1].replace(',', '.')) * heSo : null;
}

/** Màn hình: tần số quét ưu tiên hơn kích thước; thời gian phản hồi THẤP hơn là tốt hơn. */
function diemManHinh(s) {
  const t = s.toLowerCase();
  let d = 0;
  let co = false;
  const hz = t.match(/(\d{2,3})\s*hz/);
  if (hz) { d += parseInt(hz[1], 10) * 3; co = true; }
  const inch = t.match(/(\d{2}(?:[.,]\d)?)\s*(?:inch|")/);
  if (inch) { d += parseFloat(inch[1].replace(',', '.')) * 6; co = true; }
  if (/8k/.test(t)) { d += 400; co = true; }
  else if (/4k|uhd|2160/.test(t)) { d += 300; co = true; }
  else if (/2k|qhd|1440|wqhd/.test(t)) { d += 200; co = true; }
  else if (/wuxga|1200/.test(t)) { d += 130; co = true; }
  else if (/fhd|1080/.test(t)) { d += 100; co = true; }
  return co ? d : null;
}

/** Chipset mainboard: hạng chipset quyết định khả năng ép xung / số làn PCIe. */
function diemChipset(s) {
  const t = s.toUpperCase();
  const bang = [
    [/X[67]\d0E?/, 900], [/Z[678]\d0/, 850], [/B[678]\d0/, 650],
    [/H[678]\d0/, 450], [/A[678]\d0/, 300],
    [/Z[45]\d0/, 700], [/B[45]\d0/, 520], [/H[45]\d0/, 380],
  ];
  for (const [re, d] of bang) if (re.test(t)) return d;
  return null;
}

/** Thời gian phản hồi màn hình / độ trễ: THẤP hơn = tốt hơn nên đảo dấu. */
function diemNguocMs(s) {
  const v = diemTheoSo(s, /(\d+(?:[.,]\d+)?)\s*ms/);
  return v == null ? null : -v;
}

/**
 * Mỗi loại linh kiện có 1 hàm chấm điểm riêng. Trả về null = không đủ dữ liệu để kết luận,
 * lúc đó bảng so sánh sẽ hiện "không so sánh được" thay vì đoán bừa.
 */
const CHAM_DIEM = {
  GPU: diemGpu,
  CPU: diemCpu,
  RAM: diemRam,
  SSD: diemO,
  HDD: diemO,
  MAINBOARD: (s) => diemChipset(s),
  PSU: (s) => diemTheoSo(s, /(\d{3,4})\s*w/),
  MONITOR: diemManHinh,
  MOUSE: (s) => diemTheoSo(s, /(\d{3,5})\s*dpi/),
  COOLER: null,
  CASE: null,
  KEYBOARD: null,
};

/** Các khoá thông số rời (không phải tên linh kiện) cũng so sánh được. */
const CHAM_DIEM_THONG_SO = [
  { re: /dung lư[ơợ]ng|dung luong/i, fn: diemO },
  { re: /t[ốô]c đ[ộo] đ[ọo]c|toc do doc/i, fn: (s) => diemTheoSo(s, /(\d{3,5})\s*mb\/s/) },
  { re: /c[ôo]ng su[ấâ]t|cong suat/i, fn: (s) => diemTheoSo(s, /(\d{3,4})\s*w/) },
  { re: /bus|t[ầâ]n s[ốo]/i, fn: (s) => diemTheoSo(s, /(\d{3,5})\s*mhz/) },
  { re: /đ[ộo] ph[âa]n gi[ảa]i|do phan giai|k[íi]ch thư[ớơ]c/i, fn: diemManHinh },
  { re: /th[ờơ]i gian ph[ảa]n h[ồô]i/i, fn: diemNguocMs },
  { re: /s[ốo] nh[âa]n|nh[âa]n\/lu[ồô]ng/i, fn: (s) => diemTheoSo(s, /(\d+)\s*nh[âa]n/, 22) },
  { re: /chipset/i, fn: diemChipset },
  { re: /dpi/i, fn: (s) => diemTheoSo(s, /(\d{3,5})\s*dpi/) },
  { re: /chu[ẩâ]n|giao ti[ếê]p/i, fn: diemO },
];

/**
 * Điểm của một ô trong bảng so sánh.
 * @param {string} khoaLinhKien khoá chuẩn hoá (CPU/GPU/RAM/...) hoặc nhãn thông số tự do
 * @param {string} giaTri chuỗi thông số hiển thị
 */
export function chamDiem(khoaLinhKien, giaTri) {
  if (!giaTri) return null;
  const fn = CHAM_DIEM[khoaLinhKien];
  if (fn) {
    const d = fn(giaTri);
    if (d != null) return d;
  }
  const theoNhan = CHAM_DIEM_THONG_SO.find((x) => x.re.test(khoaLinhKien || ''));
  if (theoNhan) return theoNhan.fn(giaTri);
  // Vẫn thử đoán theo nội dung — nhiều cấu hình ghi thẳng tên card/CPU vào ô tự do.
  return diemGpu(giaTri) ?? diemCpu(giaTri) ?? diemRam(giaTri) ?? null;
}

/**
 * So một ô với ô tốt nhất cùng hàng.
 * @returns {'hon'|'kem'|'bang'|null} null = không đủ dữ liệu để kết luận
 */
export function soSanhO(diem, diemTotNhat, diemKemNhat) {
  if (diem == null || diemTotNhat == null) return null;
  if (diemTotNhat === diemKemNhat) return 'bang';
  // Ngưỡng tính theo KHOẢNG CÁCH giữa cao nhất và thấp nhất của hàng, không theo giá trị tuyệt
  // đối: chênh dưới 5% khoảng đó mới coi là ngang nhau (vd RAM 3200MHz vs 3000MHz). Lấy theo
  // giá trị tuyệt đối sẽ nuốt mất khác biệt thật khi cả hàng đều là số lớn.
  const nguong = Math.abs(diemTotNhat - diemKemNhat) * 0.05;
  if (Math.abs(diem - diemTotNhat) <= nguong) return 'hon';
  if (diemKemNhat != null && Math.abs(diem - diemKemNhat) <= nguong) return 'kem';
  return 'bang';
}

export const KY_HIEU = {
  hon: { mui: '▲', mau: '#22c55e', nhan: 'Mạnh hơn' },
  kem: { mui: '▼', mau: '#ef4444', nhan: 'Yếu hơn' },
  bang: { mui: '—', mau: '#f59e0b', nhan: 'Tương đương' },
};

// ── Tương thích & đề xuất ──────────────────────────────────────────────────────

/** Socket CPU -> các chipset mainboard dùng được. Dùng để cảnh báo/đề xuất khi ghép linh kiện. */
const SOCKET_CHIPSET = {
  LGA1700: ['Z790', 'Z690', 'B760', 'B660', 'H770', 'H670', 'H610'],
  LGA1200: ['Z590', 'Z490', 'B560', 'B460', 'H510', 'H410'],
  LGA1851: ['Z890', 'B860', 'H810'],
  AM5: ['X670E', 'X670', 'B650E', 'B650', 'A620'],
  AM4: ['X570', 'B550', 'B450', 'A520', 'A320'],
};

function socketCuaCpu(s) {
  const t = String(s).toLowerCase();
  let m = t.match(/\bi[3579]\s*-?\s*(\d{4,5})/);
  if (m) {
    const doi = m[1].length === 5 ? parseInt(m[1].slice(0, 2), 10) : parseInt(m[1].slice(0, 1), 10);
    if (doi >= 12 && doi <= 14) return 'LGA1700';
    if (doi === 10 || doi === 11) return 'LGA1200';
    if (doi >= 15) return 'LGA1851';
  }
  m = t.match(/\bryzen\s*[3579]\s*-?\s*(\d{4})/);
  if (m) {
    const doi = parseInt(m[1].slice(0, 1), 10);
    if (doi >= 7) return 'AM5';
    if (doi >= 1 && doi <= 5) return 'AM4';
  }
  return null;
}

/** Ước công suất nguồn tối thiểu theo card đồ hoạ — con số an toàn thực dụng, không phải TDP thật. */
function nguonToiThieu(gpuText) {
  const d = diemGpu(gpuText || '');
  if (d == null) return null;
  if (d >= 1150) return 850; // 4080/5080 trở lên
  if (d >= 1050) return 750; // 4070 / 3080
  if (d >= 950) return 650; // 4060 / 3070
  if (d >= 850) return 550; // 3060
  return 450;
}

/**
 * Đề xuất dựa trên cấu hình đang so sánh.
 * @param {Array<{key:string, name:string}>} linhKien các dòng linh kiện của cấu hình mạnh nhất
 * @param {boolean} laThietBiHoanChinh true nếu đang so sánh laptop/PC nguyên bộ
 */
export function goiY(linhKien, laThietBiHoanChinh) {
  const ds = [];
  const lay = (k) => linhKien.find((i) => i.key === k)?.name || '';
  const cpu = lay('CPU');
  const gpu = lay('GPU');
  const main = lay('MAINBOARD');
  const psu = lay('PSU');
  const ram = lay('RAM');

  if (laThietBiHoanChinh) {
    const dGpu = diemGpu(gpu);
    const dCpu = diemCpu(cpu);
    if (dGpu != null && dGpu >= 1150) {
      ds.push({ loai: 'thiet_bi', text: 'Cấu hình đủ sức chơi game 2K/4K và dựng video — nên ghép màn 2K 165Hz trở lên để không phí card.' });
    } else if (dGpu != null && dGpu >= 950) {
      ds.push({ loai: 'thiet_bi', text: 'Phù hợp game FHD cấu hình cao và làm đồ hoạ vừa — màn 1080p 144Hz là điểm cân bằng tốt nhất.' });
    } else if (dGpu != null) {
      ds.push({ loai: 'thiet_bi', text: 'Thiên về học tập – văn phòng. Nếu cần chơi game nặng, ưu tiên nâng card đồ hoạ trước tiên.' });
    }
    // So chéo CPU với GPU phải quy về cùng thang 0–100, điểm thô hai loại không cùng đơn vị.
    const nCpu = chuanHoa('CPU', dCpu);
    const nGpu = chuanHoa('GPU', dGpu);
    if (nCpu != null && nGpu != null && nCpu - nGpu >= 20) {
      ds.push({ loai: 'canh_bao', text: 'CPU mạnh hơn hẳn card đồ hoạ — chơi game sẽ bị nghẽn ở card, cân nhắc nâng GPU.' });
    } else if (nCpu != null && nGpu != null && nGpu - nCpu >= 20) {
      ds.push({ loai: 'canh_bao', text: 'Card đồ hoạ mạnh hơn hẳn CPU — CPU sẽ kìm hiệu năng card ở game nặng CPU, cân nhắc nâng CPU.' });
    }
    if (/8\s*gb/i.test(ram)) {
      ds.push({ loai: 'nang_cap', text: 'RAM 8GB là mức tối thiểu hiện nay — nâng lên 16GB cho trải nghiệm mượt hơn rõ rệt.' });
    }
    return ds;
  }

  // So sánh linh kiện rời -> kiểm tra tương thích và đề xuất linh kiện đi kèm.
  const socket = socketCuaCpu(cpu);
  if (socket) {
    const dsChipset = SOCKET_CHIPSET[socket] || [];
    const khop = dsChipset.some((c) => new RegExp(c, 'i').test(main));
    if (main && !khop) {
      ds.push({ loai: 'canh_bao', text: `CPU dùng socket ${socket} nhưng mainboard đang chọn không thuộc nhóm tương thích (${dsChipset.slice(0, 4).join(', ')}…).` });
    } else if (!main) {
      ds.push({ loai: 'tuong_thich', text: `CPU dùng socket ${socket} — mainboard tương thích: ${dsChipset.slice(0, 5).join(', ')}.` });
    }
  }
  const wCan = nguonToiThieu(gpu);
  if (wCan) {
    const wCo = diemTheoSo(psu, /(\d{3,4})\s*w/);
    if (wCo != null && wCo < wCan) {
      ds.push({ loai: 'canh_bao', text: `Nguồn ${wCo}W thấp hơn mức khuyến nghị ${wCan}W cho card đồ hoạ này — dễ sập nguồn khi tải nặng.` });
    } else if (wCo == null) {
      ds.push({ loai: 'tuong_thich', text: `Card đồ hoạ này nên đi với nguồn từ ${wCan}W trở lên (80+ Bronze).` });
    }
  }
  if (/ddr5/i.test(ram) && /b[45]\d0|x570|z[45]\d0/i.test(main)) {
    ds.push({ loai: 'canh_bao', text: 'RAM DDR5 không lắp được lên mainboard đời DDR4 — kiểm tra lại chuẩn RAM của bo mạch.' });
  }
  return ds;
}

/**
 * Phân loại cấu hình theo hướng tài chính hay hiệu năng: so điểm hiệu năng với giá.
 * Cấu hình nào có nhiều điểm trên mỗi triệu đồng thì thiên về tài chính (đáng tiền), cấu hình
 * điểm tuyệt đối cao nhất thì thiên về hiệu năng.
 */
export function phanLoaiHuong(dsCauHinh) {
  const co = dsCauHinh.filter((c) => c.tongDiem > 0 && c.totalPrice > 0);
  if (co.length < 2) return {};
  const nhan = {};
  const manh = co.reduce((a, b) => (b.tongDiem > a.tongDiem ? b : a));
  const dangTien = co.reduce((a, b) =>
    b.tongDiem / b.totalPrice > a.tongDiem / a.totalPrice ? b : a);
  nhan[manh.key] = { text: 'Hiệu năng cao nhất', mau: '#22c55e' };
  if (dangTien.key !== manh.key) {
    nhan[dangTien.key] = { text: 'Đáng tiền nhất', mau: '#38bdf8' };
  }
  return nhan;
}
