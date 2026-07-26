# Admin/HR Pagination Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add deterministic server-side pagination to the four growing Admin/HR lists while preserving filters, authorization, and existing CRUD behavior.

**Architecture:** Introduce one dependency-free pagination calculation helper, then let each controller count its filtered query, clamp the requested page, and apply `Skip`/`Take` after deterministic ordering. Each view receives explicit page metadata through its feature view model and renders the established `.admin-pagination` UI while retaining its own route values.

**Tech Stack:** ASP.NET MVC 5, C#/.NET Framework, Entity Framework 6, Razor, PowerShell regression tests, MSBuild.

---

## File map

- Create `ATSMiniProject/Helpers/Pagination.cs`: pure page-boundary calculation shared by four controllers.
- Create `ATSMiniProject/ViewModels/Jobs/AdminCatalogListViewModels.cs`: list contracts for departments and job positions.
- Create `tests/AdminPagination.Policy.Tests.ps1`: executable page-math tests plus source-level integration guards for controllers and views.
- Modify `ATSMiniProject/ATSMiniProject.csproj`: compile the two new C# files.
- Modify `ATSMiniProject/Controllers/JobsController.cs`: paginate `AdminIndex` without changing public job pagination.
- Modify `ATSMiniProject/ViewModels/Jobs/JobFilterViewModel.cs`: expose job page metadata.
- Modify `ATSMiniProject/Views/Jobs/AdminIndex.cshtml`: show range and filter-preserving navigation.
- Modify `ATSMiniProject/Controllers/DepartmentsController.cs` and `ATSMiniProject/Controllers/JobPositionsController.cs`: paginate catalog queries.
- Modify `ATSMiniProject/Views/Departments/Index.cshtml` and `ATSMiniProject/Views/JobPositions/Index.cshtml`: consume catalog view models and preserve keyword navigation.
- Modify `ATSMiniProject/Controllers/NotificationsController.cs`: paginate notifications scoped to the current recipient.
- Modify `ATSMiniProject/ViewModels/Notifications/NotificationViewModels.cs`: expose notification page metadata.
- Modify `ATSMiniProject/Views/Notifications/Index.cshtml`: show range and navigation.

### Task 1: Tested pagination boundary helper

**Files:**
- Create: `tests/AdminPagination.Policy.Tests.ps1`
- Create: `ATSMiniProject/Helpers/Pagination.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`

- [ ] **Step 1: Write the failing page-math test**

Create the test with these executable cases before the helper exists:

```powershell
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$helperPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\Pagination.cs'

if (-not (Test-Path -LiteralPath $helperPath)) {
    throw "Missing pagination helper: $helperPath"
}

$source = Get-Content -Raw -LiteralPath $helperPath
Add-Type -TypeDefinition $source -Language CSharp

$cases = @(
    @{ Page = -2; Total = 0; Size = 12; ExpectedPage = 1; ExpectedPages = 1; ExpectedOffset = 0; ExpectedFirst = 0; ExpectedLast = 0 },
    @{ Page = 1; Total = 12; Size = 12; ExpectedPage = 1; ExpectedPages = 1; ExpectedOffset = 0; ExpectedFirst = 1; ExpectedLast = 12 },
    @{ Page = 2; Total = 13; Size = 12; ExpectedPage = 2; ExpectedPages = 2; ExpectedOffset = 12; ExpectedFirst = 13; ExpectedLast = 13 },
    @{ Page = 99; Total = 25; Size = 12; ExpectedPage = 3; ExpectedPages = 3; ExpectedOffset = 24; ExpectedFirst = 25; ExpectedLast = 25 }
)

foreach ($case in $cases) {
    $result = [ATSMiniProject.Helpers.Pagination]::Calculate($case.Page, $case.Total, $case.Size)
    foreach ($property in @('Page', 'TotalPages', 'Offset', 'FirstItem', 'LastItem')) {
        $expectedName = if ($property -eq 'Page') { 'ExpectedPage' } elseif ($property -eq 'TotalPages') { 'ExpectedPages' } elseif ($property -eq 'Offset') { 'ExpectedOffset' } elseif ($property -eq 'FirstItem') { 'ExpectedFirst' } else { 'ExpectedLast' }
        if ($result.$property -ne $case.$expectedName) {
            throw "Pagination case failed for $property: expected $($case.$expectedName), got $($result.$property)."
        }
    }
}

Write-Output 'Pagination calculation tests passed: 4/4.'
```

