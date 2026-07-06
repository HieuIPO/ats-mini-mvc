# Phân công công việc - Dự án ATS Mini

## 1. Thông tin chung

**Tên đề tài:** Hệ thống quản lý tuyển dụng và theo dõi ứng viên (ATS Mini)

**Môn học:** Lập trình Web MVC

**Công nghệ thống nhất:**

- ASP.NET MVC 5 / .NET Framework
- C#
- Entity Framework 6
- SQL Server
- Database-first: thiết kế database trước, sau đó sinh Entity Framework model
- Razor View, HTML Helper, ViewModel, Validation
- Bootstrap cho giao diện chung
- AJAX / Partial View cho một số chức năng cập nhật động

**Mục tiêu sản phẩm:** Xây dựng website ATS mini mức khá đầy đủ, có đăng nhập, phân quyền, quản lý tin tuyển dụng, nộp hồ sơ, upload CV, theo dõi trạng thái ứng viên và lịch phỏng vấn cơ bản.

## 2. Vai trò người dùng

| Vai trò | Mô tả |
|---|---|
| Admin | Quản lý tài khoản, vai trò, cấu hình chung và hỗ trợ tích hợp hệ thống |
| HR | Quản lý tin tuyển dụng, xem hồ sơ ứng tuyển, cập nhật trạng thái, lập lịch phỏng vấn |
| Ứng viên | Xem tin tuyển dụng, nộp hồ sơ, upload CV, theo dõi trạng thái ứng tuyển |

## 3. Nguyên tắc chia việc

Nhóm chia theo **module nghiệp vụ dọc**, mỗi người tự làm trọn phần của mình:

- Tự làm từ Controller đến View, xử lý EF, validation và test dữ liệu mẫu.
- Không chia kiểu một người làm database, một người làm controller, một người làm giao diện vì dễ bị phụ thuộc lẫn nhau.
- Mỗi thành viên phải có module riêng có thể demo độc lập.
- Khi ghép lại, các module tạo thành luồng demo chung: HR/Admin tạo tin tuyển dụng -> ứng viên nộp hồ sơ -> HR xử lý trạng thái và lịch phỏng vấn.

## 4. Phân công công việc

### 4.1. Nguyên tắc hiểu đúng khi làm trang web

Dự án này là **website ASP.NET MVC để người dùng thao tác trực tiếp trên trình duyệt**, không phải chỉ làm database hoặc viết báo cáo. Mỗi thành viên cần làm trọn phần của mình gồm:

- Controller xử lý chức năng.
- View/Razor để người dùng thao tác trên web.
- ViewModel/validation nếu có form nhập liệu.
- Kết nối Entity Framework tới các bảng liên quan.
- Dữ liệu mẫu để tự test module.
- Giao diện bám theo layout Bootstrap chung của nhóm.

Mỗi người làm theo một nhánh riêng trên GitHub:

| Thành viên | Nhánh GitHub | Cụm trang phụ trách |
|---|---|---|
| Thành viên 1 | `auth-layout1` | Đăng nhập, phân quyền, dashboard, layout chung |
| Thành viên 2 | `jobs2` | Tin tuyển dụng, phòng ban, vị trí tuyển dụng |
| Thành viên 3 | `applications3` | Hồ sơ ứng tuyển, upload CV, trạng thái, phỏng vấn |

Luồng website cuối cùng cần chạy được:

`Đăng nhập -> tạo tin tuyển dụng -> ứng viên nộp hồ sơ -> HR xem hồ sơ -> đổi trạng thái -> tạo lịch phỏng vấn -> nhập kết quả`

### Thành viên 1: Leader, tài khoản, phân quyền, giao diện mẫu, tích hợp

**Người phụ trách:** ....................................

**Nhánh làm việc:** `auth-layout1`

**Phạm vi chính:**

