# ATS Mini Public UI Style Guide - Candidate Website

## 1. Quyet dinh thiet ke

Phan public/candidate cua ATS Mini dung huong:

```text
Clean Job Board / Career Portal UI
```

Dinh vi san pham:

- ATS Mini la trang tuyen dung cua mot cong ty.
- Ung vien vao xem viec lam, xem chi tiet tin, nop ho so va theo doi trang thai.
- Khong phai san tuyen dung nhieu cong ty.

He qua thiet ke:

- Khong co menu `Companies`.
- Khong co nut `Post Jobs` cho public.
- Khong co trang cong ty rieng.
- Job card khong can logo nhieu cong ty; co the dung icon phong ban/vi tri.

## 2. Pham vi ap dung

Public layout dung cho:

```text
Home/Index
Jobs/Index
Jobs/Details/{id}
Applications/Create?jobId=...
Applications/Status
Candidate/Profile neu co
Account/Login
```

File goi y:

```text
Views/Shared/_Layout.cshtml
Views/Shared/_Navbar.cshtml
Views/Shared/_Alert.cshtml
Content/css/site.css
```

Neu sau nay muon tach rieng public layout thi co the tao:

```text
Views/Shared/_PublicLayout.cshtml
Views/Shared/_PublicNavbar.cshtml
Views/Shared/_PublicFooter.cshtml
Content/css/public.css
```

Nhung hien tai project da co `_Layout.cshtml`, nen co the tan dung truoc de tranh churn.

## 3. Anh mau va cach ap dung

### 3.1 Public homepage / landing

Lay cam hung tu anh Job Find / JobBook:

- Navbar ngang.
- Hero co title lon.
- Search job + location.
- Section category.
- Featured jobs.
- CTA xem viec lam / nop ho so.

Can dieu chinh:

- Doi noi dung thanh trang tuyen dung cua mot cong ty.
- Bo cac logo cong ty neu gay hieu nham la san nhieu cong ty.
- Khong dung noi dung freelancer marketplace.

### 3.2 Jobs listing

Lay cam hung tu anh Jobnetic:

- Header `Danh sach viec lam`.
- Search theo tu khoa va dia diem.
- Filter.
- Job cards.
- Pagination.
- Footer navy.

Can dieu chinh:

- Filter `Company` doi thanh `Phong ban` hoac bo.
- Button `Post Jobs` bo.
- Menu `Candidates`, `Companies` bo.

### 3.3 Featured jobs

Lay cam hung tu anh JobBook:

- Danh sach viec lam noi bat dang list/card.
- Moi job co ten vi tri, phong ban, dia diem, loai viec, muc luong neu co, nut ung tuyen.

Can dieu chinh:

- Giu noi dung ngan gon.
- Khong dua qua nhieu company logo.

## 4. Navbar chot

### Chua dang nhap

```text
ATS Mini | Trang chu | Viec lam | Theo doi ho so | Dang nhap
```

### Da dang nhap role Candidate

```text
ATS Mini | Trang chu | Viec lam | Ho so cua toi | Trang thai ung tuyen | Tai khoan
```

### Admin/HR dang nhap

Neu Admin/HR vao public layout, co the hien them link:

```text
Dashboard
```

Nhung public navigation khong nen tron qua nhieu chuc nang quan tri.

## 5. Phong cach tong the

- Sang, sach, de doc.
- Nhanh tim viec.
- Card trang, shadow nhe.
- Navbar ngang.
- Footer navy.
- Khong dung sidebar.
- Khong lam landing page qua dai neu chua xong chuc nang chinh.

Ten style:

```text
Clean Job Board / Career Portal UI
```

## 6. Mau sac chot

