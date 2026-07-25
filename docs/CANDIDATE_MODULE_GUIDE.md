# Thành viên 3 - Hồ sơ ứng tuyển và Phỏng vấn

## 1. Mục tiêu

Thành viên 3 phụ trách trọn vòng đời hồ sơ kể từ khi ứng viên gửi đơn đến khi Nhân sự kết thúc phỏng vấn:

1. Ứng viên nộp hồ sơ theo một `JobID` hợp lệ và đính kèm CV.
2. Ứng viên theo dõi trạng thái, lịch sử xử lý và lịch phỏng vấn của chính mình.
3. Ứng viên quản lý thông tin cá nhân, ảnh đại diện và mật khẩu.
4. HR/Admin tìm kiếm, lọc, xem chi tiết và cập nhật hồ sơ.
5. HR/Admin tạo, sửa, hủy lịch phỏng vấn và ghi nhận kết quả.
6. Mọi thay đổi quan trọng được phân quyền, ghi lịch sử và audit log.

Auth/layout/dashboard thuộc Thành viên 1. Danh sách, chi tiết và quản trị Jobs thuộc Thành viên 2. Phần TV3 chỉ tích hợp với các chức năng này, không nhận quyền sở hữu thay cho thành viên khác.

## 2. Cấu trúc triển khai

### Controllers

- `ApplicationsController`
  - Candidate: `Status`, `Details`, `DownloadCv`.
  - HR/Admin: `Index`, `Review`, `UpdateStatus`, `DownloadCandidateCv`.
- `JobsController`
  - Điểm tích hợp để mở form và gửi hồ sơ theo `JobID`.
- `InterviewsController`
  - HR/Admin: `Index`, `Create`, `Edit`, `Cancel`.

### ViewModels

- `ViewModels/Applications/CandidateApplicationViewModels.cs`: dữ liệu an toàn cho giao diện ứng viên.
- `ViewModels/Applications/AdminApplicationViewModels.cs`: bộ lọc, bảng hồ sơ, chi tiết, lịch sử và cập nhật trạng thái.
- `ViewModels/Interviews/InterviewManagementViewModels.cs`: danh sách và biểu mẫu tạo/cập nhật phỏng vấn.
- `ViewModels/Jobs/CandidateJobViewModels.cs`: dữ liệu tích hợp cho biểu mẫu nộp hồ sơ.

Entity không được truyền trực tiếp ra view. Cách tách này hạn chế over-posting, không làm lộ `HRNote` cho Candidate và giữ controller rõ trách nhiệm.

### Views

- Candidate: `Views/Jobs/Apply.cshtml`, `Views/Applications/Status.cshtml`, `Views/Applications/Details.cshtml`.
- HR/Admin: `Views/Applications/Index.cshtml`, `Views/Applications/Review.cshtml`.
- Phỏng vấn: `Views/Interviews/Index.cshtml`, `Views/Interviews/Edit.cshtml`.

## 3. Quy tắc nghiệp vụ

### Nộp hồ sơ

- Chỉ nhận Job đang hoạt động, chưa xóa và chưa hết hạn.
- Mỗi Candidate chỉ có một hồ sơ đang hoạt động trên một Job.
- CSDL có filtered unique index cho `(JobID, CandidateUserID)` và `(JobID, CandidateEmail)`.
- Application, metadata CV, status history và audit log được ghi trong cùng transaction.
- Tệp lỗi được dọn khi transaction thất bại.

### CV và bảo mật

- Giới hạn 5 MB; chỉ nhận PDF, DOC và DOCX.
- Kiểm tra cả phần mở rộng và chữ ký tệp, không chỉ tin `Content-Type`.
- Tên lưu trên server là GUID; tên gốc chỉ dùng khi tải xuống.
- Thư mục `Uploads` chặn URL trực tiếp.
- Candidate chỉ tải được CV thuộc hồ sơ của chính mình.
- HR/Admin tải CV qua action đã phân quyền.

### Hồ sơ cá nhân và tài khoản

- Ảnh đại diện chỉ nhận JPG/PNG tối đa 3 MB và tối thiểu 128 x 128 pixel.
- Ảnh được giải mã, cắt vuông, loại metadata và nén lại thành JPEG 512 x 512.
- Tệp ảnh nằm trong `Uploads` bị IIS chặn và chỉ trả qua action đã xác thực.
- Ảnh cập nhật được đồng bộ ngay lên avatar navbar bằng URL có phiên bản cache; khi không có ảnh hệ thống dùng chữ cái fallback.
- Đổi mật khẩu bắt buộc xác minh mật khẩu hiện tại, mật khẩu mới khác mật khẩu cũ.
- Mật khẩu mới dùng PBKDF2-SHA256 và mọi thay đổi được ghi audit log.
- Nút hiện/ẩn mật khẩu có trên đăng nhập, đăng ký và đổi mật khẩu.
- Hero tự chuyển ba ảnh sau mỗi 6,5 giây bằng crossfade và zoom nhẹ; có nút tạm dừng/tiếp tục rõ ràng.
- Trang đăng nhập dùng ảnh tuyển dụng thích hợp trên desktop/mobile; scroll reveal giảm biên độ chuyển động khi người dùng bật `prefers-reduced-motion`.

### Trạng thái hồ sơ

- HR/Admin được cập nhật trạng thái và ghi chú nội bộ.
- Khi trạng thái thay đổi, hệ thống ghi `ApplicationStatusHistory` gồm trạng thái cũ, mới, người đổi, thời gian và ghi chú.
- `HRNote` không xuất hiện trong ViewModel hoặc giao diện Candidate.
- Kết quả phỏng vấn “Đạt”/“Không đạt” đồng bộ sang trạng thái hồ sơ tương ứng.

