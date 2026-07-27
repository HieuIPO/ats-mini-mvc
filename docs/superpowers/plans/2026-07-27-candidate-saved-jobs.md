# Candidate Saved Jobs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép ứng viên lưu/bỏ lưu tin tuyển dụng và xem lại danh sách tin đã lưu sau khi đăng nhập lại.

**Architecture:** Thêm quan hệ nhiều-nhiều có payload thời gian qua entity `SavedJob`, ràng buộc unique `(CandidateUserID, JobID)` tại SQL Server và ánh xạ bằng EF6. `JobsController` xử lý trạng thái của từng tin; `CandidateController` cung cấp trang danh sách riêng. UI dùng form POST + anti-forgery cho ứng viên, còn khách được đưa tới trang đăng nhập với `returnUrl` là trang GET hiện tại.

**Tech Stack:** ASP.NET MVC 5, Entity Framework 6, SQL Server Express, Razor, Bootstrap/CSS hiện có, PowerShell regression tests, MSBuild .NET Framework.

---

## File map

- `database/2026-07-27_AddSavedJobs.sql`: migration idempotent cho database đang chạy.
- `database/ATSMiniDB_StudentPlus_Schema_Seed.sql`: schema đầy đủ cho lần cài mới.
- `ATSMiniProject/Models/SavedJob.cs`: entity lưu quan hệ ứng viên–tin tuyển dụng.
- `ATSMiniProject/Models/Job.cs`, `ATSMiniProject/Models/User.cs`: navigation collections.
- `ATSMiniProject/Models/ATSMiniDBContext.cs`: `DbSet` và mapping/relationship EF6.
- `ATSMiniProject/ViewModels/Jobs/CandidateJobViewModels.cs`: trạng thái `IsSaved` trên card/detail.
- `ATSMiniProject/ViewModels/Candidate/SavedJobViewModels.cs`: dữ liệu/phân trang trang tin đã lưu.
- `ATSMiniProject/Controllers/JobsController.cs`: truy vấn trạng thái, POST save/unsave và local redirect.
- `ATSMiniProject/Controllers/CandidateController.cs`: GET danh sách tin đã lưu.
- `ATSMiniProject/Views/Jobs/Index.cshtml`, `Details.cshtml`: nút bookmark.
- `ATSMiniProject/Views/Candidate/SavedJobs.cshtml`: trang xem lại.
- `ATSMiniProject/Views/Shared/_Navbar.cshtml`: mục menu ứng viên.
- `ATSMiniProject/Content/css/site.css`: trình bày bookmark và danh sách đã lưu.
- `ATSMiniProject/ATSMiniProject.csproj`: đăng ký source/view mới.
- `tests/CandidateSavedJobs.Policy.Tests.ps1`, `tests/CandidateSavedJobs.UI.Tests.ps1`: regression tests.

### Task 1: Persistence schema and EF mapping

**Files:**
- Create: `tests/CandidateSavedJobs.Policy.Tests.ps1`
- Create: `database/2026-07-27_AddSavedJobs.sql`
- Create: `ATSMiniProject/Models/SavedJob.cs`
- Modify: `database/ATSMiniDB_StudentPlus_Schema_Seed.sql`
- Modify: `ATSMiniProject/Models/Job.cs`
- Modify: `ATSMiniProject/Models/User.cs`
- Modify: `ATSMiniProject/Models/ATSMiniDBContext.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`

- [ ] **Step 1: Write the failing persistence policy test**

Create a PowerShell test that asserts the migration contains the table, two foreign keys and unique index, and that the project includes/mapping exposes the entity:

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$sql = Get-Content -Raw (Join-Path $root 'database/2026-07-27_AddSavedJobs.sql')
$context = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Models/ATSMiniDBContext.cs')
$project = Get-Content -Raw (Join-Path $root 'ATSMiniProject/ATSMiniProject.csproj')

foreach ($required in @('CREATE TABLE dbo.SavedJobs', 'CandidateUserID INT NOT NULL',
    'JobID INT NOT NULL', 'SavedAt DATETIME NOT NULL',
    'UX_SavedJobs_Candidate_Job', 'FOREIGN KEY (CandidateUserID)', 'FOREIGN KEY (JobID)')) {
    if (-not $sql.Contains($required)) { throw "Missing persistence rule: $required" }
}
if ($context -notmatch 'DbSet<SavedJob>\s+SavedJobs') { throw 'SavedJobs DbSet missing.' }
if ($project -notmatch 'Compile Include="Models\\SavedJob.cs"') { throw 'SavedJob.cs is not compiled.' }
'Candidate saved jobs persistence policy tests passed.'
```

- [ ] **Step 2: Run the test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.Policy.Tests.ps1`

