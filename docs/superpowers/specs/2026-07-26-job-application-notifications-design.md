# Thiết kế thông báo khi có ứng viên nộp hồ sơ

## Trạng thái

Đã được người dùng chấp thuận về nguyên tắc ngày 2026-07-26.

## Mục tiêu

Khi ứng viên nộp hồ sơ thành công, hệ thống tạo thông báo trong khu vực quản trị cho người đã đăng tin tuyển dụng. Nếu không thể xác định một người đăng tin hợp lệ, hệ thống gửi thông báo dự phòng cho các tài khoản Admin đang hoạt động.

Tính năng phải giúp người phụ trách phát hiện hồ sơ mới mà không gửi thông báo tràn lan cho toàn bộ HR và Admin.

## Phạm vi

### Bao gồm

- Thông báo trong ứng dụng, hiển thị ở khu vực quản trị.
- Chuông thông báo và số lượng chưa đọc trên thanh đầu trang quản trị.
- Danh sách thông báo gần đây của tài khoản đang đăng nhập.
- Mở hồ sơ liên quan từ thông báo.
- Đánh dấu một thông báo hoặc tất cả thông báo là đã đọc.
- Chọn người nhận theo quy tắc người đăng tin và Admin dự phòng.
- Ghi nhận lỗi tạo thông báo mà không làm thất bại hồ sơ đã nộp thành công.

### Không bao gồm

- Email, SMS hoặc thông báo đẩy.
- Cập nhật thời gian thực bằng SignalR hoặc WebSocket.
- Cho phép người dùng cấu hình loại thông báo.
- Phân công hoặc bàn giao HR phụ trách tin tuyển dụng.
- Thông báo cho ứng viên khi trạng thái hồ sơ thay đổi.

## Dữ kiện và giả định

- `Jobs.CreatedByUserID` hiện lưu tài khoản tạo tin và là nguồn xác định người nhận chính.
- Chỉ Admin và HR được phép tạo tin trong luồng hiện tại.
- Một hồ sơ được xem là nộp thành công sau khi dữ liệu hồ sơ, tệp CV, lịch sử trạng thái và nhật ký kiểm toán đã được lưu, đồng thời giao dịch nộp hồ sơ đã commit.
- Phiên bản đầu chấp nhận tải lại trang để cập nhật số lượng thông báo; không yêu cầu thời gian thực.

## Quy tắc chọn người nhận

1. Tìm `CreatedByUserID` của tin tuyển dụng.
2. Người tạo được xem là hợp lệ khi tài khoản tồn tại, đang hoạt động và có vai trò Admin hoặc HR.
3. Nếu người tạo hợp lệ, chỉ tạo một thông báo cho tài khoản đó.
4. Nếu `CreatedByUserID` rỗng, tài khoản không tồn tại, không hoạt động hoặc không còn vai trò Admin/HR, tạo một thông báo cho mỗi tài khoản Admin đang hoạt động.
5. Không gửi đồng thời cho Admin dự phòng khi người tạo vẫn hợp lệ, kể cả khi người tạo cũng là Admin.
6. Nếu không có người tạo hợp lệ và cũng không có Admin hoạt động, bỏ qua thông báo và ghi lỗi chẩn đoán; hồ sơ ứng tuyển vẫn giữ trạng thái thành công.

Quy tắc này dùng `CreatedByUserID` như đại diện tạm thời cho người phụ trách. Đây là một suy luận nghiệp vụ, không bảo đảm người tạo luôn là người thực sự xử lý tuyển dụng. Việc bổ sung `AssignedRecruiterUserID` được để ngoài phạm vi phiên bản đầu.

## Mô hình dữ liệu

Thêm bảng `Notifications`:

| Trường | Kiểu dự kiến | Quy tắc |
|---|---|---|
| `NotificationID` | `INT IDENTITY` | Khóa chính |
| `RecipientUserID` | `INT` | Bắt buộc, khóa ngoại tới `Users` |
| `ApplicationID` | `INT NULL` | Hồ sơ liên quan; cho phép rỗng để hệ thống có thể mở rộng |
| `NotificationType` | `NVARCHAR(50)` | Phiên bản đầu dùng `NEW_APPLICATION` |
| `Title` | `NVARCHAR(150)` | Nội dung tiêu đề đã chụp tại thời điểm tạo |
| `Message` | `NVARCHAR(500)` | Tên ứng viên và vị trí tuyển dụng |
| `CreatedAt` | `DATETIME` | Thời điểm tạo |
| `ReadAt` | `DATETIME NULL` | Rỗng nghĩa là chưa đọc |

