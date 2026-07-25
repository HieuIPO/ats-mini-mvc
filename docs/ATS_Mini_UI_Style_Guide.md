# ATS Mini UI Style Guide - Admin & HR

## 1. Quyet dinh thiet ke

Khu vuc Admin va HR cua ATS Mini dung chung mot layout quan tri theo huong:

```text
Modern HR Recruitment SaaS Dashboard
```

Dinh vi san pham:

- ATS Mini la he thong tuyen dung noi bo cho mot cong ty.
- Admin va HR la nguoi dung noi bo.
- Ung vien la nguoi dung public ben ngoai.
- Khong dinh vi la san tuyen dung nhieu cong ty.

Ly do:

- Database hien co `Departments`, `JobPositions`, `Jobs`, `Applications`, `Interviews`, `Users`, `Roles`.
- Khong co bang `Companies`, `Employers`, `CompanyProfiles`.
- Role hien co la `Admin`, `HR`, `Candidate`.

## 2. Pham vi ap dung

Admin va HR dung chung:

```text
Views/Shared/_AdminLayout.cshtml
Views/Shared/_Sidebar.cshtml
Views/Shared/_Navbar.cshtml
Content/css/site.css
```

Khong tao layout rieng cho tung module. TV2 va TV3 khi lam view quan tri phai dung layout nay.

Ung vien khong dung layout Admin/HR. Ung vien dung public layout rieng.

## 3. Anh mau da chon va cach ap dung

Cac anh mau HR / Recruitment SaaS duoc dung lam cam hung cho:

- Dashboard tong quan.
- Jobs management table.
- Candidate pipeline.
- Hiring pipeline.
- Interview schedule card.

Chi lay cau truc va component. Khong copy y nguyen thiet ke.

### 3.1 Dashboard overview

Ap dung:

- Sidebar trai.
- Topbar trang.
- Card thong ke.
- Khu vuc lich phong van / ung vien moi.
- Content nen xam nhat.

Khong nen lam ngay:

- Chart phuc tap.
- Inbox realtime.
- Notification realtime.

### 3.2 Jobs management

Ap dung cho `Jobs/Index` cua HR:

- Tabs: Tat ca, Dang mo, Da dong.
- Search theo tieu de.
- Filter phong ban / vi tri / loai viec.
- Table jobs.
- Badge trang thai.
- Nut chinh: `Them tin tuyen dung`.

### 3.3 Candidate pipeline

Ap dung cho Applications hoac tab ung vien trong chi tiet job:

- Search ung vien.
- Filter trang thai.
- Cac trang thai: Moi nop, Dang xem xet, Moi phong van, Dat, Truot.
- Uu tien table truoc. Pipeline card chi lam neu con thoi gian.

## 4. Nguyen tac UI

- UI sang, sach, hien dai, nghiem tuc.
- Uu tien table, form, card, badge vi phu hop do an MVC.
- Khong dung React, Vue, Angular, Tailwind.
- Khong dung animation phuc tap.
- Khong lam chart khi chua co du lieu that.
- Khong dat card long trong card.
- Moi trang chi nen co mot nut chinh noi bat.

## 5. Mau sac chot

| Token | Mau | Dung cho |
|---|---|---|
| `--ats-primary` | `#1687F7` | Button chinh, active menu, link |
| `--ats-primary-dark` | `#0F6FD1` | Hover button chinh |
| `--ats-bg` | `#F5F7FA` | Nen content |
| `--ats-sidebar-bg` | `#EEF6F6` | Sidebar sang neu dung style sang |
| `--ats-sidebar-dark` | `#0F172A` | Sidebar toi neu giu style hien tai |
| `--ats-surface` | `#FFFFFF` | Card, table, topbar |
| `--ats-border` | `#E6EBF0` | Border card/table/input |
| `--ats-text` | `#102A2A` | Text chinh |
| `--ats-muted` | `#6B7A7A` | Text phu |
| `--ats-success` | `#16A34A` | Dat, dang mo |
| `--ats-warning` | `#F59E0B` | Moi phong van, cho xu ly |
| `--ats-danger` | `#EF4444` | Truot, khoa, het han |
| `--ats-info` | `#0EA5E9` | Moi nop |
| `--ats-neutral` | `#94A3B8` | Da dong, ban nhap |

CSS variables goi y:

```css
:root {
    --ats-primary: #1687f7;
    --ats-primary-dark: #0f6fd1;
    --ats-bg: #f5f7fa;
    --ats-sidebar-bg: #eef6f6;
    --ats-sidebar-dark: #0f172a;
    --ats-surface: #ffffff;
    --ats-border: #e6ebf0;
    --ats-text: #102a2a;
    --ats-muted: #6b7a7a;
    --ats-success: #16a34a;
    --ats-warning: #f59e0b;
    --ats-danger: #ef4444;
    --ats-info: #0ea5e9;
    --ats-neutral: #94a3b8;
}
```

## 6. Layout Admin / HR

### 6.1 Khung chinh

```text
---------------------------------------------------------
| Sidebar | Topbar: Search | Notification | User        |
|         |-----------------------------------------------|
|         | Page title + action button                    |
|         | Filters / tabs                                |
|         | Cards / Table / Forms                         |
---------------------------------------------------------
```

### 6.2 Sidebar

Chieu rong goi y:

```css
width: 260px;
```

Menu hien tai:

```text
Dashboard
Tin tuyen dung
Ho so ung vien
Phong van
Tai khoan
```

Quy tac:

