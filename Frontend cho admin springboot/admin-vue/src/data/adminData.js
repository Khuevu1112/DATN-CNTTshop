// Data layer ported from the admin design — dữ liệu PC/laptop thật theo schema dự án Spring Boot.
export const money = n => n.toLocaleString('vi-VN') + '₫'
export function short(n){
  if(n>=1e9) return (n/1e9).toFixed(n>=1e10?0:1).replace('.0','')+' tỷ'
  if(n>=1e6) return (n/1e6).toFixed(n>=1e7?0:1).replace('.0','')+'tr'
  if(n>=1e3) return Math.round(n/1e3)+'k'
  return n+''
}
export const grad      = h => 'linear-gradient(135deg,hsl('+h+' 45% 22%),hsl('+h+' 55% 12%))'
export const gradText  = h => 'hsl('+h+' 70% 75%)'
export const gradAvatar= h => 'linear-gradient(135deg,hsl('+h+' 50% 40%),hsl('+h+' 60% 26%))'
export const gradCat   = h => 'linear-gradient(135deg,hsl('+h+' 50% 22%),hsl('+h+' 60% 11%))'
export const initials  = name => name.split(' ').slice(-2).map(w=>w[0]).join('').toUpperCase()

export const CATS = {
  'laptop':{label:'Laptop',hue:210}, 'pc-may-tinh-ban':{label:'PC bàn',hue:265},
  'linh-kien':{label:'Linh kiện',hue:150}, 'man-hinh':{label:'Màn hình',hue:190},
  'ngoai-vi':{label:'Ngoại vi',hue:32}, 'phu-kien':{label:'Phụ kiện',hue:330}
}
export const STATUS = {
  pending:{label:'Chờ xác nhận',color:'#ffb43b'}, confirmed:{label:'Đã xác nhận',color:'#00e5ff'},
  processing:{label:'Đang xử lý',color:'#7aa2ff'}, shipped:{label:'Đang giao',color:'#a855f7'},
  delivered:{label:'Đã giao',color:'#22d39a'}, cancelled:{label:'Đã huỷ',color:'#ff3b5c'},
  refunded:{label:'Hoàn tiền',color:'#94a3b8'}
}
const stBgOf = c => 'color-mix(in srgb,'+c+' 16%, transparent)'