- Thiết kế database ban đầu dùng chung cho cả nhóm.
- Tạo giao diện mẫu để các thành viên khác áp dụng.
- Làm chức năng đăng nhập, đăng xuất, phân quyền.
- Quản lý tài khoản người dùng cơ bản.
- Tích hợp source của cả nhóm, kiểm tra lỗi khi ghép module.

**Trang web cần làm:**

| Trang | Đường dẫn gợi ý | Mục đích |
|---|---|---|
| Đăng nhập | `/Account/Login` | Người dùng nhập tài khoản/mật khẩu để vào hệ thống |
| Đăng xuất | `/Account/Logout` | Thoát khỏi phiên đăng nhập |
| Dashboard | `/Dashboard/Index` hoặc `/Admin/Index` | Trang đầu sau khi đăng nhập, hiển thị tổng quan hệ thống |
| Không có quyền | `/Account/AccessDenied` | Thông báo khi người dùng truy cập sai quyền |
| Quản lý tài khoản | `/Admin/Users` | Admin xem/thêm/sửa tài khoản nếu đủ thời gian |
| Thông tin cá nhân | `/Profile/Index` | Người dùng xem/cập nhật thông tin cá nhân cơ bản |

**Chức năng cần code:**

- Đăng nhập.
- Đăng xuất.
- Kiểm tra quyền theo vai trò: Admin, HR, Ứng viên.
- Trang quản lý tài khoản cơ bản cho Admin.
- Trang cập nhật thông tin cá nhân cơ bản.
- Menu hiển thị theo vai trò.
- Layout chung cho website.
- Layout riêng cho khu vực quản trị nếu cần.
- Tạo mẫu giao diện cho bảng danh sách, form thêm/sửa, trang chi tiết và thông báo.

**Controller/View gợi ý:**

- `AccountController`
- `AdminController`
- `DashboardController` nếu tách dashboard riêng
- `ProfileController` nếu cần tách riêng hồ sơ cá nhân
- `Views/Account/`
- `Views/Admin/`
- `Views/Dashboard/`
- `Views/Shared/_Layout.cshtml`
- `Views/Shared/_AdminLayout.cshtml` nếu có khu vực quản trị riêng

**Bảng database liên quan:**

- `Users`
- `Roles`
- Có thể thêm `UserRoles` nếu muốn một tài khoản có nhiều vai trò

**Kết quả cần bàn giao:**

- Đăng nhập/đăng xuất chạy được.
- Mỗi vai trò vào đúng màn hình của mình.
- Thành viên khác có thể đưa View của mình vào layout chung.
- Có đủ tài khoản mẫu để test: Admin, HR, Ứng viên.
- Có giao diện mẫu để Thành viên 2 và Thành viên 3 áp dụng thống nhất.

### Thành viên 2: Quản lý tuyển dụng

**Người phụ trách:** ....................................

**Nhánh làm việc:** `jobs2`

**Phạm vi chính:**

- Quản lý thông tin tin tuyển dụng.
- Quản lý phòng ban, vị trí tuyển dụng, yêu cầu công việc.
- Cho HR/Admin tạo, sửa, xóa, ẩn/hiện tin tuyển dụng.
- Cho ứng viên xem danh sách tin đang mở.

**Trang web cần làm:**

| Trang | Đường dẫn gợi ý | Mục đích |
|---|---|---|
| Danh sách tin tuyển dụng | `/Jobs/Index` | HR/Admin xem toàn bộ tin, tìm kiếm/lọc |
| Chi tiết tin tuyển dụng | `/Jobs/Details/{id}` | Xem đầy đủ mô tả, yêu cầu, số lượng, trạng thái |
| Thêm tin tuyển dụng | `/Jobs/Create` | HR/Admin tạo tin mới |
| Sửa tin tuyển dụng | `/Jobs/Edit/{id}` | HR/Admin cập nhật nội dung tin |
| Đóng/mở tin tuyển dụng | `/Jobs/Close/{id}` hoặc nút trong danh sách | Chuyển trạng thái đang mở/đã đóng |
| Tin tuyển dụng công khai | `/Jobs/Public` hoặc `/Jobs/Openings` | Ứng viên xem các tin đang mở |
| Quản lý phòng ban | `/Departments/Index` | Thêm/sửa/xóa phòng ban |
| Quản lý vị trí | `/JobPositions/Index` | Thêm/sửa/xóa vị trí tuyển dụng |

