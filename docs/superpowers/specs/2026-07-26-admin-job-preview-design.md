# Admin/HR Job Preview Design

## Mục tiêu

Admin và HR xem nội dung tin tuyển dụng trong không gian quản trị, không bị chuyển sang giao diện ứng viên và không nhìn thấy lời kêu gọi ứng tuyển.

## Phạm vi

- Thêm trang `Jobs/AdminPreview/{id}` chỉ dành cho vai trò `Admin` và `HR`.
- Dùng lại `JobDetailsViewModel` và dữ liệu mô tả/yêu cầu hiện có; không thay đổi cơ sở dữ liệu.
- Trang xem trước dùng `_AdminLayout.cshtml`, hiển thị trạng thái tin, thông tin vị trí, mô tả, yêu cầu và các thao tác quay lại danh sách/chỉnh sửa.
- Chuyển các liên kết nội bộ tại danh sách tin, trang chỉnh sửa tin và trang đánh giá hồ sơ sang trang xem trước.
- Giữ nguyên `Jobs/Details/{id}` cho trang công khai và ứng viên, gồm luồng ứng tuyển hiện tại.

## Phân quyền và dữ liệu

- `AdminPreview` bắt buộc `[AuthorizeRole("Admin", "HR")]`.
- Trang nội bộ được phép xem tin đang đóng hoặc hết hạn, nhưng không xem bản ghi đã xóa.
- Thiếu `id` trả về HTTP 400; không tìm thấy tin hợp lệ trả về HTTP 404.
- Nội dung HTML mô tả và yêu cầu tiếp tục đi qua `RichTextSanitizer.Sanitize` trước khi hiển thị.

## Giao diện

- Giữ sidebar và topbar quản trị.
- Header phân biệt rõ đây là “Xem trước tin tuyển dụng”, kèm nhãn Đang mở/Đã đóng/Hết hạn.
- Khu vực chính trình bày mô tả và yêu cầu; cột phụ trình bày phòng ban, vị trí, địa điểm, hình thức, lương, lĩnh vực và hạn nộp.
- Không có nút “Ứng tuyển”, “Xem hồ sơ đã nộp” hoặc liên kết khám phá việc làm công khai.
- Có nút “Quay lại danh sách” và “Chỉnh sửa tin”.

## Kiểm thử chấp nhận

- Kiểm thử chính sách xác nhận action có phân quyền, dùng layout quản trị và không có CTA ứng tuyển.
- Kiểm thử xác nhận mọi liên kết Admin/HR liên quan trỏ đến `AdminPreview`, trong khi liên kết ứng viên vẫn trỏ đến `Details`.
- Dự án biên dịch thành công với Razor views.
- Kiểm tra trình duyệt xác nhận trang giữ giao diện quản trị, nội dung hiển thị đúng và không có lỗi console.