| Token | Mau | Dung cho |
|---|---|---|
| `--ats-primary` | `#2563EB` | Button chinh, link active |
| `--ats-primary-dark` | `#1D4ED8` | Hover button |
| `--ats-navy` | `#0F172A` | Footer, text nhan manh |
| `--ats-bg` | `#F8FAFC` | Nen public |
| `--ats-hero-bg` | `#EAF6FF` | Nen hero xanh nhat |
| `--ats-surface` | `#FFFFFF` | Job card, form card |
| `--ats-border` | `#E5E7EB` | Border card/input |
| `--ats-text` | `#111827` | Text chinh |
| `--ats-muted` | `#6B7280` | Text phu |
| `--ats-success` | `#16A34A` | Dang tuyen / Dat |
| `--ats-warning` | `#F59E0B` | Sap het han / Phong van |
| `--ats-danger` | `#DC2626` | Het han / Tu choi |
| `--ats-info` | `#0EA5E9` | Moi nop |

CSS variables goi y:

```css
:root {
    --ats-primary: #2563eb;
    --ats-primary-dark: #1d4ed8;
    --ats-navy: #0f172a;
    --ats-bg: #f8fafc;
    --ats-hero-bg: #eaf6ff;
    --ats-surface: #ffffff;
    --ats-border: #e5e7eb;
    --ats-text: #111827;
    --ats-muted: #6b7280;
    --ats-success: #16a34a;
    --ats-warning: #f59e0b;
    --ats-danger: #dc2626;
    --ats-info: #0ea5e9;
}
```

## 7. Typography

Dung font co san de de chay tren may nhom:

```css
font-family: "Segoe UI", Arial, sans-serif;
```

Neu sau nay cho phep them font ngoai, co the dung Inter.

Kich thuoc goi y:

| Thanh phan | Size |
|---|---|
| Hero title | 44px - 56px |
| Page title | 32px - 40px |
| Section title | 28px - 32px |
| Job title | 18px - 20px |
| Body text | 15px - 16px |
| Small text | 13px - 14px |

## 8. Trang chu ung vien

Route:

```text
Home/Index
```

Muc tieu:

- Gioi thieu nhanh he thong.
- Cho ung vien tim viec ngay.
- Dan den danh sach viec lam.

Bo cuc:

```text
Navbar
Hero search
Thong ke ngan
Danh muc viec lam
Viec lam noi bat
Quy trinh ung tuyen
CTA xem viec lam
Footer
```

Hero content goi y:

```text
Title: Tim cong viec phu hop voi ban
Subtitle: Kham pha cac vi tri dang tuyen va nop ho so truc tuyen.
Search: Ten cong viec, ky nang...
Location: Dia diem
Button: Tim viec
```

Thong ke co the dung du lieu mau:

```text
Tin dang tuyen
Ho so da nop
Lich phong van
Ung vien duoc xu ly
```

## 9. Trang danh sach viec lam

Route:

```text
Jobs/Index
```

Muc tieu:

- Cho ung vien loc va xem tin tuyen dung dang mo.

Bo cuc uu tien:

```text
Header search
Filter bar hoac sidebar filter
Job cards
Pagination
Footer
```

Filter goi y:

- Tu khoa.
- Dia diem.
- Phong ban.
- Vi tri.
- Loai viec.
- Trang thai.
- Han nop.

Job card nen co:

```text
Ten vi tri
Phong ban
Dia diem
Loai viec
Muc luong neu co
Han nop
Trang thai
Button Xem chi tiet
Button Ung tuyen
```

Khong nen co:

- Ten cong ty khac nhau.
- Logo cong ty khac nhau.
- Nut save/favorite neu chua co nghiep vu.

## 10. Trang chi tiet viec lam

Route:

```text
Jobs/Details/{id}
```

Bo cuc 2 cot:

Cot trai:

- Tieu de viec lam.
- Phong ban.
- Dia diem.
- Mo ta cong viec.
- Yeu cau.
- Quyen loi neu co.
- Thoi gian / hinh thuc lam viec.

Cot phai:

- Card tom tat.
- Loai viec.
- Muc luong.
- Han nop.
- So luong tuyen.
- Trang thai.
- Button `Ung tuyen ngay`.

Neu tin da dong, button ung tuyen phai disabled hoac an di.

## 11. Form nop ho so

Route:

```text
Applications/Create?jobId=...
```

Form can co:

- Ho ten.
- Email.
- So dien thoai.
- Upload CV.
- Thu gioi thieu ngan / ghi chu neu can.

Upload CV:

```text
Chap nhan PDF, DOC, DOCX. Dung luong toi da 5MB.
```

Quy tac UI:

- Form nam trong card trang.
- Ben phai hoac tren dau co card tom tat viec dang ung tuyen.
- Nut chinh: `Nop ho so`.
- Validation message ro rang.

## 12. Trang theo doi ho so

Route goi y:

```text
Applications/Status
```

Neu chua dang nhap:

- Hien form tra cuu bang email + ma ho so, hoac yeu cau dang nhap.

Neu da dang nhap:

- Hien danh sach ho so da nop.
- Moi ho so co job title, ngay nop, trang thai, lich phong van neu co.

Timeline goi y:

```text
Da nop ho so -> HR dang xem xet -> Moi phong van -> Co ket qua
```

## 13. Badge trang thai

Job status:

| Trang thai | Mau |
|---|---|
| Dang tuyen | Success |
| Sap het han | Warning |
| Da dong | Neutral |
| Het han | Danger |

Application status:

| Trang thai | Mau |
|---|---|
| Moi nop | Info |
| Dang xem xet | Primary |
| Moi phong van | Warning |
| Dat | Success |
| Truot | Danger |

Neu Bootstrap local khong ho tro `bg-*-subtle`, tu tao class CSS rieng.

## 14. Footer

Footer nen gon, nen navy.

Noi dung:

```text
ATS Mini
Gioi thieu
Viec lam
Theo doi ho so
Lien he
```

Khong can footer nhieu cot nhu template that neu chua co noi dung.

## 15. Khong nen lam

Khong dua cac muc sau vao public site:

- Sidebar Admin/HR.
- Dashboard quan tri.
- Companies.
- Post Jobs.
- Employer pricing.
- Saved jobs/favorites neu chua co database.
- Multi-company branding.
- Form qua dai.
- Animation phuc tap.

## 16. Thu tu uu tien khi code

```text
1. Public layout / navbar / footer
2. Home/Index hero + featured jobs mau
3. Jobs/Index listing + filter
4. Jobs/Details
5. Applications/Create
6. Applications/Status
7. Candidate profile neu con thoi gian
```

Khong lam profile/tra cuu nang cao truoc khi luong xem viec -> nop ho so chay duoc.

## 17. Prompt ngan khi can code public view

```text
Code Razor View ASP.NET MVC 5 + Bootstrap 5 cho ATS Mini theo style Clean Job Board / Career Portal UI.

Dinh vi:
- ATS Mini la trang tuyen dung cua mot cong ty.
- Khong co Companies, khong co Post Jobs, khong phai san nhieu cong ty.

Quy tac:
- Dung navbar ngang, khong dung sidebar.
- Nen #F8FAFC, primary #2563EB, footer navy #0F172A.
- Card trang bo goc 16px, border #E5E7EB, shadow nhe.
- Job card gon, co title, phong ban, dia diem, loai viec, han nop, badge, nut xem chi tiet/ung tuyen.
- Dung Bootstrap 5 + Razor .cshtml.
- Khong dung React/Vue/Tailwind.
```

## 18. Cach giai thich voi giao vien

```text
Giao dien ung vien duoc thiet ke theo phong cach Job Board/Career Portal nhung da dieu chinh cho bai toan ATS noi bo mot cong ty. Ung vien tap trung vao 4 thao tac chinh: tim viec, xem chi tiet tin, nop ho so va theo doi trang thai ung tuyen. Public site dung navbar ngang de tach biet voi giao dien quan tri Admin/HR co sidebar.
```

## 19. Ket luan

Thiet ke public/candidate da chot theo huong Clean Job Board. Anh mau Jobnetic phu hop nhat cho Jobs listing; anh landing page phu hop cho Home; anh beige/editorial chi nen lay mot vai section phu neu can. Khi code, uu tien luong chinh: xem viec -> xem chi tiet -> nop ho so -> theo doi trang thai.