Expected: FAIL because the migration/entity/mapping do not exist.

- [ ] **Step 3: Add the idempotent SQL migration**

Implement this shape in both migration and full seed schema:

```sql
IF OBJECT_ID(N'dbo.SavedJobs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SavedJobs (
        SavedJobID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CandidateUserID INT NOT NULL,
        JobID INT NOT NULL,
        SavedAt DATETIME NOT NULL CONSTRAINT DF_SavedJobs_SavedAt DEFAULT GETDATE(),
        CONSTRAINT FK_SavedJobs_Candidate FOREIGN KEY (CandidateUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_SavedJobs_Job FOREIGN KEY (JobID) REFERENCES dbo.Jobs(JobID) ON DELETE CASCADE
    );
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SavedJobs_Candidate_Job' AND object_id = OBJECT_ID(N'dbo.SavedJobs'))
    CREATE UNIQUE INDEX UX_SavedJobs_Candidate_Job ON dbo.SavedJobs(CandidateUserID, JobID);
GO
```

- [ ] **Step 4: Add the EF entity and mappings**

Use the exact entity contract:

```csharp
public partial class SavedJob
{
    public int SavedJobID { get; set; }
    public int CandidateUserID { get; set; }
    public int JobID { get; set; }
    public System.DateTime SavedAt { get; set; }
    public virtual User CandidateUser { get; set; }
    public virtual Job Job { get; set; }
}
```

Add `DbSet<SavedJob> SavedJobs`, key/table mapping, a required non-cascade relation to `User`, a required cascade relation to `Job`, initialize `SavedJobs` collections in `User` and `Job`, then register `Models\SavedJob.cs` in the project file.

