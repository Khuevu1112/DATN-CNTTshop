// ===== Static catalog data + pricing helpers =====

export const accents = { cyan: '#00e5ff', magenta: '#ff45e0' }

export const catMeta = {
  laptop:   { vn: 'Laptop',      en: 'LAPTOPS',    hue: 210 },
  pc:       { vn: 'PC Gaming',   en: 'DESKTOP PC', hue: 265 },
  linhkien: { vn: 'Linh kiện',   en: 'COMPONENTS', hue: 158 },
  manhinh:  { vn: 'Màn hình',    en: 'MONITORS',   hue: 190 },
  gear:     { vn: 'Gaming Gear', en: 'GEAR',       hue: 328 }
}

export const products = [
  {id:1,cat:'laptop',brand:'Asus',name:'Laptop Gaming Asus ROG Strix G16',price:32990000,oldPrice:35990000,rating:4.8,reviews:214,badge:'HOT',hue:210,featured:true,specs:[{k:'CPU',v:'Intel Core i7-13650HX'},{k:'Card đồ họa',v:'RTX 4060 8GB'},{k:'RAM',v:'16GB DDR5'},{k:'Màn hình',v:'16" 165Hz'},{k:'Ổ cứng',v:'512GB SSD'}],cfg:[{key:'ram',label:'RAM',ch:[{l:'16GB DDR5',d:0},{l:'32GB DDR5',d:2200000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'512GB SSD',d:0},{l:'1TB SSD',d:1400000}]}]},
  {id:2,cat:'laptop',brand:'MSI',name:'Laptop MSI Katana 15 B13V',price:24490000,oldPrice:26990000,rating:4.6,reviews:98,badge:'',hue:206,featured:false,specs:[{k:'CPU',v:'Intel Core i5-13420H'},{k:'Card đồ họa',v:'RTX 4050 6GB'},{k:'RAM',v:'16GB DDR5'},{k:'Màn hình',v:'15.6" 144Hz'},{k:'Ổ cứng',v:'512GB SSD'}],cfg:[{key:'ram',label:'RAM',ch:[{l:'16GB DDR5',d:0},{l:'32GB DDR5',d:2200000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'512GB SSD',d:0},{l:'1TB SSD',d:1400000}]}]},
  {id:3,cat:'laptop',brand:'Acer',name:'Laptop Acer Nitro V15',price:19990000,oldPrice:0,rating:4.5,reviews:143,badge:'',hue:200,featured:false,specs:[{k:'CPU',v:'Intel Core i5-13420H'},{k:'Card đồ họa',v:'RTX 3050 6GB'},{k:'RAM',v:'8GB DDR5'},{k:'Màn hình',v:'15.6" 144Hz'},{k:'Ổ cứng',v:'512GB SSD'}]},
  {id:4,cat:'laptop',brand:'Lenovo',name:'Laptop Lenovo LOQ 15IRX9',price:22490000,oldPrice:23990000,rating:4.7,reviews:76,badge:'',hue:216,featured:false,specs:[{k:'CPU',v:'Intel Core i5-12450HX'},{k:'Card đồ họa',v:'RTX 4050 6GB'},{k:'RAM',v:'16GB DDR5'},{k:'Màn hình',v:'15.6" 144Hz'},{k:'Ổ cứng',v:'512GB SSD'}]},
  {id:5,cat:'pc',brand:'CNTTshop',name:'PC Gaming CNTT Titan RTX 4070',price:38500000,oldPrice:41000000,rating:4.9,reviews:57,badge:'BUILD',hue:265,featured:true,specs:[{k:'CPU',v:'Intel Core i5-14400F'},{k:'Card đồ họa',v:'RTX 4070 12GB'},{k:'RAM',v:'32GB DDR5'},{k:'Ổ cứng',v:'1TB NVMe SSD'},{k:'Nguồn',v:'750W 80+ Gold'}],cfg:[{key:'cpu',label:'CPU',ch:[{l:'Intel Core i5-14400F',d:0},{l:'Intel Core i7-14700F',d:3500000}]},{key:'gpu',label:'Card đồ họa',ch:[{l:'RTX 4070 12GB',d:0},{l:'RTX 4070 Ti Super 16GB',d:5000000}]},{key:'ram',label:'RAM',ch:[{l:'32GB DDR5',d:0},{l:'64GB DDR5',d:2800000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'1TB NVMe SSD',d:0},{l:'2TB NVMe SSD',d:1500000}]}]},
  {id:6,cat:'pc',brand:'CNTTshop',name:'PC Gaming CNTT Spark RTX 4060',price:24900000,oldPrice:0,rating:4.8,reviews:89,badge:'',hue:260,featured:true,specs:[{k:'CPU',v:'Intel Core i5-12400F'},{k:'Card đồ họa',v:'RTX 4060 8GB'},{k:'RAM',v:'16GB DDR5'},{k:'Ổ cứng',v:'512GB NVMe SSD'},{k:'Nguồn',v:'650W 80+ Bronze'}],cfg:[{key:'cpu',label:'CPU',ch:[{l:'Intel Core i5-12400F',d:0},{l:'Intel Core i5-14400F',d:2000000}]},{key:'gpu',label:'Card đồ họa',ch:[{l:'RTX 4060 8GB',d:0},{l:'RTX 4060 Ti 8GB',d:3000000}]},{key:'ram',label:'RAM',ch:[{l:'16GB DDR5',d:0},{l:'32GB DDR5',d:1400000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'512GB NVMe SSD',d:0},{l:'1TB NVMe SSD',d:900000}]}]},
  {id:7,cat:'pc',brand:'CNTTshop',name:'PC Văn Phòng CNTT Office Pro',price:9990000,oldPrice:0,rating:4.7,reviews:210,badge:'',hue:252,featured:false,specs:[{k:'CPU',v:'Intel Core i3-12100'},{k:'Card đồ họa',v:'Intel UHD 730'},{k:'RAM',v:'16GB DDR4'},{k:'Ổ cứng',v:'512GB NVMe SSD'},{k:'Nguồn',v:'400W'}],cfg:[{key:'cpu',label:'CPU',ch:[{l:'Intel Core i3-12100',d:0},{l:'Intel Core i5-12400',d:1800000}]},{key:'ram',label:'RAM',ch:[{l:'16GB DDR4',d:0},{l:'32GB DDR4',d:1100000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'512GB NVMe SSD',d:0},{l:'1TB NVMe SSD',d:800000}]}]},
  {id:8,cat:'pc',brand:'CNTTshop',name:'PC Gaming CNTT Apex RTX 4080 Super',price:62900000,oldPrice:67000000,rating:5.0,reviews:33,badge:'TOP',hue:270,featured:true,specs:[{k:'CPU',v:'Intel Core i7-14700F'},{k:'Card đồ họa',v:'RTX 4080 Super 16GB'},{k:'RAM',v:'32GB DDR5'},{k:'Ổ cứng',v:'2TB NVMe SSD'},{k:'Nguồn',v:'1000W 80+ Gold'}],cfg:[{key:'cpu',label:'CPU',ch:[{l:'Intel Core i7-14700F',d:0},{l:'Intel Core i9-14900F',d:4500000}]},{key:'gpu',label:'Card đồ họa',ch:[{l:'RTX 4080 Super 16GB',d:0},{l:'RTX 4090 24GB',d:18000000}]},{key:'ram',label:'RAM',ch:[{l:'32GB DDR5',d:0},{l:'64GB DDR5',d:2800000}]},{key:'ssd',label:'Ổ cứng',ch:[{l:'2TB NVMe SSD',d:0},{l:'4TB NVMe SSD',d:3200000}]}]},
  {id:9,cat:'linhkien',brand:'AMD',name:'CPU AMD Ryzen 7 7800X3D',price:9490000,oldPrice:10490000,rating:4.9,reviews:302,badge:'',hue:160,featured:false,specs:[{k:'Nhân / Luồng',v:'8 nhân / 16 luồng'},{k:'Xung nhịp',v:'Tối đa 5.0GHz'},{k:'Socket',v:'AM5'},{k:'TDP',v:'120W'},{k:'Bộ nhớ đệm',v:'96MB L3'}]},
  {id:10,cat:'linhkien',brand:'NVIDIA',name:'VGA NVIDIA RTX 4070 Ti Super',price:22990000,oldPrice:0,rating:4.8,reviews:121,badge:'',hue:165,featured:false,specs:[{k:'Bộ nhớ',v:'16GB GDDR6X'},{k:'Xung Boost',v:'2610 MHz'},{k:'Cổng xuất',v:'3x DP, 1x HDMI'},{k:'TDP',v:'285W'},{k:'Kích thước',v:'3.0 slot'}]},
  {id:11,cat:'linhkien',brand:'Corsair',name:'RAM Corsair Vengeance 32GB DDR5',price:2690000,oldPrice:2990000,rating:4.7,reviews:188,badge:'',hue:150,featured:false,specs:[{k:'Dung lượng',v:'32GB (2x16GB)'},{k:'Bus',v:'6000 MHz'},{k:'Chuẩn',v:'DDR5'},{k:'Tản nhiệt',v:'Nhôm CL30'},{k:'Đèn',v:'Không RGB'}]},
  {id:12,cat:'linhkien',brand:'Samsung',name:'SSD Samsung 990 Pro 2TB',price:4290000,oldPrice:0,rating:4.9,reviews:265,badge:'',hue:155,featured:false,specs:[{k:'Dung lượng',v:'2TB'},{k:'Tốc độ đọc',v:'7450 MB/s'},{k:'Chuẩn',v:'M.2 NVMe'},{k:'Giao tiếp',v:'PCIe 4.0'},{k:'Bảo hành',v:'5 năm'}]},
  {id:13,cat:'manhinh',brand:'LG',name:'Màn hình LG UltraGear 27GR75Q',price:7990000,oldPrice:8990000,rating:4.8,reviews:142,badge:'',hue:190,featured:false,specs:[{k:'Kích thước',v:'27" QHD'},{k:'Tần số quét',v:'165Hz'},{k:'Tấm nền',v:'IPS'},{k:'Thời gian đáp ứng',v:'1ms GtG'},{k:'Đồng bộ',v:'G-Sync Compatible'}]},
  {id:14,cat:'manhinh',brand:'Samsung',name:'Màn hình Samsung Odyssey G6',price:9490000,oldPrice:0,rating:4.7,reviews:77,badge:'NEW',hue:185,featured:true,specs:[{k:'Kích thước',v:'27" QHD'},{k:'Tần số quét',v:'240Hz'},{k:'Độ cong',v:'1000R'},{k:'HDR',v:'HDR600'},{k:'Đồng bộ',v:'FreeSync Premium'}]},
  {id:15,cat:'gear',brand:'Keychron',name:'Bàn phím cơ Keychron Q1 Pro',price:3490000,oldPrice:0,rating:4.8,reviews:96,badge:'',hue:330,featured:false,specs:[{k:'Layout',v:'75%'},{k:'Kết nối',v:'Bluetooth / USB-C'},{k:'Switch',v:'Gateron Pro'},{k:'Hotswap',v:'Có'},{k:'Vỏ',v:'Nhôm CNC'}]},
  {id:16,cat:'gear',brand:'Logitech',name:'Chuột Logitech G Pro X Superlight 2',price:2890000,oldPrice:3190000,rating:4.9,reviews:341,badge:'',hue:325,featured:false,specs:[{k:'Trọng lượng',v:'60g'},{k:'Cảm biến',v:'HERO 2'},{k:'DPI',v:'32000'},{k:'Kết nối',v:'Không dây Lightspeed'},{k:'Pin',v:'95 giờ'}]}
]