### Phỏng vấn

- Lịch mới phải ở tương lai.
- Không tạo hai lịch cùng thời điểm cho một hồ sơ.
- Người phỏng vấn phải là tài khoản HR/Admin đang hợp lệ.
- Không tạo lịch mới cho hồ sơ đã ở trạng thái kết thúc.
- Tạo lịch mới tự chuyển hồ sơ sang “Mời phỏng vấn”.
- Hủy lịch theo kiểu soft delete.
- Khi sửa hoặc hủy lịch, trạng thái hồ sơ được đối soát lại với các lịch và kết quả còn hoạt động.
- Nếu hủy lịch hoạt động cuối cùng, hồ sơ tự trở về “Đang xem xét”.
- Candidate có thể tải lịch tương lai dạng `.ics`, thêm vào Outlook/Google Calendar/điện thoại và nhận nhắc trước 30 phút.
- Action xuất lịch kiểm tra `CandidateUserID`; lịch không thuộc tài khoản trả về `404`.

### Kiểm soát truy cập

- Candidate không truy cập được màn quản trị Applications/Interviews.
- HR/Admin không dùng được action chỉ dành cho Candidate.
- `AuthorizeRoleAttribute` kiểm tra lại trạng thái User/Role từ CSDL.
- Mọi POST đều có anti-forgery token.
- Các thao tác ghi quan trọng có audit log và xử lý lỗi cập nhật đồng thời.

## 4. Cơ sở dữ liệu

- Server: `MSI\MCHIENCS`
- Database: `ATSMiniDB`
- Connection name: `ModelDB`
- Script: `database/ATSMiniDB_Schema_Seed.sql`

Script seed có tính idempotent. Chạy lại không tạo trùng Role, User, Job, Application hoặc ApplicationStatus.

| Vai trò | Tên đăng nhập | Mật khẩu |
|---|---|---|
| Quản trị viên | `admin` | `123456` |
| Nhân sự | `hr01` | `123456` |
| Ứng viên | `ungvien01` | `123456` |

## 5. Kịch bản demo bảo vệ bài

1. Đăng nhập `ungvien01`, mở một Job và nộp hồ sơ theo đúng `JobID`.
2. Trình bày validation CV và cơ chế chống nộp trùng.
3. Mở `/Applications/Status` để xem trạng thái, lịch sử, lịch phỏng vấn và tải lịch `.ics`.
4. Đổi ID trên URL để chứng minh Candidate không xem được hồ sơ người khác.
5. Đăng nhập `hr01`, mở `/Applications`, demo tìm kiếm, lọc và phân trang.
6. Mở chi tiết hồ sơ, cập nhật trạng thái và chỉ ra bản ghi lịch sử vừa sinh.
7. Tạo lịch phỏng vấn; chứng minh hồ sơ tự chuyển sang “Mời phỏng vấn”.
8. Cập nhật kết quả “Đạt” hoặc “Không đạt”; chứng minh trạng thái hồ sơ đồng bộ.
9. Hủy lịch và giải thích soft delete cùng quy tắc đưa hồ sơ về “Đang xem xét”.
10. Đăng nhập Candidate để chứng minh các URL quản trị trả về Access Denied.

## 6. Definition of Done

- [x] Nộp hồ sơ gắn đúng Job và Candidate.
- [x] Upload CV có validation, transaction và dọn tệp khi lỗi.
- [x] Chống nộp trùng ở cả controller và database.
- [x] Candidate chỉ xem/tải tài nguyên thuộc quyền sở hữu.
- [x] Ảnh đại diện được kiểm tra, xử lý lại và phục vụ qua action bảo vệ.
- [x] Đổi mật khẩu có xác minh mật khẩu hiện tại và audit log.
- [x] HR/Admin có bảng hồ sơ, tìm kiếm, lọc và phân trang.
- [x] HR/Admin xem chi tiết, cập nhật trạng thái và ghi chú nội bộ.
- [x] Lịch sử trạng thái ghi đúng người, thời gian, trạng thái cũ/mới.
- [x] HR/Admin tạo, sửa, hủy và lọc lịch phỏng vấn.
- [x] Kết quả phỏng vấn đồng bộ trạng thái hồ sơ.
- [x] Candidate tải được lịch `.ics` của chính mình và không truy cập được lịch người khác.
- [x] Phân quyền Candidate và HR/Admin đã được kiểm thử.
- [x] Giao diện tiếng Việt có dấu và responsive.
- [x] Build .NET Framework 4.8 thành công, không warning.

## 7. Phần còn lại của toàn hệ thống

Các mục sau không phải phần thiếu của TV3:

- Bảng quản trị Jobs, đóng/mở Job: Thành viên 2.
- Hoàn thiện dashboard tổng hợp: Thành viên 1 sau khi nhận dữ liệu tích hợp.
- Menu, topbar, thông báo chung và quản lý User: Thành viên 1/Admin.

Các nâng cấp liên chức năng nên đưa vào backlog chung:

- Gửi email/thông báo khi trạng thái hoặc lịch phỏng vấn thay đổi.
- Automated test cho service/controller và CSDL kiểm thử riêng.
- Logging lỗi tập trung và trang lỗi production.
- Connection string theo từng môi trường triển khai.
- Optimistic concurrency (`rowversion`) cho Job/Application.
- Quét malware và private object storage cho CV ở môi trường production.