- [ ] **Step 5: Run persistence test and build GREEN**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.Policy.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Build /p:Configuration=Debug /m /v:minimal
```

Expected: test prints its pass message and MSBuild exits `0`.

- [ ] **Step 6: Apply migration to the local database and verify constraints**

Execute the migration against `ATSMiniDB_StudentPlus`, then query `sys.tables`, `sys.foreign_keys` and `sys.indexes`; expect one `SavedJobs` table, two foreign keys and `UX_SavedJobs_Candidate_Job`.

- [ ] **Step 7: Commit the persistence slice**

```bash
git add tests/CandidateSavedJobs.Policy.Tests.ps1 database/2026-07-27_AddSavedJobs.sql database/ATSMiniDB_StudentPlus_Schema_Seed.sql ATSMiniProject/Models/SavedJob.cs ATSMiniProject/Models/Job.cs ATSMiniProject/Models/User.cs ATSMiniProject/Models/ATSMiniDBContext.cs ATSMiniProject/ATSMiniProject.csproj
git commit -m "feat: add candidate saved jobs persistence"
```

### Task 2: Save/unsave actions and query state

**Files:**
- Modify: `tests/CandidateSavedJobs.Policy.Tests.ps1`
- Modify: `ATSMiniProject/ViewModels/Jobs/CandidateJobViewModels.cs`
- Modify: `ATSMiniProject/Controllers/JobsController.cs`
- Modify: `ATSMiniProject/Controllers/CandidateController.cs`

- [ ] **Step 1: Extend the failing test for controller policy**

Assert both actions use Candidate authorization, POST and anti-forgery; the entity uses session user ID rather than accepting it from the request; `returnUrl` is guarded by `Url.IsLocalUrl`; card/detail expose `IsSaved`.

```powershell
$controller = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Controllers/JobsController.cs')
$viewModels = Get-Content -Raw (Join-Path $root 'ATSMiniProject/ViewModels/Jobs/CandidateJobViewModels.cs')
foreach ($signature in @('ActionResult SaveJob(int jobId, string returnUrl)', 'ActionResult UnsaveJob(int jobId, string returnUrl)')) {
    if (-not $controller.Contains($signature)) { throw "Missing action: $signature" }
}
if (($controller | Select-String -Pattern '\[ValidateAntiForgeryToken\]' -AllMatches).Matches.Count -lt 2) { throw 'Anti-forgery policy missing.' }
if (-not $controller.Contains('Url.IsLocalUrl(returnUrl)')) { throw 'Local redirect guard missing.' }
if (-not $viewModels.Contains('public bool IsSaved { get; set; }')) { throw 'IsSaved state missing.' }
```

- [ ] **Step 2: Run and verify RED**

Run the policy test. Expected: FAIL on missing actions/`IsSaved`.

- [ ] **Step 3: Implement minimal save and unsave actions**

Use this behavior:

```csharp
[AuthorizeRole("Candidate")]
[HttpPost]
[ValidateAntiForgeryToken]
public ActionResult SaveJob(int jobId, string returnUrl)
{
    var userId = GetCurrentUserId();
    if (!db.Jobs.Any(j => j.JobID == jobId && !j.IsDeleted)) return HttpNotFound();
    if (!db.SavedJobs.Any(s => s.CandidateUserID == userId && s.JobID == jobId))
    {
        db.SavedJobs.Add(new SavedJob { CandidateUserID = userId, JobID = jobId, SavedAt = DateTime.Now });
        db.SaveChanges();
    }
    return RedirectAfterSavedJobAction(jobId, returnUrl);
}
```

`UnsaveJob` loads only `(CandidateUserID == userId && JobID == jobId)`, removes it when present and otherwise still redirects successfully. `RedirectAfterSavedJobAction` returns `Redirect(returnUrl)` only for `Url.IsLocalUrl(returnUrl)`; fallback is `RedirectToAction("Details", new { id = jobId })`.

- [ ] **Step 4: Populate `IsSaved` for list and detail**

Add `IsSaved` to `JobCardViewModel`. For a Candidate session, project `j.SavedJobs.Any(s => s.CandidateUserID == candidateUserId)` in public list, details and dashboard recommended jobs; guests and back-office accounts get `false`.

- [ ] **Step 5: Run policy tests and build GREEN**

Run the policy test plus MSBuild; expect both exit `0`.

- [ ] **Step 6: Commit the behavior slice**

```bash
git add tests/CandidateSavedJobs.Policy.Tests.ps1 ATSMiniProject/ViewModels/Jobs/CandidateJobViewModels.cs ATSMiniProject/Controllers/JobsController.cs ATSMiniProject/Controllers/CandidateController.cs
git commit -m "feat: add save and unsave job actions"
```

### Task 3: Candidate saved-jobs page

**Files:**
- Create: `ATSMiniProject/ViewModels/Candidate/SavedJobViewModels.cs`
- Create: `ATSMiniProject/Views/Candidate/SavedJobs.cshtml`
- Modify: `ATSMiniProject/Controllers/CandidateController.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`
- Modify: `tests/CandidateSavedJobs.Policy.Tests.ps1`

- [ ] **Step 1: Add a failing page policy test**

Assert the controller contains `[HttpGet] public ActionResult SavedJobs(int page = 1)`, filters `CandidateUserID == userId && !s.Job.IsDeleted`, orders by `SavedAt` descending, calls `Pagination.Calculate`, and the project registers both new files.

- [ ] **Step 2: Run and verify RED**

Run the policy test. Expected: FAIL because page action/view model/view do not exist.

- [ ] **Step 3: Implement the page view models**

```csharp
public sealed class SavedJobListViewModel
{
    public SavedJobListViewModel() { Jobs = new List<SavedJobItemViewModel>(); }
    public int Page { get; set; }
    public int TotalPages { get; set; }
    public int TotalItems { get; set; }
    public IList<SavedJobItemViewModel> Jobs { get; set; }
}

public sealed class SavedJobItemViewModel
{
    public int JobId { get; set; }
    public string Title { get; set; }
    public string DepartmentName { get; set; }
    public string Location { get; set; }
    public string JobType { get; set; }
    public string SalaryRange { get; set; }
    public DateTime SavedAt { get; set; }
    public DateTime? Deadline { get; set; }
    public bool IsActive { get; set; }
    public bool IsExpired { get; set; }
}
```

- [ ] **Step 4: Implement paginated query and view**

Use page size `9`, newest saved first, exclude soft-deleted jobs, and project status without loading full entities. The Razor view renders heading/count, responsive job cards, POST `UnsaveJob` form with anti-forgery, open/closed/expired badge, empty state linking to `Jobs/Index`, and pagination preserving no unnecessary query parameters.

- [ ] **Step 5: Run page policy tests and build GREEN**

Run the policy test and MSBuild; expect both exit `0`.

- [ ] **Step 6: Commit the page slice**

```bash
git add ATSMiniProject/ViewModels/Candidate/SavedJobViewModels.cs ATSMiniProject/Views/Candidate/SavedJobs.cshtml ATSMiniProject/Controllers/CandidateController.cs ATSMiniProject/ATSMiniProject.csproj tests/CandidateSavedJobs.Policy.Tests.ps1
git commit -m "feat: add candidate saved jobs page"
```

### Task 4: Bookmark UI and candidate navigation

**Files:**
- Create: `tests/CandidateSavedJobs.UI.Tests.ps1`
- Modify: `ATSMiniProject/Views/Jobs/Index.cshtml`
- Modify: `ATSMiniProject/Views/Jobs/Details.cshtml`
- Modify: `ATSMiniProject/Views/Shared/_Navbar.cshtml`
- Modify: `ATSMiniProject/Content/css/site.css`

- [ ] **Step 1: Write failing UI tests**

Assert list/detail render `SaveJob` and `UnsaveJob`, each candidate POST form includes `AntiForgeryToken`, guests receive a login URL with current local GET URL, and candidate menu contains `Url.Action("SavedJobs", "Candidate")` plus label `Tin đã lưu`.

- [ ] **Step 2: Run and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.UI.Tests.ps1`

