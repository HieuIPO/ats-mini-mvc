# Thiết kế lại trang Hồ sơ ứng viên Admin/HR

## Mục tiêu

Nâng cấp trang `Applications/Index` thành bảng điều hành tuyển dụng rõ ràng, giàu thông tin và dễ quét hơn, đồng thời hiển thị toàn bộ bộ lọc mà không yêu cầu mở phần “Bộ lọc chi tiết”.

## Phạm vi

- Chỉ thay đổi `Views/Applications/Index.cshtml` và CSS có tiền tố riêng cho trang trong `Content/css/ats-ui-v2.css`.
- Giữ nguyên `ApplicationsController.Index`, `AdminApplicationListViewModel`, truy vấn EF, phân quyền Admin/HR và kích thước 12 hồ sơ mỗi trang.
- Không thay đổi trạng thái hồ sơ, quy tắc hàng đợi, thao tác tạo phỏng vấn hoặc đường dẫn xem xét hồ sơ.
- Không thay đổi layout dùng chung hoặc cấu hình bundle.

## Hướng thẩm mỹ

Sử dụng ngôn ngữ “Recruitment Operations Dashboard”: bề mặt sáng, đường viền tinh tế, màu xanh ATS làm điểm nhấn, phân cấp chữ mạnh và khoảng trắng có chủ đích. Giao diện tránh gradient, bóng đổ nặng và các lớp card lồng nhau.

## Bố cục

1. Phần đầu trang gồm nhãn quản trị, tiêu đề, mô tả ngắn và nút “Tạo lịch phỏng vấn”. Khoảng cách được thu gọn để phần dữ liệu xuất hiện sớm hơn.
2. Sáu hàng đợi hồ sơ tiếp tục là liên kết lọc nhanh. Mỗi mục có nhãn và số lượng rõ ràng; mục đang chọn dùng nền xanh nhạt, chữ xanh đậm và đường chỉ báo phía dưới.
3. Bộ lọc là một khối điều khiển luôn mở. Không còn `<details>` hoặc nhãn “Bộ lọc chi tiết”.
4. Hàng đầu của bộ lọc gồm ô tìm kiếm rộng và danh sách tin tuyển dụng. Hàng thứ hai gồm trạng thái cụ thể, ngày bắt đầu, ngày kết thúc, nút lọc và liên kết đặt lại.
5. Nhãn thật luôn hiển thị phía trên các trường chọn/ngày. Ô tìm kiếm vẫn có nhãn ẩn để giữ bố cục thoáng nhưng có tên truy cập đầy đủ.
6. Bảng giữ năm nhóm thông tin chính. Ô ứng viên bổ sung email và số điện thoại từ view model hiện có; ô vị trí giữ tiêu đề tin và phòng ban; trạng thái, thời gian chờ và hành động tiếp theo được trình bày cô đọng.
7. Thanh công cụ bảng hiển thị tên hàng đợi, tổng số hồ sơ, ghi chú sắp xếp và số trang. Phân trang hiện có tiếp tục giữ mọi tham số lọc.

## Responsive và khả năng truy cập

- Trên màn hình rộng, bộ lọc dùng lưới có tỷ lệ ưu tiên cho tìm kiếm và tin tuyển dụng.
- Dưới 1100 px, bộ lọc chuyển sang hai cột; dưới 680 px chuyển thành một cột và nút thao tác giãn ngang.
- Thanh hàng đợi chuyển thành lưới ba cột rồi hai cột, không làm mất mục lọc.
- Các trường có label liên kết đúng, trạng thái đang chọn có `aria-current`, focus ring rõ và bảng giữ cấu trúc semantic.
- Màu chữ, badge và đường viền bảo đảm độ tương phản trên nền sáng; không dùng màu làm tín hiệu duy nhất.

## Trạng thái và dữ liệu

- Không có bộ lọc: hiển thị hàng đợi đang chọn và toàn bộ điều kiện lọc ở giá trị mặc định.
- Có bộ lọc chi tiết: trường tương ứng giữ nguyên giá trị sau khi gửi; không cần nhãn phụ “Đang áp dụng”.
- Không có kết quả: giữ trạng thái rỗng hiện tại nhưng nằm trong khung bảng mới.
- Có kết quả: tối đa 12 dòng mỗi trang, hành động tùy theo trạng thái hồ sơ như hiện tại.

## Kiểm thử

- Kiểm thử source contract phải thất bại trước khi sửa và xác nhận không còn `<details class="application-filter-details">`.
- Kiểm tra đủ năm điều kiện lọc luôn tồn tại trong form và phân trang vẫn truyền lại keyword, job, status, khoảng ngày và queue.
- Kiểm tra view hiển thị email, điện thoại và giữ các liên kết Review/Create Interview.
- Chạy toàn bộ PowerShell tests, rebuild với `MvcBuildViews=true` và `git diff --check`.
- Kiểm tra trực quan ở desktop và mobile nếu trình duyệt kiểm thử khả dụng.

## Rủi ro và kiểm soát

- Hai file mục tiêu đã có thay đổi chưa commit. Chỉ chỉnh các đoạn thuộc trang hồ sơ, không stage hoặc commit mã nguồn tự động.
- `ats-ui-v2.css` là stylesheet lớn; mọi rule mới phải bắt đầu bằng `.application-ops-` hoặc lớp trang hiện có đủ cụ thể để tránh ảnh hưởng trang khác.
- Dữ liệu email/điện thoại có thể dài; dùng wrap hợp lý thay vì cắt mất nội dung quan trọng.
