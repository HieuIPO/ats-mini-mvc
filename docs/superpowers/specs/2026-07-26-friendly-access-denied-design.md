# Thiết kế trang 403 thân thiện

## Trạng thái

Đã được người dùng duyệt qua mockup ngày 2026-07-26.

## Mục tiêu

Thay trang “Không có quyền truy cập” mang cảm giác cảnh báo bằng một trang hướng dẫn bình tĩnh, an toàn và thân thiện. Trang giúp người dùng hiểu rằng tài khoản hiện tại chưa phù hợp và cung cấp hai lối đi rõ ràng mà không quy trách nhiệm cho họ.

## Nội dung

- Mã trạng thái nhỏ: `403`.
- Tiêu đề: `Bạn chưa thể mở trang này`.
- Mô tả: `Tài khoản hiện tại chưa có vai trò phù hợp để truy cập chức năng này. Bạn có thể quay về khu vực an toàn hoặc đăng nhập bằng tài khoản khác.`
- Nút chính: `Về trang phù hợp`.
- Nút phụ: `Đăng nhập tài khoản khác`.
- Không hiển thị đường dẫn yêu cầu hoặc URL bị chặn.

## Hành vi

- Nếu tài khoản hiện tại là Admin hoặc HR, nút chính dẫn tới Dashboard.
- Với các tài khoản khác, nút chính dẫn tới trang chủ công khai.
- Nút phụ luôn dẫn tới trang đăng nhập.
- Controller tiếp tục trả HTTP 403; thay đổi chỉ tác động tới cách trình bày và điều hướng.

## Bố cục và hình ảnh

- Trang độc lập, không dùng navbar/footer của layout công khai để giữ đúng trải nghiệm tập trung trong mockup.
- Khung nội dung rộng tối đa khoảng 90rem, chia hai cột 56/44 trên desktop.
- Bên trái chứa mã 403, tiêu đề, mô tả và hai nút.
- Bên phải dùng một ảnh minh họa riêng: cánh cửa xanh nhạt, biểu tượng khiên có dấu kiểm và chậu cây. Minh họa không dùng ổ khóa, dấu chấm than hoặc màu cảnh báo.
- Nền trắng ngà; chữ xanh navy đậm; nút chính teal; nút phụ viền teal.
- Không dùng card lớn bao quanh toàn bộ nội dung, không dùng bóng đổ nặng hoặc gradient tím/xanh kiểu AI.

## Responsive và khả năng truy cập

- Ở màn hình nhỏ, chuyển thành một cột; nội dung đứng trước minh họa.
- Hai nút chiếm toàn chiều rộng trên mobile.
- Tiêu đề dùng `clamp()` để không tràn màn hình.
- Các liên kết có focus ring rõ, trạng thái hover và active.
- Minh họa là nội dung trang trí nên dùng `alt=""` và `aria-hidden="true"`.
- Trang có skip link và một thẻ `main` gắn với tiêu đề `h1`.
- Tôn trọng `prefers-reduced-motion`.

## Tệp dự kiến

- Sửa `ATSMiniProject/Views/Account/AccessDenied.cshtml` thành trang HTML độc lập.
- Tạo `ATSMiniProject/Content/css/access-denied.css` với selector chỉ dành cho trang này.
- Tạo `ATSMiniProject/Content/images/errors/access-denied-door.png` từ một ảnh minh họa standalone mới; không cắt từ mockup.
- Thêm hai asset mới vào `ATSMiniProject/ATSMiniProject.csproj` bằng hunk riêng, không gom thay đổi cũ.
- Tạo kiểm thử policy xác nhận HTTP 403, nội dung, điều hướng theo vai trò và việc loại bỏ đường dẫn yêu cầu.

## Kiểm thử chấp nhận

1. Trang trả HTTP 403 nhưng hiển thị giao diện thân thiện, không có từ ngữ cảnh báo gay gắt.
2. Không có `returnUrl`, “Đường dẫn yêu cầu” hoặc URL bị chặn trong HTML.
3. HR/Admin thấy nút chính dẫn về Dashboard.
4. Candidate thấy nút chính dẫn về trang chủ.
5. Nút đăng nhập tài khoản khác dẫn đúng tới Account/Login.
6. Trang không phụ thuộc navbar/footer công khai.
7. Desktop và mobile không tràn ngang; nút dùng được bằng bàn phím.
8. Build dự án thành công và trình duyệt không có lỗi console.