**Chức năng cần code:**

- Danh sách tin tuyển dụng.
- Xem chi tiết tin tuyển dụng.
- Thêm tin tuyển dụng.
- Sửa tin tuyển dụng.
- Xóa hoặc đóng tin tuyển dụng.
- Tìm kiếm tin tuyển dụng theo từ khóa.
- Lọc tin theo phòng ban, vị trí, địa điểm, loại công việc hoặc trạng thái.
- Hiển thị trạng thái tin: đang mở / đã đóng.

**Controller/View gợi ý:**

- `JobsController`
- `DepartmentsController` nếu tách quản lý phòng ban
- `JobPositionsController` nếu tách quản lý vị trí
- `Views/Jobs/`
- `Views/Departments/`
- `Views/JobPositions/`

**Bảng database liên quan:**

- `Jobs`
- `Departments`
- `JobPositions`
- Có thể thêm `Skills` hoặc `JobSkills` nếu nhóm muốn quản lý kỹ năng riêng

**Kết quả cần bàn giao:**

- HR/Admin quản lý được tin tuyển dụng.
- Ứng viên xem được tin đang mở.
- Tin tuyển dụng có đủ thông tin để ứng viên nộp hồ sơ.
- Có đủ dữ liệu mẫu để test danh sách, tìm kiếm và lọc.
- Các trang dùng đúng layout chung, không tự thiết kế giao diện riêng khác phong cách nhóm.

### Thành viên 3: Ứng tuyển, upload CV, theo dõi ứng viên, lịch phỏng vấn

**Người phụ trách:** ....................................

**Nhánh làm việc:** `applications3`

**Phạm vi chính:**

- Xử lý luồng ứng viên nộp hồ sơ vào tin tuyển dụng.
- Upload CV.
- HR xem danh sách hồ sơ ứng tuyển.
- HR cập nhật trạng thái ứng viên.
- Quản lý lịch phỏng vấn cơ bản.
- Áp dụng AJAX / Partial View cho cập nhật trạng thái hoặc lọc danh sách nếu làm kịp.

**Trang web cần làm:**

| Trang | Đường dẫn gợi ý | Mục đích |
|---|---|---|
| Form nộp hồ sơ | `/Applications/Create?jobId=...` | Ứng viên nhập thông tin và upload CV |
| Danh sách hồ sơ | `/Applications/Index` | HR xem danh sách hồ sơ, tìm kiếm/lọc theo trạng thái |
| Chi tiết hồ sơ | `/Applications/Details/{id}` | HR xem thông tin ứng viên, CV, ghi chú, trạng thái |
| Cập nhật trạng thái | `/Applications/UpdateStatus/{id}` | HR đổi trạng thái hồ sơ |
| Lịch sử trạng thái | `/Applications/StatusHistory/{id}` | Xem quá trình xử lý hồ sơ |
| Danh sách phỏng vấn | `/Interviews/Index` | HR xem các lịch phỏng vấn |
| Tạo lịch phỏng vấn | `/Interviews/Create?applicationId=...` | HR đặt lịch phỏng vấn cho ứng viên |
| Cập nhật kết quả phỏng vấn | `/Interviews/Edit/{id}` | Ghi kết quả, nhận xét sau phỏng vấn |

**Chức năng cần code:**