- [ ] **Step 2: Run the test and confirm the expected failure**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminPagination.Policy.Tests.ps1`

Expected: non-zero exit with `Missing pagination helper`.

- [ ] **Step 3: Implement the minimal dependency-free helper**

Create `Pagination.cs`:

```csharp
using System;

namespace ATSMiniProject.Helpers
{
    public sealed class PaginationResult
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalItems { get; set; }
        public int TotalPages { get; set; }
        public int Offset { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
    }

    public static class Pagination
    {
        public static PaginationResult Calculate(int requestedPage, int totalItems, int pageSize)
        {
            if (totalItems < 0) throw new ArgumentOutOfRangeException("totalItems");
            if (pageSize <= 0) throw new ArgumentOutOfRangeException("pageSize");

            var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)pageSize));
            var page = Math.Max(1, Math.Min(requestedPage, totalPages));
            var offset = (page - 1) * pageSize;

            return new PaginationResult
            {
                Page = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                TotalPages = totalPages,
                Offset = offset,
                FirstItem = totalItems == 0 ? 0 : offset + 1,
                LastItem = Math.Min(offset + pageSize, totalItems)
            };
        }
    }
}
```

Add `<Compile Include="Helpers\Pagination.cs" />` beside the other helper entries in the project file.

- [ ] **Step 4: Run the helper test and build**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminPagination.Policy.Tests.ps1`

Expected: `Pagination calculation tests passed: 4/4.`

Run: `msbuild ATSMiniProject.sln /t:Build /p:Configuration=Debug /m`

Expected: exit code 0 with 0 compilation errors.

- [ ] **Step 5: Commit the helper slice**

```powershell
git add -- tests/AdminPagination.Policy.Tests.ps1 ATSMiniProject/Helpers/Pagination.cs ATSMiniProject/ATSMiniProject.csproj
git commit -m "test: define admin pagination boundaries"
```

### Task 2: Admin/HR job pagination

**Files:**
- Modify: `tests/AdminPagination.Policy.Tests.ps1`
- Modify: `ATSMiniProject/Controllers/JobsController.cs`
- Modify: `ATSMiniProject/ViewModels/Jobs/JobFilterViewModel.cs`
- Modify: `ATSMiniProject/Views/Jobs/AdminIndex.cshtml`

- [ ] **Step 1: Add failing job integration guards**

Append source assertions that require:

```powershell
$jobsController = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Controllers\JobsController.cs')
$jobsModel = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Jobs\JobFilterViewModel.cs')
$jobsView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Jobs\AdminIndex.cshtml')

foreach ($fragment in @('private const int AdminPageSize = 12;', 'int page = 1', 'Pagination.Calculate(page, filteredJobs, AdminPageSize)', '.Skip(pagination.Offset)', '.Take(pagination.PageSize)', '.ThenBy(j => j.JobID)')) {
    if (-not $jobsController.Contains($fragment)) { throw "Jobs pagination is missing: $fragment" }
}
foreach ($fragment in @('public int Page { get; set; }', 'public int TotalPages { get; set; }', 'public int FirstItem { get; set; }', 'public int LastItem { get; set; }')) {
    if (-not $jobsModel.Contains($fragment)) { throw "JobFilterViewModel pagination is missing: $fragment" }
}
foreach ($fragment in @('aria-label="Phân trang tin tuyển dụng"', 'page = pageNumber', 'keyword = Model.Keyword', 'sort = Model.Sort', 'aria-current')) {
    if (-not $jobsView.Contains($fragment)) { throw "Jobs view pagination is missing: $fragment" }
}
```