export const trust = [
  { icon: '🚚', title: 'Giao nhanh 2h',        sub: 'Nội thành HN & HCM' },
  { icon: '🛡️', title: 'Bảo hành 36 tháng',    sub: '1 đổi 1 tận nơi' },
  { icon: '💳', title: 'Trả góp 0%',           sub: 'Duyệt nhanh 15 phút' },
  { icon: '✅', title: 'Chính hãng 100%',      sub: 'Hoàn tiền nếu fake' }
]

export const fmt = (n) => n.toLocaleString('vi-VN') + '₫'

export const defaultSel = (p) => {
  const o = {}
  if (p && p.cfg) p.cfg.forEach(g => { o[g.key] = 0 })
  return o
}

export const priceWith = (p, sel) => {
  let t = p.price
  if (p.cfg) p.cfg.forEach(g => {
    const i = (sel && sel[g.key] != null) ? sel[g.key] : 0
    t += g.ch[i].d
  })
  return t
}

export const cfgKey = (p, sel) => {
  if (!p || !p.cfg) return 'p' + p.id
  return 'p' + p.id + '|' + p.cfg.map(g => g.key + ((sel && sel[g.key] != null) ? sel[g.key] : 0)).join('-')
}

export const productById = (id) => products.find(p => p.id === id)