Expected: FAIL because bookmark forms and menu item are absent.

- [ ] **Step 3: Add progressive-enhancement bookmark controls**

For Candidate sessions render:

```cshtml
@using (Html.BeginForm(Model.IsSaved ? "UnsaveJob" : "SaveJob", "Jobs", FormMethod.Post, new { @class = "job-save-form" }))
{
    @Html.AntiForgeryToken()
    @Html.Hidden("jobId", Model.JobId)
    @Html.Hidden("returnUrl", Request.RawUrl)
    <button class="job-save-button @(Model.IsSaved ? "is-saved" : null)" type="submit">
        <span aria-hidden="true">☆</span>
        @(Model.IsSaved ? "Bỏ lưu" : "Lưu tin")
    </button>
}
```

For guests render a link to `Account/Login` with `returnUrl = Request.RawUrl`. Do not render controls for Admin/HR. Use the card item’s `job.JobId`/`job.IsSaved` in the list equivalent.

- [ ] **Step 4: Add candidate menu entry and scoped CSS**

Insert `Tin đã lưu` in the candidate avatar popover, mark it active for `Candidate/SavedJobs`, and style `.job-save-button`, `.is-saved`, `.candidate-saved-jobs-*` with the existing orange/neutral design tokens, visible focus state and responsive card layout. Do not alter global button defaults.

- [ ] **Step 5: Run UI tests, related navbar/job tests and build GREEN**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.UI.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateNavbar.Menu.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\PublicJobsTitleWrapping.UI.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Build /p:Configuration=Debug /m /v:minimal
```

Expected: every test and build exits `0`.

- [ ] **Step 6: Commit the UI slice**

```bash
git add tests/CandidateSavedJobs.UI.Tests.ps1 ATSMiniProject/Views/Jobs/Index.cshtml ATSMiniProject/Views/Jobs/Details.cshtml ATSMiniProject/Views/Shared/_Navbar.cshtml ATSMiniProject/Content/css/site.css
git commit -m "feat: add candidate saved job controls"
```

### Task 5: End-to-end verification and cleanup

**Files:**
- Modify only files from Tasks 1–4 if verification exposes a defect.

- [ ] **Step 1: Verify guest behavior**

Open a public job list/detail while logged out. Confirm the bookmark control opens `Account/Login` with a local `returnUrl`, successful Candidate login returns to the same GET page, and no save occurs before the authenticated POST.

- [ ] **Step 2: Verify authenticated persistence**

As Candidate, save a job from the list, confirm detail shows `Bỏ lưu`, confirm it appears first on `/Candidate/SavedJobs`, log out/in and confirm it remains, then remove it and confirm it disappears. Repeat save once to confirm the unique constraint/idempotent action produces no HTTP 500.

- [ ] **Step 3: Verify authorization and stale jobs**

Confirm Admin/HR see no bookmark controls, Candidate cannot manipulate another Candidate’s row, soft-deleted jobs do not appear, and closed/expired saved jobs display the correct badge without bypassing the existing job-details access rule.

- [ ] **Step 4: Run the final verification gate**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.Policy.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateSavedJobs.UI.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateNavbar.Menu.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\CandidateDashboard.UI.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\JobRichText.Policy.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Build /p:Configuration=Debug /m /v:minimal
git diff --check
```

Expected: all tests and MSBuild exit `0`; `git diff --check` has no whitespace errors (line-ending warnings are informational).

- [ ] **Step 5: Commit verification-only corrections if any**

If verification required a code correction, stage only the saved-jobs files and commit with `fix: harden candidate saved jobs`; otherwise do not create an empty commit.
