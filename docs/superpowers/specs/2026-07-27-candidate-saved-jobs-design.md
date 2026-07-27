# Thiết kế chức năng tin tuyển dụng yêu thích

## Mục tiêu

Cho phép ứng viên lưu một tin tuyển dụng để xem lại sau, bỏ lưu khi không còn quan tâm và truy cập danh sách tin đã lưu từ khu vực tài khoản ứng viên.

## Phạm vi

- Hiển thị thao tác lưu/bỏ lưu trên thẻ việc làm công khai và trang chi tiết tin.
- Chỉ tài khoản có vai trò `Candidate` được tạo hoặc xóa dữ liệu lưu tin.
- Người chưa đăng nhập khi chọn lưu được chuyển tới đăng nhập và quay lại đúng trang trước đó.
- Cung cấp trang `Tin đã lưu` riêng và liên kết trong menu tài khoản ứng viên.
- Tin đóng hoặc hết hạn vẫn được liệt kê với trạng thái rõ ràng; tin đã xóa mềm không xuất hiện.
- Không thay đổi quy trình nộp hồ sơ và không dùng bảng `Applications` để biểu diễn việc lưu tin.

## Mô hình dữ liệu

Tạo bảng `SavedJobs`:

- `SavedJobID INT IDENTITY` là khóa chính.
- `CandidateUserID INT NOT NULL` tham chiếu `Users(UserID)`.
- `JobID INT NOT NULL` tham chiếu `Jobs(JobID)`.
- `SavedAt DATETIME NOT NULL` mặc định thời điểm hiện tại.
- Unique index trên `(CandidateUserID, JobID)` để ngăn lưu trùng.
- Cascade delete từ `Jobs` tới `SavedJobs`; không cascade từ `Users` để tránh chuỗi xóa ngoài ý muốn.

Model EF6 database-first được bổ sung entity `SavedJob`, `DbSet<SavedJob>` và quan hệ tương ứng trong `ATSMiniDBContext`. Script schema phải có thể chạy lặp lại an toàn trên database đã tồn tại.

## Backend và luồng dữ liệu

`JobsController` tiếp tục chịu trách nhiệm cho trạng thái lưu của một tin:

- Các truy vấn danh sách và chi tiết xác định `IsSaved` cho ứng viên hiện tại.
- Endpoint POST lưu tin xác thực anti-forgery, vai trò Candidate, tin tồn tại và chưa bị xóa.
- Endpoint POST bỏ lưu chỉ xóa bản ghi thuộc ứng viên hiện tại.
- Lưu lặp lại hoặc bỏ lưu một bản ghi không tồn tại được xử lý idempotent, không tạo lỗi 500.
- `returnUrl` chỉ được sử dụng khi là URL nội bộ; nếu không hợp lệ thì quay về trang chi tiết tin.

`CandidateController` cung cấp action GET `SavedJobs`, truy vấn theo người dùng hiện tại, sắp xếp mới lưu gần nhất và phân trang. View model riêng mang dữ liệu hiển thị, trạng thái mở/đóng/hết hạn và thời điểm lưu.

## Giao diện

- Thẻ việc làm công khai có nút bookmark với nhãn truy cập `Lưu tin` hoặc `Bỏ lưu`.
- Trang chi tiết đặt nút lưu cạnh hành động ứng tuyển, không làm giảm độ nổi bật của CTA ứng tuyển.
- Trang `Tin đã lưu` dùng lại ngôn ngữ thị giác của khu vực ứng viên, có trạng thái rỗng và liên kết quay lại danh sách việc làm.
- Menu avatar ứng viên có mục `Tin đã lưu`; không thêm mục này cho Admin/HR.
- Với tin đóng hoặc hết hạn, nút xem chi tiết chỉ hoạt động theo chính sách truy cập hiện có và giao diện luôn giải thích trạng thái.
- Thao tác dùng form POST hoạt động không phụ thuộc JavaScript; JavaScript chỉ được dùng để cải thiện phản hồi nếu cần.

## Xử lý lỗi và bảo mật

- Mọi thay đổi trạng thái dùng POST và `ValidateAntiForgeryToken`.
- Không nhận `CandidateUserID` từ client; luôn lấy từ session đã xác thực.
- Kiểm tra role tại controller bằng `AuthorizeRole("Candidate")`.
- Unique index bảo vệ dữ liệu trước thao tác lặp hoặc request đồng thời.
- Không tiết lộ tin bị xóa qua trang danh sách đã lưu.
- Redirect đăng nhập và redirect sau thao tác chỉ chấp nhận local URL.

## Kiểm thử và tiêu chí hoàn thành

- Regression test xác minh schema, mapping, unique index và controller authorization.
- Test xác minh ứng viên lưu được một tin, không lưu trùng, bỏ lưu được và không thao tác lên dữ liệu của người khác.
- Test giao diện xác minh nút bookmark có anti-forgery, trạng thái đúng và menu có liên kết `Tin đã lưu`.
- Kiểm thử trực tiếp: khách bấm lưu đi qua đăng nhập và quay lại; ứng viên lưu/bỏ lưu trên danh sách và chi tiết; danh sách đã lưu giữ nguyên sau đăng xuất/đăng nhập.
- MSBuild phải thành công và các regression test hiện có liên quan đến Jobs/Candidate/Navbar vẫn đạt.

## Ngoài phạm vi

- Không gửi thông báo khi tin sắp hết hạn.
- Không cho Admin/HR xem danh sách yêu thích của ứng viên.
- Không đồng bộ tin lưu ẩn danh từ local storage.
- Không thêm thư mục hoặc bộ sưu tập tùy chỉnh cho tin đã lưu.
