# Thiết kế phân trang cho khu vực Admin/HR

## Mục tiêu

Bổ sung phân trang phía máy chủ cho các danh sách có thể tăng trưởng trong khu vực Admin/HR, đồng thời giữ nguyên bộ lọc, sắp xếp, phân quyền và các quy tắc nghiệp vụ hiện có. Việc phân trang phải giảm số bản ghi được tải từ cơ sở dữ liệu thay vì chỉ ẩn bớt dữ liệu trên trình duyệt.

## Hiện trạng đã xác minh

- Trang việc làm công khai đã phân trang với 9 tin mỗi trang.
- Trang hồ sơ ứng viên, lịch phỏng vấn và quản lý tài khoản đã phân trang.
- Trang tin tuyển dụng Admin/HR, phòng ban, vị trí tuyển dụng và thông báo đang tải toàn bộ kết quả.
- Dashboard chỉ hiển thị các khối tóm tắt có giới hạn số lượng và không cần phân trang.

## Phạm vi

Thêm phân trang 12 mục mỗi trang cho:

1. `Jobs/AdminIndex` — tin tuyển dụng dành cho Admin/HR.
2. `Departments/Index` — danh mục phòng ban.
3. `JobPositions/Index` — danh mục vị trí tuyển dụng.
4. `Notifications/Index` — thông báo của tài khoản Admin/HR hiện tại.

Không thay đổi phân trang hiện có của trang việc làm công khai, hồ sơ ứng viên, lịch phỏng vấn và tài khoản. Không phân trang các khối tóm tắt trên Dashboard.

## Thiết kế truy vấn

- Chuẩn hóa `page` về tối thiểu là 1.
- Áp dụng điều kiện phân quyền, xóa mềm, tìm kiếm và lọc trước khi đếm.
- Tính tổng số kết quả và tổng số trang; tổng số trang tối thiểu là 1 để giao diện và route ổn định khi không có kết quả.
- Nếu `page` lớn hơn tổng số trang, đưa về trang cuối hợp lệ.
- Sắp xếp ổn định trước `Skip` và `Take`; thêm khóa định danh làm tiêu chí phụ khi cần để tránh bản ghi đổi trang khi hai giá trị sắp xếp bằng nhau.
- Chỉ ánh xạ và tải 12 bản ghi của trang hiện tại từ cơ sở dữ liệu.
- Các số liệu tổng quan của trang tin tuyển dụng tiếp tục được tính trên toàn bộ tập dữ liệu phù hợp với ý nghĩa hiện tại, không dựa trên 12 bản ghi đang hiển thị.

## View model và giao diện

- Mở rộng `JobFilterViewModel` và `NotificationIndexViewModel` với thông tin trang, tổng kết quả và tổng số trang.
- Thay kiểu model `IEnumerable` của phòng ban và vị trí bằng view model danh sách chuyên biệt; không đưa entity trực tiếp làm hợp đồng phân trang của view.
- Mỗi trang hiển thị khoảng kết quả theo dạng “Đang xem X–Y trên tổng Z”. Khi không có kết quả, khoảng hiển thị là 0 và trạng thái rỗng hiện có được giữ nguyên.
- Thanh phân trang chỉ xuất hiện khi có từ hai trang trở lên, gồm nút Trước, các số trang và nút Sau. Trang hiện tại có `aria-current="page"`; nút không khả dụng không tạo liên kết sai.
- Mọi liên kết chuyển trang giữ nguyên từ khóa, bộ lọc, trạng thái và cách sắp xếp tương ứng.
- Tận dụng lớp CSS phân trang Admin hiện có; chỉ bổ sung CSS có phạm vi hẹp nếu bốn view cần căn chỉnh thêm.

## Hành vi nghiệp vụ cần giữ nguyên

- Thêm, sửa và xóa mềm phòng ban/vị trí vẫn tuân theo kiểm tra đang được tin tuyển dụng sử dụng.
- Thêm, sửa, xóa, đóng/mở và xem hồ sơ của tin tuyển dụng không thay đổi quy tắc phân quyền hoặc xác nhận hiện tại.
- Mở thông báo và đánh dấu tất cả đã đọc vẫn chỉ tác động đến thông báo của người dùng hiện tại.
- Các thao tác POST tiếp tục có anti-forgery token. Sau thao tác thành công, việc quay về trang đầu của danh sách là hành vi chấp nhận được; không bổ sung `returnUrl` để tránh mở rộng bề mặt chuyển hướng.

## Kiểm thử và kiểm chứng

- Viết kiểm thử hồi quy trước khi sửa để chứng minh bốn action chưa đáp ứng hợp đồng phân trang.
- Kiểm tra các trường hợp: trang âm hoặc bằng 0, trang vượt giới hạn, không có kết quả, đúng 12 kết quả, hơn 12 kết quả, và bộ lọc được giữ khi chuyển trang.
- Kiểm tra thứ tự truy vấn có tính xác định và `Skip`/`Take` diễn ra trước khi tải danh sách.
- Chạy toàn bộ kiểm thử PowerShell hiện có và build solution với Razor view compilation nếu môi trường hỗ trợ.
- Kiểm tra trực tiếp các trang Admin/HR ở kích thước desktop và mobile; xác nhận không tràn ngang và các thao tác hàng vẫn truy cập được.

## Rủi ro và kiểm soát

- Workspace đang có nhiều thay đổi chưa commit, bao gồm các controller và view liên quan. Chỉ sửa các đoạn cần thiết, kiểm tra diff theo từng file và không ghi đè thay đổi ngoài phạm vi.
- Đếm tổng và truy vấn dữ liệu là hai truy vấn cơ sở dữ liệu riêng. Đây là đánh đổi có chủ đích để có metadata phân trang chính xác; lợi ích là không tải toàn bộ bản ghi và dữ liệu điều hướng đúng.
- Liệt kê mọi số trang có thể dài nếu dữ liệu tăng rất lớn. Với quy mô ATS Mini hiện tại, cách này phù hợp; nếu tổng trang tăng đáng kể, có thể thay bằng cửa sổ số trang trong một thay đổi riêng.

## Ngoài phạm vi

- Không thay đổi schema hoặc EDMX.
- Không thêm thư viện phân trang bên thứ ba.
- Không thiết kế lại giao diện tổng thể.
- Không thay đổi CRUD, phân quyền hoặc quy tắc xóa hiện có trừ khi kiểm thử phát hiện lỗi trực tiếp cản trở phân trang.