- Form nộp hồ sơ ứng tuyển.
- Upload CV.
- Lưu đường dẫn file CV vào database, không lưu file trực tiếp trong database.
- Danh sách hồ sơ ứng tuyển theo tin tuyển dụng.
- Xem chi tiết hồ sơ ứng viên.
- Cập nhật trạng thái hồ sơ.
- Ghi chú của HR cho hồ sơ.
- Tạo lịch phỏng vấn.
- Xem danh sách lịch phỏng vấn.
- Tìm kiếm/lọc ứng viên theo trạng thái.
- AJAX đổi trạng thái hồ sơ hoặc load danh sách lọc nếu kịp.

**Trạng thái ứng tuyển gợi ý:**

- Mới nộp
- Đang xem xét
- Mời phỏng vấn
- Đạt
- Trượt

**Controller/View gợi ý:**

- `ApplicationsController`
- `InterviewsController`
- `Views/Applications/`
- `Views/Interviews/`

**Bảng database liên quan:**

- `Applications`
- `ApplicationStatuses`
- `Interviews`
- `CandidateFiles` nếu tách file riêng
- Hoặc dùng cột `CVFilePath` trong bảng `Applications`

**Quy tắc upload CV:**

- Lưu file vào thư mục `~/Uploads/CVs/`.
- Database chỉ lưu đường dẫn tương đối, ví dụ `Uploads/CVs/cv-nguyenvana.pdf`.
- Không lưu file dạng blob trong database.

**Kết quả cần bàn giao:**

- Ứng viên nộp hồ sơ và upload CV được.
- HR xem và cập nhật trạng thái hồ sơ được.
- Tạo/xem lịch phỏng vấn được.
- Có đủ dữ liệu mẫu để demo luồng xử lý ứng viên.
- Nếu làm AJAX, ưu tiên cập nhật trạng thái hồ sơ hoặc lọc danh sách hồ sơ, không làm lan man.

## 5. Database dùng chung

Database ban đầu nên có tối thiểu các bảng sau:

| Bảng | Mục đích |
|---|---|
| `Users` | Lưu tài khoản Admin, HR, Ứng viên |
| `Roles` | Lưu vai trò người dùng |
| `Departments` | Lưu phòng ban tuyển dụng |
| `JobPositions` | Lưu vị trí/chức danh tuyển dụng |
| `Jobs` | Lưu tin tuyển dụng |
| `Applications` | Lưu hồ sơ ứng tuyển |
| `ApplicationStatuses` | Lưu danh mục trạng thái ứng tuyển |
| `Interviews` | Lưu lịch phỏng vấn |

Quan hệ tối thiểu:

- `Roles` 1 - N `Users`
- `Departments` 1 - N `Jobs`
- `JobPositions` 1 - N `Jobs`
- `Jobs` 1 - N `Applications`
- `ApplicationStatuses` 1 - N `Applications`
- `Applications` 1 - N `Interviews`

## 6. Quy tắc khi thay đổi database

Vì database là phần dùng chung, không ai tự ý đổi âm thầm. Nếu trong quá trình code thấy thiếu bảng hoặc cột, thành viên cần báo lại:

- Tên bảng/cột muốn thêm hoặc sửa.
- Lý do cần thay đổi.
- Module nào bị ảnh hưởng.
- Có ảnh hưởng đến dữ liệu mẫu hay không.
- Có cần scaffold/update Entity Framework model lại hay không.

Leader sẽ cập nhật database chung, sau đó thông báo lại cho cả nhóm.

## 7. Quy tắc code chung

- Mỗi module có Controller riêng, View riêng.
- Không sửa module của người khác nếu chưa trao đổi.
- Không đặt logic của module này vào Controller của module khác.
- `JobsController` chỉ xử lý logic tin tuyển dụng.
- `ApplicationsController` chỉ xử lý nộp hồ sơ, upload CV và theo dõi ứng tuyển.
- `AdminController` chỉ xử lý các chức năng quản trị.
- Dùng ViewModel cho form nhập liệu và validation nếu cần.
- Mỗi form quan trọng phải có validation.
- Mỗi người tự tạo dữ liệu mẫu để test module của mình.
- Khi hoàn thành module, phải demo được luồng chính của module.