const RAW_PRODUCTS = [
  ['Laptop ASUS TUF Gaming F15','laptop','ASUS','TUF',22990000,25990000,15,'i7 · RTX 4060 · 144Hz'],
  ['Laptop Dell XPS 13','laptop','Dell','XPS',31490000,0,8,'i7 · 13.4" · siêu mỏng'],
  ['Laptop ASUS ROG Strix G16','laptop','ASUS','ROG',32990000,35990000,12,'i7 · RTX 4060 · 16GB'],
  ['Laptop MSI Katana 15','laptop','MSI','KAT',24490000,26990000,9,'i5 · RTX 4050 · 16GB'],
  ['Laptop Acer Nitro V15','laptop','ACER','NIT',19990000,0,15,'i5 · RTX 3050 · 8GB'],
  ['Laptop Dell G15 5530','laptop','Dell','G15',23490000,25000000,7,'i7 · RTX 4050 · 16GB'],
  ['PC Gaming MSI Aegis','pc-may-tinh-ban','MSI','AEG',35000000,37500000,5,'Dựng sẵn cao cấp'],
  ['PC CNTT Titan RTX 4070','pc-may-tinh-ban','Gigabyte','TIT',38500000,41000000,6,'i5 · RTX 4070 · 32GB'],
  ['PC CNTT Spark RTX 4060','pc-may-tinh-ban','Gigabyte','SPK',24900000,0,10,'i5 · RTX 4060 · 16GB'],
  ['PC Văn phòng CNTT Office Pro','pc-may-tinh-ban','Intel','OFF',9990000,0,20,'i3 · UHD 730 · 16GB'],
  ['PC CNTT Apex RTX 4080 Super','pc-may-tinh-ban','Gigabyte','APX',62900000,67000000,4,'i7 · RTX 4080S · 32GB'],
  ['CPU Intel Core i5-13400F','linh-kien','Intel','I54',4690000,5200000,30,'10 nhân · LGA1700'],
  ['CPU AMD Ryzen 7 7800X3D','linh-kien','AMD','7X3',9490000,10490000,25,'8 nhân · AM5 · 5.0GHz'],
  ['CPU Intel Core i5-14400F','linh-kien','Intel','I54',4790000,0,30,'10 nhân · 4.7GHz'],
  ['Card NVIDIA RTX 4060','linh-kien','NVIDIA','406',8990000,0,12,'8GB GDDR6'],
  ['VGA NVIDIA RTX 4070 Ti Super','linh-kien','NVIDIA','47T',22990000,0,8,'16GB GDDR6X · 285W'],
  ['RAM Corsair Vengeance 32GB DDR5','linh-kien','Corsair','RAM',2690000,2990000,40,'2x16GB · 6000MHz'],
  ['SSD Samsung 990 Pro 2TB','linh-kien','Samsung','SSD',4290000,0,35,'7450MB/s · NVMe 4.0'],
  ['Màn hình Samsung Odyssey 27"','man-hinh','Samsung','OD27',6490000,7200000,20,'27" · 165Hz · VA'],
  ['Màn hình LG UltraGear 27GR75Q','man-hinh','LG','LG27',7990000,8990000,14,'27" QHD · 165Hz · IPS'],
  ['Màn hình Samsung Odyssey G6','man-hinh','Samsung','G6',9490000,0,11,'27" QHD · 240Hz'],
  ['Màn hình Asus TUF VG27AQ','man-hinh','ASUS','VG27',6490000,7200000,18,'27" QHD · 165Hz · IPS'],
  ['Bàn phím cơ AKKO 3068','ngoai-vi','AKKO','AKK',1290000,0,40,'68 phím · không dây'],
  ['Bàn phím Keychron Q1 Pro','ngoai-vi','Keychron','Q1',3490000,0,22,'75% · Gateron Pro'],
  ['Chuột Logitech G Pro X Superlight 2','ngoai-vi','Logitech','GPX',2890000,3190000,27,'60g · HERO 2 · 32K DPI'],
  ['Tai nghe Logitech G733','phu-kien','Logitech','733',2290000,2690000,19,'7.1 · Lightspeed · RGB'],
  ['Lót chuột Corsair MM300 Extended','phu-kien','Corsair','MM3',390000,0,50,'930x300 · vải dệt'],
]
export const PRODUCTS = RAW_PRODUCTS.map((r,i)=>{
  const [name,cs,brand,tag,price,oldp,stock,spec]=r
  return { id:1001+i, name, catSlug:cs, cat:CATS[cs].label, hue:CATS[cs].hue, brand, tag, sku:'SKU-'+(1001+i),
    price, oldp, stock, spec, active:i!==9 && i!==26, priceFmt:money(price), oldFmt:oldp?money(oldp):'',
    disc:oldp?Math.round((1-price/oldp)*100):0 }
})

