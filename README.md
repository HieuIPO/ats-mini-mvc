# ATS Mini MVC

He thong quan ly tuyen dung va theo doi ung vien (ATS Mini) cho mon Lap trinh Web MVC.

## Cong nghe

- ASP.NET MVC 5 / .NET Framework
- C#
- Entity Framework 6
- SQL Server
- Code First from database
- Bootstrap
- Razor View, ViewModel, Validation
- AJAX / Partial View cho mot so chuc nang cap nhat dong

## Cau truc thu muc de nghi

```text
ATSMiniProject/      Source code ASP.NET MVC 5
database/            Script tao database va du lieu mau
docs/                Phan cong, tai lieu bao cao, ERD, hinh demo
BaiGiang/            Tai lieu bai giang tham khao
```

## Database

Script chinh:

```text
database/ATSMiniDB_StudentPlus_Schema_Seed.sql
```

Cach tao database:

1. Mo SQL Server Management Studio.
2. Tao query moi.
3. Chay toan bo file SQL tren.
4. Database duoc tao voi ten `ATSMiniDB_StudentPlus`.
5. Trong Visual Studio, dung Entity Framework Code First from database de sinh DbContext va entity classes tu database nay.

## Tai khoan demo

| Vai tro | Username | Password |
|---|---|---|
| Admin | admin | 123456 |
| HR | hr01 | 123456 |
| Ung vien | ungvien01 | 123456 |

Luu y: Database luu `PasswordHash` va `PasswordSalt`, khong luu mat khau ro.

## Branch lam viec

| Branch | Nguoi/pham vi |
|---|---|
| main | Ban on dinh de nop/demo |
| develop | Branch ghep code chung |
| auth-layout1 | Thanh vien 1: dang nhap, phan quyen, layout, tich hop |
| jobs2 | Thanh vien 2: quan ly tin tuyen dung |
| applications3 | Thanh vien 3: ung tuyen, upload CV, trang thai, phong van |

## Quy trinh lam viec

1. Moi nguoi lay code moi nhat tu `develop`.
2. Moi nguoi code tren branch rieng cua minh.
3. Khi xong mot phan, tao Pull Request vao `develop`.
4. Kiem tra chay duoc moi merge vao `develop`.
5. Truoc ngay nop, merge `develop` vao `main`.

## Tai lieu phan cong

Xem file:

```text
docs/PHAN_CONG_CONG_VIEC_ATS.md
```

## Huong dan GitHub

Xem file:

```text
docs/GITHUB_SETUP.md
```