## 8. Giao diện chung

Cả nhóm dùng chung một bộ giao diện để website đồng nhất:

- Navbar/menu theo vai trò.
- Mẫu bảng danh sách.
- Mẫu form thêm/sửa.
- Mẫu nút thêm, sửa, xóa, xem chi tiết.
- Mẫu thông báo thành công/thất bại.
- Mẫu trang danh sách có tìm kiếm/lọc.
- Mẫu trang chi tiết.

Thành viên khác khi code View cần bám theo layout và class Bootstrap chung, không tự thiết kế mới hoàn toàn.

## 9. Tiến độ gợi ý

### Tuần 1

- Chốt database ban đầu.
- Tạo project ASP.NET MVC 5.
- Kết nối SQL Server và Entity Framework Database First.
- Tạo layout chung.
- Mỗi thành viên tạo khung Controller/View cho module của mình.

### Tuần 2

- Hoàn thành CRUD chính của từng module.
- Có đủ dữ liệu mẫu để test.
- Chạy được các màn hình cơ bản.

### Tuần 3

- Thêm validation, tìm kiếm, lọc.
- Thêm upload CV.
- Thêm cập nhật trạng thái hồ sơ.
- Thêm lịch phỏng vấn.

### Tuần 4

- Tích hợp source.
- Sửa lỗi giao diện và lỗi database.
- Bổ sung AJAX/Partial View nếu kịp.
- Viết báo cáo, chụp màn hình minh họa, chuẩn bị demo.

### Nếu còn dư thời gian

- Dashboard thống kê.
- Audit log thao tác.
- Gửi email/thông báo.
- Tối ưu truy vấn Entity Framework.
- Xuất danh sách ứng viên ra Excel/PDF.

## 10. Luồng demo cuối kỳ

Luồng demo đề nghị:

1. Admin đăng nhập.
2. Admin/HR tạo tin tuyển dụng.
3. Ứng viên đăng nhập hoặc vào trang tin tuyển dụng.
4. Ứng viên xem chi tiết tin và nộp hồ sơ, upload CV.
5. HR đăng nhập, xem danh sách hồ sơ.
6. HR cập nhật trạng thái ứng viên.
7. HR tạo lịch phỏng vấn.
8. Xem lại trạng thái hồ sơ và lịch phỏng vấn.

## 11. Ghi chú phản biện

Không nên mở rộng quá sớm sang các chức năng nâng cao khi 3 module chính chưa chạy ổn định. Điểm cuối kỳ ưu tiên sản phẩm đúng, đầy đủ, rõ ràng và demo được. Các phần như dashboard, email, audit log, tối ưu truy vấn chỉ nên làm sau khi đã có luồng chính hoàn chỉnh.

## 12. Gợi ý để đạt điểm cao

Mục tiêu thực tế không phải là nhồi thật nhiều chức năng, mà là làm cho sản phẩm khó bị trừ điểm: đúng mô hình MVC, chạy ổn định, có nghiệp vụ rõ, báo cáo logic và demo mạch lạc.

### 12.1. Ưu tiên bắt buộc

Những phần dưới đây nên hoàn thành trước khi làm chức năng nâng cao:

- Luồng nghiệp vụ chính phải chạy trọn vẹn: HR/Admin tạo tin tuyển dụng -> ứng viên nộp hồ sơ -> HR xem hồ sơ -> HR cập nhật trạng thái -> HR tạo lịch phỏng vấn.
- Phân quyền phải rõ: Admin, HR và Ứng viên nhìn thấy đúng chức năng của mình.
- Mỗi form quan trọng phải có validation, không để dữ liệu sai vẫn lưu vào database.
- Database phải có quan hệ rõ ràng, có khóa chính, khóa ngoại và dữ liệu mẫu.
- Upload CV phải lưu file trong `~/Uploads/CVs/`, database chỉ lưu đường dẫn file.
- Giao diện phải đồng nhất, không để mỗi module có một kiểu trình bày khác nhau.
- Mỗi thành viên phải demo được module của mình, tránh tình trạng chỉ một người hiểu toàn bộ dự án.