const RAW_ORDERS = [
  ['DH240615','Nguyễn Văn An','an.nguyen@gmail.com',32990000,'delivered','15/06 09:42','Laptop ASUS ROG Strix G16'],
  ['DH240614','Trần Thị Bình','binh.tran@gmail.com',13280000,'shipped','15/06 08:10','RTX 4060 + RAM Corsair'],
  ['DH240613','Lê Hoàng Cường','cuong.le@outlook.com',62900000,'processing','14/06 21:30','PC CNTT Apex RTX 4080S'],
  ['DH240612','Phạm Minh Dũng','dung.pham@gmail.com',4290000,'confirmed','14/06 17:05','SSD Samsung 990 Pro 2TB'],
  ['DH240611','Vũ Thị Hà','ha.vu@gmail.com',24900000,'pending','14/06 15:48','PC CNTT Spark RTX 4060'],
  ['DH240610','Đỗ Quang Huy','huy.do@gmail.com',9490000,'delivered','13/06 11:20','CPU AMD Ryzen 7 7800X3D'],
  ['DH240609','Bùi Thanh Lan','lan.bui@yahoo.com',7990000,'cancelled','13/06 10:02','Màn LG UltraGear 27GR75Q'],
  ['DH240608','Hồ Văn Mạnh','manh.ho@gmail.com',38500000,'delivered','12/06 19:15','PC CNTT Titan RTX 4070'],
  ['DH240607','Ngô Thị Ngọc','ngoc.ngo@gmail.com',2890000,'refunded','12/06 14:33','Chuột Logitech G Pro X SL2'],
  ['DH240606','Dương Văn Phú','phu.duong@gmail.com',31490000,'shipped','12/06 09:50','Laptop Dell XPS 13'],
  ['DH240605','Lý Thị Quỳnh','quynh.ly@gmail.com',6490000,'delivered','11/06 16:40','Màn Samsung Odyssey 27"'],
  ['DH240604','Trịnh Văn Sơn','son.trinh@gmail.com',19990000,'processing','11/06 13:12','Laptop Acer Nitro V15'],
]
export const ORDERS = RAW_ORDERS.map((r,i)=>{
  const [code,customer,email,total,st,date,item]=r
  return { id:i, code, customer, email, total, totalFmt:money(total), st, stLabel:STATUS[st].label,
    stColor:STATUS[st].color, stBg:stBgOf(STATUS[st].color), date, item, init:initials(customer) }
})

const RM = { customer:{label:'Khách hàng',color:'#7aa2ff'}, admin:{label:'Quản trị',color:'#ff3b5c'}, staff:{label:'Nhân viên',color:'#22d39a'} }
const RAW_CUSTOMERS = [
  ['Nguyễn Văn An','an.nguyen@gmail.com','0901234567','customer',8,184500000,'02/2024'],
  ['Trần Thị Bình','binh.tran@gmail.com','0912345678','customer',3,41200000,'03/2024'],
  ['Lê Hoàng Cường','cuong.le@outlook.com','0987654321','customer',5,128900000,'01/2024'],
  ['Phạm Minh Dũng','dung.pham@gmail.com','0934567890','customer',2,9800000,'05/2024'],
  ['Vũ Thị Hà','ha.vu@gmail.com','0976543210','customer',1,24900000,'06/2024'],
  ['Đỗ Quang Huy','huy.do@gmail.com','0945678901','customer',6,72300000,'11/2023'],
  ['Hồ Văn Mạnh','manh.ho@gmail.com','0967890123','customer',4,96100000,'12/2023'],
  ['Trần Quản Trị','admin@cnttshop.vn','0900000001','admin',0,0,'08/2023'],
  ['Nguyễn Thu Staff','staff@cnttshop.vn','0900000002','staff',0,0,'09/2023'],
  ['Ngô Thị Ngọc','ngoc.ngo@gmail.com','0923456789','customer',2,12600000,'04/2024'],
]
export const CUSTOMERS = RAW_CUSTOMERS.map((r,i)=>{
  const [name,email,phone,role,ord,spent,joined]=r
  return { id:i, name, email, phone, role, roleLabel:RM[role].label, roleColor:RM[role].color, roleBg:stBgOf(RM[role].color),
    init:initials(name), orders:ord, spent, spentFmt:money(spent), joined, active:i!==9, hue:[210,265,150,190,32,330][i%6] }
})

