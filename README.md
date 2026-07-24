# ATS Careers - Hệ thống quản lý tuyển dụng

Ứng dụng tuyển dụng nội bộ cho một công ty, được xây dựng bằng ASP.NET MVC 5 cho bài tập nhóm môn Lập trình Web MVC. Hệ thống có hai khu vực chính: giao diện công khai cho ứng viên và giao diện quản trị dành cho Nhân sự/Quản trị viên.

## Công nghệ

- ASP.NET MVC 5, .NET Framework 4.8 và C#
- Entity Framework 6, Code First from Database
- SQL Server
- Razor View, ViewModel và Data Annotations
- Bootstrap, CSS responsive
- PBKDF2-SHA256, phân quyền theo vai trò và anti-forgery token

## Cấu trúc thư mục

```text
ATSMiniProject/          Mã nguồn ASP.NET MVC 5
  App_Start/             Cấu hình route, bundle và filter
  Content/               CSS, Bootstrap và hình ảnh giao diện
  Controllers/           Controller xử lý request theo từng module
  Filters/               Attribute phân quyền/tái sử dụng
  Helpers/               Hàm hỗ trợ xử lý file, mật khẩu và session
  Models/                Entity Framework models và DbContext
  Scripts/               JavaScript của giao diện
  Uploads/               Thư mục runtime cho CV/avatar, chỉ giữ file cấu hình và .gitkeep
  ViewModels/            Model riêng cho form, validation và màn hình
  Views/                 Razor views theo từng controller
database/                Script tạo cấu trúc và dữ liệu mẫu
docs/                    Tài liệu kiến trúc, phân công, setup GitHub và style guide
packages/                Gói NuGet khôi phục cục bộ, không commit lên Git
```

Chi tiết cấu trúc và quy ước sắp xếp file nằm tại `docs/PROJECT_STRUCTURE.md`.

## Khởi tạo cơ sở dữ liệu

Script chính: `database/ATSMiniDB_Schema_Seed.sql`

1. Mở SQL Server Management Studio.
2. Kết nối đến `MSI\MCHIENCS`.
3. Mở và chạy toàn bộ script.
4. Cơ sở dữ liệu `ATSMiniDB` sẽ được tạo và thêm dữ liệu mẫu.
5. Ứng dụng dùng connection string `ModelDB` trong `ATSMiniProject/Web.config`.

Script có thể chạy lại an toàn mà không tạo trùng dữ liệu mẫu.

## Tài khoản demo

| Vai trò | Tên đăng nhập | Mật khẩu |
|---|---|---|
| Quản trị viên | `admin` | `123456` |
| Nhân sự | `hr01` | `123456` |
| Ứng viên | `ungvien01` | `123456` |

Mật khẩu không được lưu dưới dạng văn bản rõ. Tài khoản mới dùng PBKDF2-SHA256; tài khoản seed cũ được nâng cấp hash sau lần đăng nhập thành công.

## Phạm vi Thành viên 3

Nhánh `applications3` phụ trách trọn luồng Hồ sơ ứng tuyển và Phỏng vấn:

- Ứng viên nộp hồ sơ theo đúng `JobID`, tải CV và theo dõi tiến trình.
- Ứng viên cập nhật hồ sơ cá nhân, ảnh đại diện đồng bộ lên navbar và đổi mật khẩu an toàn.
- Ứng viên tải lịch phỏng vấn `.ics` để thêm vào ứng dụng lịch, kèm nhắc trước 30 phút.
- CV được kiểm tra phần mở rộng, chữ ký tệp, dung lượng và quyền sở hữu.
- HR/Admin tìm kiếm, lọc, phân trang và xem chi tiết hồ sơ.
- HR/Admin cập nhật trạng thái, ghi chú nội bộ và theo dõi lịch sử thay đổi.
- HR/Admin tạo, sửa, hủy lịch phỏng vấn và cập nhật kết quả.
- Kết quả "Đạt"/"Không đạt" tự động đồng bộ trạng thái hồ sơ.
- Phân quyền, anti-forgery, transaction và audit log được áp dụng cho các thao tác ghi.
- Giao diện tiếng Việt có dấu, hero carousel ba ảnh tự chuyển có nút tạm dừng, ảnh đăng nhập, scroll reveal và responsive trên desktop/mobile.

Các URL chính:

| Vai trò | Chức năng | URL |
|---|---|---|
| Ứng viên | Nộp hồ sơ | `/Jobs/Apply/{jobId}` |
| Ứng viên | Theo dõi hồ sơ | `/Applications/Status` |
| HR/Admin | Quản lý hồ sơ | `/Applications` |
| HR/Admin | Quản lý phỏng vấn | `/Interviews` |

Tài liệu kiến trúc, quy tắc nghiệp vụ và kịch bản bảo vệ phần TV3: `docs/CANDIDATE_MODULE_GUIDE.md`.

## Ranh giới phân công

- Thành viên 1: xác thực, layout dùng chung, phân quyền menu và dashboard.
- Thành viên 2: Jobs public, chi tiết Job và bảng quản trị Jobs.
- Thành viên 3: nộp hồ sơ/CV, Applications cho HR/Admin và Interviews.

Một số màn Candidate/Auth/Jobs có trong mã nguồn để bảo đảm luồng tích hợp chạy được. Khi báo cáo, Thành viên 3 chỉ nhận phần sở hữu nêu trên và trình bày các phần còn lại là điểm tích hợp với TV1/TV2.

## Chạy dự án

1. Mở `ATSMiniProject.sln` bằng Visual Studio 2022.
2. Chọn `ATSMiniProject` làm Startup Project.
3. Nhấn `F5` hoặc `Ctrl+F5`.
4. IIS Express hiện dùng `http://localhost:64322/`.

Nếu Visual Studio đang mở trong lúc thay đổi cổng, hãy đóng và mở lại solution để nạp cấu hình mới.

## Nhánh làm việc

| Nhánh | Phạm vi |
|---|---|
| `main` | Bản ổn định để nộp và demo |
| `develop` | Nhánh tích hợp chung |
| `auth-layout1` | Đăng nhập, phân quyền, layout và tích hợp |
| `jobs2` | Quản lý tin tuyển dụng |
| `applications3` | Ứng tuyển, CV, trạng thái và phỏng vấn |

Quy trình đề nghị: cập nhật từ `develop`, làm việc trên nhánh riêng, tạo Pull Request vào `develop`, kiểm thử rồi mới hợp nhất.