### 12.2. Ba điểm nên làm để gây ấn tượng

Nếu các chức năng chính đã ổn, nhóm nên ưu tiên 3 điểm sau:

| Điểm nổi bật | Lý do nên làm | Mức độ ưu tiên |
|---|---|---|
| Phân quyền rõ theo vai trò | Thể hiện chủ đề Authentication/Authorization, dễ giải thích khi thuyết trình | Cao |
| AJAX/Partial View khi đổi trạng thái hồ sơ | Thể hiện cập nhật dữ liệu động, bám chủ đề nghiên cứu giữa kỳ | Cao |
| Dashboard thống kê đơn giản | Làm hệ thống nhìn hoàn chỉnh hơn, hỗ trợ phần báo cáo và demo | Trung bình |

Dashboard chỉ cần các số liệu cơ bản:

- Tổng số tin tuyển dụng.
- Tổng số hồ sơ ứng tuyển.
- Số hồ sơ theo từng trạng thái.
- Số lịch phỏng vấn sắp tới.

### 12.3. Validation nên có

Các lỗi nhập liệu cần chặn:

- Email ứng viên phải đúng định dạng.
- Số điện thoại không được rỗng.
- CV chỉ nhận các file phù hợp như `.pdf`, `.doc`, `.docx`.
- Tin tuyển dụng phải có tiêu đề, mô tả, yêu cầu và trạng thái.
- Không tạo lịch phỏng vấn trước ngày hiện tại.
- Không cho ứng viên nộp hồ sơ vào tin tuyển dụng đã đóng.

### 12.4. Báo cáo nên trình bày rõ đã áp dụng kiến thức môn học

Trong báo cáo, nhóm nên có một phần riêng tên là **Kiến thức MVC đã áp dụng**. Nội dung nên nêu rõ:

- MVC: Controller xử lý yêu cầu, Model/Entity biểu diễn dữ liệu, View hiển thị giao diện.
- Entity Framework 6 Database First: thiết kế SQL Server trước, sinh model từ database.
- Razor View và Layout: dùng layout chung để giao diện đồng nhất.
- Validation: kiểm tra dữ liệu đầu vào ở form.
- Authentication/Authorization: đăng nhập và phân quyền theo vai trò.
- Partial View/AJAX: dùng cho cập nhật trạng thái hoặc lọc danh sách nếu có.

### 12.5. Chuẩn bị demo

Trước ngày báo cáo, nhóm nên chuẩn bị sẵn dữ liệu mẫu:

- 1 tài khoản Admin.
- 1 tài khoản HR.
- 1 tài khoản Ứng viên.
- Ít nhất 3 tin tuyển dụng.
- Ít nhất 5 hồ sơ ứng tuyển ở nhiều trạng thái khác nhau.
- Ít nhất 2 lịch phỏng vấn.

Khi demo, không nên bấm thử ngẫu nhiên. Nên đi theo kịch bản cố định:

1. Admin/HR đăng nhập.
2. Tạo hoặc xem tin tuyển dụng.
3. Ứng viên xem tin và nộp hồ sơ.
4. HR xem hồ sơ mới.
5. HR đổi trạng thái hồ sơ.
6. HR tạo lịch phỏng vấn.
7. Mở dashboard hoặc danh sách thống kê nếu có.

### 12.6. Những phần chỉ làm khi còn thời gian

Các chức năng sau có thể giúp bài tốt hơn, nhưng không nên làm trước khi luồng chính ổn định:

- Gửi email thông báo.
- Audit log ghi lại thao tác.
- Xuất Excel/PDF.
- Tối ưu truy vấn Entity Framework.
- Biểu đồ thống kê nâng cao.

Nếu thời gian gấp, nên bỏ các phần này để tập trung sửa lỗi, làm báo cáo và luyện demo.