- [ ] **Step 2: Run the test and confirm it fails on the first missing job fragment**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminPagination.Policy.Tests.ps1`

Expected: non-zero exit naming `private const int AdminPageSize = 12;`.

- [ ] **Step 3: Add job page metadata and query pagination**

Add `AdminPageSize = 12`, accept `int page = 1` in `AdminIndex`, and pass it to `BuildJobFilterModel`. Extend that private method with `int page`, then calculate after `filteredJobs = query.Count()`:

```csharp
var pagination = Pagination.Calculate(page, filteredJobs, AdminPageSize);
```

Add `ThenBy(j => j.JobID)` to every sort branch and apply the page before projection:

```csharp
Jobs = query
    .Skip(pagination.Offset)
    .Take(pagination.PageSize)
    .Select(j => new AdminJobListItemViewModel
    {
        JobID = j.JobID,
        Title = j.Title,
        DepartmentName = j.Department == null ? null : j.Department.DepartmentName,
        PositionName = j.JobPosition == null ? null : j.JobPosition.PositionName,
        Location = j.Location,
        JobType = j.JobType,
        Deadline = j.Deadline,
        IsActive = j.IsActive,
        ApplicationCount = j.Applications.Count(a => !a.IsDeleted),
        CreatedAt = j.CreatedAt
    })
    .ToList(),
Page = pagination.Page,
TotalPages = pagination.TotalPages,
FirstItem = pagination.FirstItem,
LastItem = pagination.LastItem,
```

Add these exact properties to `JobFilterViewModel`:

```csharp
public int Page { get; set; }
public int TotalPages { get; set; }
public int FirstItem { get; set; }
public int LastItem { get; set; }
```

- [ ] **Step 4: Render the job result range and filter-preserving navigation**

Change the toolbar text to use `FirstItem`, `LastItem`, and `FilteredJobs`. After the table/empty state, render navigation only when `TotalPages > 1`. The numbered link route must include all current filters:

```cshtml
<nav class="admin-pagination" aria-label="Phân trang tin tuyển dụng">
    @for (var pageNumber = 1; pageNumber <= Model.TotalPages; pageNumber++)
    {
        <a class="@(pageNumber == Model.Page ? "active" : null)"
           aria-current="@(pageNumber == Model.Page ? "page" : null)"
           href="@Url.Action("AdminIndex", "Jobs", new { keyword = Model.Keyword, departmentId = Model.DepartmentID, jobPositionId = Model.JobPositionID, location = Model.Location, jobType = Model.JobType, status = Model.Status, sort = Model.Sort, page = pageNumber })">@pageNumber</a>
    }