Không lưu URL trực tiếp. Liên kết được tạo từ `ApplicationID` để tránh URL cũ hoặc không an toàn. Thêm chỉ mục theo `(RecipientUserID, ReadAt, CreatedAt)` để phục vụ đếm chưa đọc và lấy danh sách mới nhất.

Mô hình Entity Framework phải tiếp tục theo cách Database First đang dùng trong dự án. Script cơ sở dữ liệu, mapping và lớp entity phải đồng bộ với nhau.

## Luồng xử lý

### Khi ứng viên nộp hồ sơ

1. Luồng hiện có kiểm tra dữ liệu và CV.
2. Hệ thống lưu hồ sơ, tệp CV, lịch sử trạng thái và audit log trong giao dịch hiện có.
3. Giao dịch nộp hồ sơ commit thành công.
4. Sau commit, dịch vụ thông báo xác định người nhận và lưu thông báo.
5. Nếu bước 4 lỗi, hệ thống ghi log chẩn đoán nhưng vẫn trả kết quả nộp hồ sơ thành công cho ứng viên.

Việc tạo thông báo diễn ra sau commit nhằm bảo đảm lỗi phụ trợ không rollback hồ sơ ứng tuyển. Đánh đổi là có khả năng hiếm gặp hồ sơ đã được lưu nhưng thông báo không được tạo. Phiên bản đầu chấp nhận rủi ro này và yêu cầu ghi log để có thể phát hiện; mô hình outbox đáng tin cậy hơn nhưng vượt quá phạm vi ATS mini.

### Khi người quản trị sử dụng thông báo

1. Mỗi yêu cầu hiển thị thanh đầu trang truy vấn số thông báo chưa đọc của tài khoản hiện tại.
2. Chuông mở danh sách rút gọn các thông báo mới nhất.
3. Người dùng có thể mở trang danh sách đầy đủ.
4. Khi mở một thông báo, biểu mẫu POST có anti-forgery token gửi tới endpoint mở thông báo. Hệ thống kiểm tra thông báo thuộc tài khoản hiện tại, đặt `ReadAt` nếu cần, rồi chuyển tới trang duyệt hồ sơ.
5. Lệnh “đánh dấu tất cả đã đọc” chỉ cập nhật thông báo của tài khoản hiện tại.

## Thành phần và ranh giới trách nhiệm

- `NotificationsController`: đọc danh sách, mở thông báo, đánh dấu đã đọc; chỉ dành cho Admin và HR.
- `NotificationService`: chọn người nhận và tạo thông báo. Thành phần này không xử lý việc nộp hồ sơ.
- `JobsController`: tiếp tục sở hữu luồng ứng viên nộp hồ sơ và chỉ gọi dịch vụ thông báo sau khi giao dịch thành công.
- ViewModel thông báo: đặt trong `ViewModels/Notifications/`; không truyền trực tiếp entity ra view.
- Giao diện: dùng `_AdminTopbar.cshtml` và các view riêng của `Notifications`; không thay đổi layout công khai.

## Phân quyền và an toàn

- Chỉ tài khoản Admin hoặc HR đã đăng nhập được truy cập controller thông báo.
- Mọi truy vấn đọc hoặc cập nhật phải lọc theo `RecipientUserID` bằng ID trong session; không tin ID người nhận từ trình duyệt.
- Không đưa email, số điện thoại hoặc đường dẫn CV vào nội dung thông báo.
- Nội dung tên ứng viên và chức danh phải được Razor mã hóa khi hiển thị.
- Mọi yêu cầu thay đổi trạng thái đọc, bao gồm thao tác mở thông báo, dùng POST và anti-forgery token.

## Giao diện

