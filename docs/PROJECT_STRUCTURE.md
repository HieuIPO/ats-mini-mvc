# Cấu trúc thư mục dự án ATS Mini

Tài liệu này ghi lại cách sắp xếp source để các nhánh thành viên có thể ghép vào `develop` dễ hơn.

## Cây thư mục chính

```text
ATSMiniProject.sln
ATSMiniProject/
  App_Start/
  Content/
    bootstrap/
    css/
    images/
  Controllers/
  Filters/
  Helpers/
  Models/
  Scripts/
    app/
    bootstrap/
  Uploads/
    Avatars/
    CVs/
  ViewModels/
    Account/
    Applications/
    Candidate/
    Dashboard/
    Home/
    Interviews/
    Jobs/
  Views/
    Account/
    Applications/
    Candidate/
    Dashboard/
    Home/
    Interviews/
    Jobs/
    Shared/
database/
docs/
packages/
```

## Quy ước đặt file

- `Controllers/`: mỗi controller phụ trách một nhóm màn hình hoặc nghiệp vụ, ví dụ `ApplicationsController.cs`, `InterviewsController.cs`.
- `Models/`: chỉ đặt entity, enum và `ATSMiniDBContext`. Không đặt model riêng cho form tại đây.
- `ViewModels/`: chia theo module để tránh file lớn và tránh trộn dữ liệu form với entity database.
- `Views/`: chia theo tên controller. Partial/layout dùng chung đặt trong `Views/Shared/`.
- `Helpers/`: đặt xử lý tái sử dụng không phụ thuộc trực tiếp vào UI, ví dụ hash mật khẩu, kiểm tra file, khóa session.
- `Filters/`: đặt attribute dùng chung cho phân quyền hoặc kiểm soát request.
- `Content/`: đặt CSS và hình ảnh tĩnh.
- `Scripts/app/`: đặt JavaScript tự viết cho giao diện.
- `Uploads/`: chỉ commit `Web.config` và `.gitkeep`; file CV/avatar thật là dữ liệu runtime và không đưa lên Git.
- `database/`: đặt script SQL có thể chạy lại được.
- `docs/`: đặt hướng dẫn setup, phân công, style guide và tài liệu nghiệp vụ.

## Quy ước theo nhánh

- Nhánh thành viên 3 là `applications3`.
- Sau khi hoàn thành một phần ổn định, push lên `origin/applications3`.
- Pull Request được tạo từ `applications3` vào `develop`.
- Không merge trực tiếp vào `main` khi chưa chốt bản demo.

## File không commit

Các thư mục/file local đã được loại bằng `.gitignore`:

- `.vs/`
- `bin/`, `obj/`
- `packages/`
- file upload thật trong `ATSMiniProject/Uploads/`
- file log, publish profile và database local `.mdf`/`.ldf`