</nav>
```

Place these links immediately before and after the numbered loop; do not output an anchor when the target does not exist:

```cshtml
@if (Model.Page > 1)
{
    <a href="@Url.Action("AdminIndex", "Jobs", new { keyword = Model.Keyword, departmentId = Model.DepartmentID, jobPositionId = Model.JobPositionID, location = Model.Location, jobType = Model.JobType, status = Model.Status, sort = Model.Sort, page = Model.Page - 1 })">Trước</a>
}
@if (Model.Page < Model.TotalPages)
{
    <a href="@Url.Action("AdminIndex", "Jobs", new { keyword = Model.Keyword, departmentId = Model.DepartmentID, jobPositionId = Model.JobPositionID, location = Model.Location, jobType = Model.JobType, status = Model.Status, sort = Model.Sort, page = Model.Page + 1 })">Sau</a>
}
```

- [ ] **Step 5: Run the regression test and build**

Run the pagination test, then the full build. Expected: test success and build exit code 0.

- [ ] **Step 6: Commit the job slice**

```powershell
git add -- tests/AdminPagination.Policy.Tests.ps1 ATSMiniProject/Controllers/JobsController.cs ATSMiniProject/ViewModels/Jobs/JobFilterViewModel.cs ATSMiniProject/Views/Jobs/AdminIndex.cshtml
git commit -m "feat: paginate admin job listings"
```

### Task 3: Department and job-position pagination

**Files:**
- Create: `ATSMiniProject/ViewModels/Jobs/AdminCatalogListViewModels.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`
- Modify: `tests/AdminPagination.Policy.Tests.ps1`
- Modify: `ATSMiniProject/Controllers/DepartmentsController.cs`
- Modify: `ATSMiniProject/Controllers/JobPositionsController.cs`
- Modify: `ATSMiniProject/Views/Departments/Index.cshtml`
- Modify: `ATSMiniProject/Views/JobPositions/Index.cshtml`

- [ ] **Step 1: Add failing catalog integration guards**

Append these source checks:

```powershell
$catalogCases = @(
    @{ Name = 'Departments'; Controller = 'DepartmentsController.cs'; View = 'Departments\Index.cshtml'; Model = '@model ATSMiniProject.ViewModels.Jobs.DepartmentListViewModel' },
    @{ Name = 'JobPositions'; Controller = 'JobPositionsController.cs'; View = 'JobPositions\Index.cshtml'; Model = '@model ATSMiniProject.ViewModels.Jobs.JobPositionListViewModel' }
)
foreach ($case in $catalogCases) {
    $controller = Get-Content -Raw (Join-Path $projectRoot "ATSMiniProject\Controllers\$($case.Controller)")
    $view = Get-Content -Raw (Join-Path $projectRoot "ATSMiniProject\Views\$($case.View)")
    foreach ($fragment in @('private const int PageSize = 12;', 'int page = 1', 'Pagination.Calculate(page, totalItems, PageSize)', '.Skip(pagination.Offset)', '.Take(pagination.PageSize)')) {
        if (-not $controller.Contains($fragment)) { throw "$($case.Name) pagination is missing: $fragment" }
    }
    foreach ($fragment in @($case.Model, 'Model.Items', 'Model.TotalItems', 'aria-current', 'keyword = Model.Keyword', 'page = pageNumber')) {
        if (-not $view.Contains($fragment)) { throw "$($case.Name) view pagination is missing: $fragment" }
    }
}
```

- [ ] **Step 2: Run the test and confirm it fails on the missing catalog contract**

Run the pagination test. Expected: non-zero exit identifying the first missing department fragment.

- [ ] **Step 3: Add focused catalog list contracts**

Create two view models with initialized item lists:

```csharp
using System.Collections.Generic;
using ATSMiniProject.Models;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class DepartmentListViewModel
    {
        public DepartmentListViewModel() { Items = new List<Department>(); }
        public string Keyword { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
        public IList<Department> Items { get; set; }
    }

    public class JobPositionListViewModel
    {
        public JobPositionListViewModel() { Items = new List<JobPosition>(); }
        public string Keyword { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
        public IList<JobPosition> Items { get; set; }
    }
}
```

Add its compile entry to the project file.

- [ ] **Step 4: Paginate both catalog queries**

For each action, accept `int page = 1`, count after keyword filtering, calculate the page, order by active state, name, then ID, and apply `Skip`/`Take`. Return its dedicated list view model. Example department query:

```csharp
var totalItems = query.Count();
var pagination = Pagination.Calculate(page, totalItems, PageSize);
var items = query
    .OrderByDescending(d => d.IsActive)
    .ThenBy(d => d.DepartmentName)
    .ThenBy(d => d.DepartmentID)
    .Skip(pagination.Offset)
    .Take(pagination.PageSize)
    .ToList();
```

Return the department model with this mapping:

```csharp
return View(new DepartmentListViewModel
{
    Keyword = keyword,
    Page = pagination.Page,
    TotalPages = pagination.TotalPages,
    TotalItems = pagination.TotalItems,
    FirstItem = pagination.FirstItem,
    LastItem = pagination.LastItem,
    Items = items
});
```

Return `JobPositionListViewModel` with the same pagination properties and `Items = items`; its query must use `.ThenBy(p => p.PositionName).ThenBy(p => p.JobPositionID)`.

- [ ] **Step 5: Update both catalog views**

Replace the entity enumerable model declaration with the dedicated view model, use `Model.Items` for rows, and show `Model.TotalItems` rather than the current page count. Render a range and navigation:

```cshtml
<span>Đang xem @Model.FirstItem–@Model.LastItem trên tổng @Model.TotalItems</span>
```

```cshtml
<a class="@(pageNumber == Model.Page ? "active" : null)"
   aria-current="@(pageNumber == Model.Page ? "page" : null)"
   href="@Url.Action("Index", new { keyword = Model.Keyword, page = pageNumber })">@pageNumber</a>
```

Wrap the numbered links with these valid-only controls in each catalog view:

```cshtml
@if (Model.Page > 1)
{
    <a href="@Url.Action("Index", new { keyword = Model.Keyword, page = Model.Page - 1 })">Trước</a>
}
@if (Model.Page < Model.TotalPages)
{
    <a href="@Url.Action("Index", new { keyword = Model.Keyword, page = Model.Page + 1 })">Sau</a>
}
```

Keep all existing create, edit, delete confirmation, empty-state, and anti-forgery markup unchanged.

- [ ] **Step 6: Run the regression test and build**

Expected: pagination test success and build exit code 0.

- [ ] **Step 7: Commit the catalog slice**

```powershell
git add -- tests/AdminPagination.Policy.Tests.ps1 ATSMiniProject/ATSMiniProject.csproj ATSMiniProject/ViewModels/Jobs/AdminCatalogListViewModels.cs ATSMiniProject/Controllers/DepartmentsController.cs ATSMiniProject/Controllers/JobPositionsController.cs ATSMiniProject/Views/Departments/Index.cshtml ATSMiniProject/Views/JobPositions/Index.cshtml
git commit -m "feat: paginate recruitment catalogs"
```

### Task 4: Recipient-scoped notification pagination

**Files:**
- Modify: `tests/AdminPagination.Policy.Tests.ps1`
- Modify: `ATSMiniProject/Controllers/NotificationsController.cs`
- Modify: `ATSMiniProject/ViewModels/Notifications/NotificationViewModels.cs`
- Modify: `ATSMiniProject/Views/Notifications/Index.cshtml`

- [ ] **Step 1: Add failing notification integration guards**

Append these exact source checks:

```powershell
$notificationController = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Controllers\NotificationsController.cs')
$notificationModel = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Notifications\NotificationViewModels.cs')
$notificationView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\Index.cshtml')
foreach ($fragment in @('private const int PageSize = 12;', 'Index(int page = 1)', 'Pagination.Calculate(page, totalItems, PageSize)', '.ThenByDescending(n => n.NotificationID)', '.Skip(pagination.Offset)', '.Take(pagination.PageSize)')) {
    if (-not $notificationController.Contains($fragment)) { throw "Notification pagination is missing: $fragment" }
}
foreach ($fragment in @('public int Page { get; set; }', 'public int TotalPages { get; set; }', 'public int TotalItems { get; set; }', 'public int FirstItem { get; set; }', 'public int LastItem { get; set; }')) {
    if (-not $notificationModel.Contains($fragment)) { throw "Notification model pagination is missing: $fragment" }
}
foreach ($fragment in @('aria-label="Phân trang thông báo"', 'aria-current', 'page = pageNumber')) {
    if (-not $notificationView.Contains($fragment)) { throw "Notification view pagination is missing: $fragment" }
}
```

- [ ] **Step 2: Run the test and confirm it fails on the missing notification page size**

Run the pagination test. Expected: non-zero exit naming the missing notification fragment.

- [ ] **Step 3: Paginate only the current recipient's query**

Keep the existing recipient predicate as the base query. Count unread and total from that scoped query, calculate the page, then load only one page:

```csharp
var totalItems = query.Count();
var pagination = Pagination.Calculate(page, totalItems, PageSize);
Items = query
    .OrderByDescending(n => n.CreatedAt)
    .ThenByDescending(n => n.NotificationID)
    .Skip(pagination.Offset)
    .Take(pagination.PageSize)
    .Select(n => new NotificationItemViewModel
    {
        NotificationId = n.NotificationID,
        ApplicationId = n.ApplicationID,
        Title = n.Title,
        Message = n.Message,
        CreatedAt = n.CreatedAt,
        IsRead = n.ReadAt != null
    })
    .ToList()
```

Map `Page`, `TotalPages`, `TotalItems`, `FirstItem`, and `LastItem` onto `NotificationIndexViewModel`. Do not modify `TopbarBell`, `Open`, or `MarkAllRead`.

- [ ] **Step 4: Render notification range and navigation**

Display `Đang xem X–Y trên tổng Z thông báo` above the list. Render page numbers plus valid previous/next links using `Url.Action("Index", "Notifications", new { page = pageNumber })`; set `aria-current="page"` on the active number.

- [ ] **Step 5: Run notification policy, pagination regression, and build**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/NotificationFeature.Policy.Tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminPagination.Policy.Tests.ps1
msbuild ATSMiniProject.sln /t:Build /p:Configuration=Debug /m
```

Expected: both scripts succeed and build exits 0.

- [ ] **Step 6: Commit the notification slice**

```powershell
git add -- tests/AdminPagination.Policy.Tests.ps1 ATSMiniProject/Controllers/NotificationsController.cs ATSMiniProject/ViewModels/Notifications/NotificationViewModels.cs ATSMiniProject/Views/Notifications/Index.cshtml
git commit -m "feat: paginate admin notifications"
```

### Task 5: Full regression and browser verification

**Files:**
- Modify only if a directly observed pagination defect requires a scoped correction.

- [ ] **Step 1: Run every repository PowerShell test**

```powershell
Get-ChildItem tests -Filter '*.Tests.ps1' | Sort-Object Name | ForEach-Object {
    & powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "Test failed: $($_.Name)" }
}
```

Expected: every script exits 0.

- [ ] **Step 2: Run a fresh full build with Razor compilation enabled**

Run: `msbuild ATSMiniProject.sln /t:Rebuild /p:Configuration=Debug /p:MvcBuildViews=true /m`

Expected: exit code 0 and 0 errors. Record environmental warnings separately; do not report them as feature failures unless they affect output.

- [ ] **Step 3: Review only task-scoped diffs**

Run `git diff --check` and `git status --short`. Inspect each changed hunk in the files listed in this plan. Confirm no unrelated pre-existing modification is staged or rewritten.

- [ ] **Step 4: Verify Admin/HR pages in a real browser**

With an Admin or HR session and enough seed data to produce at least two pages, verify:

- `Jobs/AdminIndex`: page 2 contains different records; keyword, status, all advanced filters, and sort remain in the URL and UI.
- `Departments/Index` and `JobPositions/Index`: keyword persists, range is global rather than page-local, and edit/delete controls remain usable.
- `Notifications/Index`: only the signed-in user's notifications appear; opening one and marking all read retain existing behavior.
- Requested page `0` resolves as page 1; a very large page resolves as the last page; zero results show the existing empty state without pagination.
- At desktop and mobile widths, pagination wraps or remains usable without horizontal page overflow.

- [ ] **Step 5: Make a final correction commit only if verification changed files**

Stage only the corrected files, rerun the affected test plus the full build, and commit with `fix: correct admin pagination verification issue`. If no correction was necessary, do not create an empty commit.
