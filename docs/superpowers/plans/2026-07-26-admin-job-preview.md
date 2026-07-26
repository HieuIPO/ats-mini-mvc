# Admin/HR Job Preview Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tạo trang xem trước tin tuyển dụng trong giao diện quản trị và chuyển toàn bộ liên kết nội bộ Admin/HR sang trang này.

**Architecture:** `JobsController.AdminPreview` truy vấn một tin chưa xóa vào `JobDetailsViewModel` và được bảo vệ bằng `AuthorizeRole`. View `Jobs/AdminPreview.cshtml` dùng `_AdminLayout`, còn `Jobs/Details` và các liên kết ứng viên được giữ nguyên.

**Tech Stack:** ASP.NET MVC 5, Entity Framework 6, Razor, PowerShell contract tests, MSBuild.

---

### Task 1: Khóa hợp đồng phân quyền và điều hướng

**Files:**
- Create: `tests/AdminJobPreview.Policy.Tests.ps1`
- Modify: `ATSMiniProject/Controllers/JobsController.cs`
- Modify: `ATSMiniProject/Views/Applications/Review.cshtml`
- Modify: `ATSMiniProject/Views/Jobs/AdminIndex.cshtml`
- Modify: `ATSMiniProject/Views/Jobs/Edit.cshtml`

- [ ] **Step 1: Viết kiểm thử thất bại**

Kiểm tra controller chứa `[AuthorizeRole("Admin", "HR")] public ActionResult AdminPreview(int? id)`, chỉ lấy `!j.IsDeleted`; ba view nội bộ dùng `Url.Action("AdminPreview", "Jobs", ...)`; các view ứng viên vẫn dùng `Details`.

- [ ] **Step 2: Chạy kiểm thử để xác nhận RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminJobPreview.Policy.Tests.ps1`
Expected: FAIL vì action và view xem trước chưa tồn tại.

- [ ] **Step 3: Thêm action tối thiểu và đổi liên kết nội bộ**

Action trả HTTP 400 khi thiếu id, HTTP 404 khi không có tin chưa xóa, ngược lại trả `View(model)`. Đổi đúng các liên kết từ `Details` sang `AdminPreview`; không sửa các view công khai/ứng viên.

- [ ] **Step 4: Chạy lại kiểm thử**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminJobPreview.Policy.Tests.ps1`
Expected: PASS.

### Task 2: Xây view xem trước quản trị

**Files:**
- Create: `ATSMiniProject/Views/Jobs/AdminPreview.cshtml`
- Modify: `ATSMiniProject/Content/css/ats-ui-v2.css`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`
- Test: `tests/AdminJobPreview.Policy.Tests.ps1`

- [ ] **Step 1: Mở rộng kiểm thử và xác nhận RED**

Kiểm tra view dùng `_AdminLayout.cshtml`, có tiêu đề `Xem trước tin tuyển dụng`, render mô tả/yêu cầu bằng `RichTextSanitizer.Sanitize`, có liên kết `AdminIndex` và `Edit`, không chứa `Apply`, `Ứng tuyển` hay `career-apply-button`; kiểm tra file dự án đăng ký view.

- [ ] **Step 2: Tạo view và CSS tối thiểu**

Tạo bố cục hai cột thích ứng màn hình, nhãn trạng thái Đang mở/Đã đóng/Hết hạn, nội dung mô tả/yêu cầu và bảng thông tin vị trí. Đăng ký `Views\Jobs\AdminPreview.cshtml` trong `.csproj`.

- [ ] **Step 3: Chạy kiểm thử để xác nhận GREEN**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminJobPreview.Policy.Tests.ps1`
Expected: PASS.

### Task 3: Xác minh toàn hệ thống

**Files:**
- Verify only

- [ ] **Step 1: Chạy toàn bộ contract tests**

Run: `Get-ChildItem tests -Filter *.Tests.ps1 | ForEach-Object { & powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName }`
Expected: tất cả PASS.

- [ ] **Step 2: Build Razor views**

Run: `& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Rebuild /p:Configuration=Debug /p:MvcBuildViews=true /m`
Expected: 0 lỗi biên dịch.

- [ ] **Step 3: Kiểm tra trình duyệt**

Đăng nhập Admin/HR, mở xem trước từ trang đánh giá hồ sơ và danh sách tin; xác nhận sidebar/topbar còn nguyên, không có CTA ứng tuyển, thao tác quay lại/chỉnh sửa hoạt động, không có lỗi console và không tràn ngang ở 390 px.

- [ ] **Step 4: Kiểm tra phạm vi thay đổi**

Run: `git diff --check`
Expected: không có lỗi khoảng trắng; không thay đổi luồng công khai `Jobs/Details`.