- Chuông nằm trên thanh đầu trang quản trị.
- Huy hiệu chỉ hiện khi số chưa đọc lớn hơn 0; giá trị lớn hơn 99 hiển thị `99+`.
- Mỗi mục hiển thị tiêu đề, nội dung ngắn, thời gian và trạng thái đã đọc.
- Thông báo mới có nội dung dự kiến: `Nguyễn Văn A vừa ứng tuyển Lập trình viên Backend.`
- Nếu hồ sơ đã bị xóa mềm hoặc không còn truy cập được, thông báo vẫn có thể được đánh dấu đã đọc và hiển thị thông báo lỗi phù hợp thay vì làm lộ dữ liệu.
- Giao diện tuân theo phong cách quản trị hiện tại và hỗ trợ bàn phím, nhãn truy cập cho nút chuông.

## Xử lý lỗi và tính nhất quán

- Không tạo thông báo nếu giao dịch nộp hồ sơ rollback.
- Lỗi tạo thông báo không thay đổi kết quả nộp hồ sơ đã commit và được ghi bằng cơ chế `System.Diagnostics.Trace` hiện có của ứng dụng.
- Không được tạo bản ghi trùng cho cùng `ApplicationID`, `RecipientUserID` và `NotificationType`; áp dụng ràng buộc duy nhất hoặc kiểm tra tương đương có khả năng chống gửi lặp.
- Nếu người dùng bấm mở thông báo nhiều lần, `ReadAt` chỉ được đặt lần đầu.
- Các truy vấn topbar phải giới hạn số bản ghi và không tải toàn bộ nội dung không cần thiết.

## Kiểm thử chấp nhận

1. HR đang hoạt động tạo tin; ứng viên nộp hồ sơ; chỉ HR đó nhận một thông báo.
2. Admin đang hoạt động tạo tin; ứng viên nộp hồ sơ; chỉ Admin đó nhận một thông báo.
3. Người tạo bị vô hiệu hóa; mỗi Admin đang hoạt động nhận đúng một thông báo.
4. Tin cũ không có `CreatedByUserID`; áp dụng Admin dự phòng.
5. Không có Admin dự phòng; hồ sơ vẫn nộp thành công và lỗi thông báo được ghi nhận.
6. Nộp hồ sơ thất bại hoặc rollback; không có thông báo.
7. Một HR không thể đọc hoặc đánh dấu thông báo của tài khoản khác bằng cách sửa ID trên URL.
8. Mở thông báo đánh dấu đã đọc và chuyển đúng trang hồ sơ.
9. Đánh dấu tất cả chỉ tác động tới thông báo của tài khoản hiện tại.
10. Gọi lại logic tạo thông báo cho cùng hồ sơ không tạo bản ghi trùng.
11. Huy hiệu ẩn khi không có thông báo chưa đọc và hiển thị `99+` khi vượt 99.
12. Hồ sơ liên quan bị xóa mềm không gây lỗi máy chủ hoặc làm lộ thông tin.

## Tiêu chí hoàn thành

- Script cơ sở dữ liệu và mô hình EF thống nhất.
- Thông báo được tạo đúng quy tắc người đăng tin/Admin dự phòng.
- Chuông, danh sách, mở thông báo và đánh dấu đã đọc hoạt động với đúng phân quyền.
- Luồng nộp hồ sơ không thất bại do lỗi thông báo.
- Các kịch bản chấp nhận quan trọng có kiểm thử tự động phù hợp và kiểm tra thủ công trong trình duyệt.

## Phương án đã loại

### Gửi cho toàn bộ Admin và HR

Dễ triển khai nhưng tạo nhiễu và không phản ánh trách nhiệm xử lý hồ sơ.

### Chỉ gửi cho người tạo tin, không dự phòng

Ít nhiễu nhất nhưng có thể làm mất thông báo khi tài khoản bị khóa, bị xóa hoặc dữ liệu tin cũ thiếu người tạo.

### Thêm HR phụ trách ngay trong phiên bản đầu

Đúng nghiệp vụ dài hạn hơn nhưng mở rộng phạm vi sang phân công, bàn giao và quyền quản lý tin. Phần này nên là một thay đổi riêng sau khi tính năng thông báo cơ bản ổn định.