- Admin thay menu `Tai khoan`.
- HR khong thay `Tai khoan` neu khong co quyen quan ly user.
- Active item phai ro.
- Icon + text, khong chi dung icon.
- Menu khong duoc dan toi route chua thuoc module cua nguoi khac neu chua thong nhat.

### 6.3 Topbar

Thanh topbar nen co:

- Search box.
- Ten nguoi dung + role.
- Nut dang xuat.
- Thong bao neu co thoi gian.

Khong can notification realtime o giai doan dau.

### 6.4 Content

- Padding 24px.
- Page title 24px - 28px.
- Page subtitle ngan neu can.
- Action button dat ben phai page header.
- Card/table cach nhau 16px - 24px.

## 7. Component chuan

### 7.1 Card

Dung cho KPI, form, table wrapper, lich phong van.

```css
.ats-card {
    background: var(--ats-surface);
    border: 1px solid var(--ats-border);
    border-radius: 16px;
    box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
}
```

### 7.2 Table

Dung cho:

- Jobs.
- Applications.
- Interviews.
- Users.

Quy tac:

- Table nam trong card.
- Co toolbar tren table.
- Header mau xam nhat.
- Row hover nhe.
- Cot action nam ben phai.
- Co pagination neu danh sach dai.
- Mobile dung `.table-responsive`.

### 7.3 Badge

Application status:

| Trang thai | Class goi y |
|---|---|
| Moi nop | `badge-soft-info` |
| Dang xem xet | `badge-soft-primary` |
| Moi phong van | `badge-soft-warning` |
| Dat | `badge-soft-success` |
| Truot | `badge-soft-danger` |

Job status:

| Trang thai | Class goi y |
|---|---|
| Dang mo | `badge-soft-success` |
| Tam dung | `badge-soft-warning` |
| Da dong | `badge-soft-neutral` |
| Het han | `badge-soft-danger` |

Role badge:

| Role | Class goi y |
|---|---|
| Admin | `badge-soft-danger` |
| HR | `badge-soft-primary` |
| Candidate | `badge-soft-neutral` |

## 8. Man hinh Admin

### 8.1 Admin Dashboard

Lam sau khi da co du lieu hoac co the hard-code mau de demo UI.

Thanh phan:

- Tong tai khoan.
- Tai khoan HR.
- Ung vien.
- Tin dang mo.
- Tai khoan moi tao.
- Audit log / hoat dong gan day neu co.

### 8.2 Quan ly tai khoan

Muc phu, lam neu con thoi gian.

Thanh phan:

- Search.
- Filter role.
- Filter trang thai.
- Table users.
- Action: xem, sua, khoa/mo khoa.

## 9. Man hinh HR

### 9.1 HR Dashboard

Thanh phan:

- Tin dang tuyen.
- Ho so moi.
- Cho phong van.
- Da tuyen.
- Ung vien moi nhat.
- Lich phong van hom nay.

### 9.2 Quan ly tin tuyen dung

Trang quan trong cua TV2.

Thanh phan:

- Tabs: Tat ca, Dang mo, Da dong.
- Search/filter.
- Table jobs.
- Nut `Them tin tuyen dung`.
- Badge trang thai.

### 9.3 Ho so ung vien

Trang quan trong cua TV3.

Thanh phan:

- Filter theo job, trang thai, ngay nop.
- Table applications.
- Link xem CV.
- Action: xem chi tiet, cap nhat trang thai, lap lich phong van.

### 9.4 Lich phong van

Thanh phan:

- List phong van theo ngay.
- Form tao/sua lich.
- Badge ket qua.

## 10. Thu tu uu tien khi code

```text
1. Layout Admin/HR
2. Jobs table
3. Applications table
4. Candidate detail
5. Interviews list/form
6. Dashboard that
7. Pipeline/card nang cao
```

Khong lam dashboard/chart nang cao truoc khi Jobs va Applications chay on.

## 11. Checklist cho TV2 va TV3

TV2 Jobs:

- Dung `_AdminLayout.cshtml`.
- Dung table theo style guide.
- Co search/filter/tabs.
- Co badge trang thai.
- Nut chinh la `Them tin tuyen dung`.

TV3 Applications:

- Dung `_AdminLayout.cshtml`.
- Co filter trang thai.
- Co badge trang thai.
- Co link CV.
- Trang detail co note HR va lich su trang thai.

TV3 Interviews:

- Dung `_AdminLayout.cshtml`.
- Co list lich phong van.
- Co form tao/sua lich.
- Co badge ket qua phong van.

## 12. Prompt ngan khi can code view Admin/HR

```text
Code Razor View ASP.NET MVC 5 + Bootstrap 5 cho ATS Mini theo style Modern HR Recruitment SaaS Dashboard.

Quy tac:
- Dung _AdminLayout.cshtml.
- Sidebar trai, topbar trang, content nen #F5F7FA.
- Card trang bo goc 16px, border #E6EBF0, shadow nhe.
- Table sach, co toolbar search/filter/tabs.
- Badge mem cho trang thai.
- Button chinh mau #1687F7.
- Khong dung React/Vue/Tailwind.
- Khong tao layout moi.
```

## 13. Ket luan

Thiet ke Admin/HR da chot theo huong Recruitment SaaS Dashboard. Huong nay phu hop voi ATS Mini vi tap trung vao dashboard noi bo, quan ly jobs, applications va interviews. Tuy nhien phai ap dung co chon loc, uu tien luong demo chinh truoc cac thanh phan trang tri nang cao.