export const NAV_GROUPS = [
  { title:'Tổng quan', items:[ ['dashboard','Bảng điều khiển','bi-grid-1x2-fill'], ['analytics','Phân tích','bi-graph-up-arrow'] ] },
  { title:'Bán hàng', items:[ ['orders','Đơn hàng','bi-receipt','12'], ['products','Sản phẩm','bi-box-seam'], ['categories','Danh mục','bi-tags'] ] },
  { title:'Khách hàng', items:[ ['customers','Khách hàng','bi-people'] ] },
  { title:'Marketing', items:[ ['coupons','Khuyến mãi','bi-ticket-perforated'], ['shipping','Phí giao hàng','bi-truck'] ] },
]

// ---- sparkline / area helpers (dashboard scale) ----
export function buildSpark(arr){
  const max=Math.max(...arr), min=Math.min(...arr), w=120, h=34
  return arr.map((v,i)=>{ const x=(i/(arr.length-1))*w; const y=h-2-((v-min)/(max-min||1))*(h-6); return (i?'L':'M')+x.toFixed(1)+' '+y.toFixed(1) }).join(' ')
}
export function buildArea(arr,line){
  const max=Math.max(...arr), min=0, w=560, h=200
  const pts=arr.map((v,i)=>{ const x=(i/(arr.length-1))*w; const y=h-8-((v-min)/(max-min||1))*(h-24); return [x,y] })
  const d=pts.map((p,i)=>(i?'L':'M')+p[0].toFixed(1)+' '+p[1].toFixed(1)).join(' ')
  return line ? d : d+' L'+w+' '+h+' L0 '+h+' Z'
}

// ---- analytics chart geometry ----
export const CHART = { W:860, H:320, padL:50, padR:18, padT:14, padB:32 }
const plotW = CHART.W-CHART.padL-CHART.padR, plotH = CHART.H-CHART.padT-CHART.padB
export const X = (i,n)=> CHART.padL + (i/(n-1))*plotW
export const Y = (v,max)=> CHART.padT + plotH - (v/max)*plotH
export const PLOT_BOTTOM = CHART.padT + plotH
export const AN_XLABELS = ['Th10','Th11','Th12','Th1','Th2','Th3','Th4','Th5','Th6']
export const CAT_SERIES = [
  { key:'laptop',   name:'Laptop',    color:'#00e5ff', data:[320,360,410,380,450,520,490,560,610] },
  { key:'pc',       name:'PC bàn',    color:'#a855f7', data:[240,280,300,330,360,410,390,440,480] },
  { key:'linhkien', name:'Linh kiện', color:'#22d39a', data:[160,180,200,210,240,280,260,300,330] },
  { key:'manhinh',  name:'Màn hình',  color:'#ffb43b', data:[90,110,120,130,150,165,158,180,200] },
  { key:'ngoaivi',  name:'Ngoại vi',  color:'#7aa2ff', data:[45,52,60,58,70,88,80,95,110] },
  { key:'phukien',  name:'Phụ kiện',  color:'#ff6ec7', data:[30,35,40,38,46,55,50,60,68] },
]
export const CAT_COLORS = {'laptop':'#00e5ff','pc-may-tinh-ban':'#a855f7','linh-kien':'#22d39a','man-hinh':'#ffb43b','ngoai-vi':'#7aa2ff','phu-kien':'#ff6ec7'}
export const CAT_EN = {'laptop':'LAPTOP','pc-may-tinh-ban':'DESKTOP PC','linh-kien':'COMPONENTS','man-hinh':'MONITORS','ngoai-vi':'PERIPHERALS','phu-kien':'ACCESSORIES'}

export function statusBreak(){
  const total = ORDERS.length
  return ['delivered','shipped','processing','confirmed','pending','cancelled','refunded']
    .map(k=>{ const cnt=ORDERS.filter(o=>o.st===k).length
      return { label:STATUS[k].label, color:STATUS[k].color, count:cnt+'', pct:Math.round(cnt/total*100)+'%', show:cnt>0 } })
    .filter(s=>s.show)
}
