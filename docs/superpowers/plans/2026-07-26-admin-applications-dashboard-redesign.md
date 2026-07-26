# Admin Applications Dashboard Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the Admin/HR candidate applications page as a polished operations dashboard with all five filters permanently visible.

**Architecture:** Keep the controller, view model, routes, queue semantics, actions, and pagination untouched. Change only the Razor composition and page-scoped CSS; protect the behavior with a source-contract regression test and verify Razor compilation.

**Tech Stack:** ASP.NET MVC 5, Razor, CSS, PowerShell contract tests, MSBuild.

---

## File map

- Create `tests/AdminApplicationsDashboard.UI.Tests.ps1`: verifies filter visibility, preserved routes/actions, richer candidate information, and scoped CSS.
- Modify `ATSMiniProject/Views/Applications/Index.cshtml`: removes the collapsible filter and applies the new operations-dashboard markup.
- Modify `ATSMiniProject/Content/css/ats-ui-v2.css`: replaces application filter/detail styling with responsive page-scoped dashboard styling.
- Do not modify `ApplicationsController.cs`, application view models, shared layouts, bundles, or database files.

### Task 1: Lock the new view contract with a failing test

**Files:**
- Create: `tests/AdminApplicationsDashboard.UI.Tests.ps1`
- Test: `ATSMiniProject/Views/Applications/Index.cshtml`
- Test: `ATSMiniProject/Content/css/ats-ui-v2.css`

- [ ] **Step 1: Create the source-contract test**

```powershell
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $root 'ATSMiniProject\Views\Applications\Index.cshtml'
$cssPath = Join-Path $root 'ATSMiniProject\Content\css\ats-ui-v2.css'
$view = Get-Content -Raw -LiteralPath $viewPath
$css = Get-Content -Raw -LiteralPath $cssPath

if ($view.Contains('<details class="application-filter-details"')) {
    throw 'The detailed filter disclosure must be removed.'
}

foreach ($fragment in @(
    'class="application-ops-page"',
    'class="application-ops-filter-grid"',
    'class="application-ops-filter-actions"',
    'id="keyword"',
    'id="jobId"',
    'id="statusId"',
    'id="fromDate"',
    'id="toDate"',
    '@item.CandidateEmail',
    '@item.CandidatePhone',
    'Url.Action("Create", "Interviews")',
    'Url.Action("Review", "Applications"',
    'queue = Model.Queue',
    'page = pageNumber'
)) {
    if (-not $view.Contains($fragment)) {
        throw "Applications dashboard view is missing: $fragment"
    }
}

foreach ($fragment in @(
    '.application-ops-page',
    '.application-ops-filter-grid',
    '.application-ops-filter-actions',
    '.application-ops-contact',
    '@media (max-width: 1099.98px)',
    '@media (max-width: 679.98px)'
)) {
    if (-not $css.Contains($fragment)) {
        throw "Applications dashboard CSS is missing: $fragment"
    }
}

Write-Output 'Admin applications dashboard UI contract tests passed.'
```

- [ ] **Step 2: Run the test and verify the intended failure**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminApplicationsDashboard.UI.Tests.ps1`

Expected: non-zero exit with `The detailed filter disclosure must be removed.`

### Task 2: Recompose the Razor view

**Files:**
- Modify: `ATSMiniProject/Views/Applications/Index.cshtml`
- Test: `tests/AdminApplicationsDashboard.UI.Tests.ps1`

- [ ] **Step 1: Add the page scope and remove obsolete detail-filter state**

Wrap the existing page content in `<div class="application-ops-page">`. Delete `hasDetailFilters`; it has no consumer after the disclosure is removed. Keep `statusClass`, `queueUrl`, and `queueTitle` unchanged.

- [ ] **Step 2: Replace the filter disclosure with one always-visible grid**

Inside the existing GET form, keep `@Html.Hidden("queue", Model.Queue)` and render this structure:

```cshtml
<div class="application-ops-filter-heading">
    <div>
        <span class="application-ops-filter-kicker">Tìm kiếm &amp; sàng lọc</span>
        <h2>Bộ lọc hồ sơ</h2>
    </div>
    <p>Thu hẹp danh sách theo vị trí, trạng thái và thời gian nộp.</p>
</div>
<div class="application-ops-filter-grid">
    <div class="filter-field application-ops-search">
        <label for="keyword">Ứng viên hoặc vị trí</label>
        <input id="keyword" name="keyword" type="search" class="form-control" value="@Model.Keyword" placeholder="Tên, email, số điện thoại hoặc vị trí..." />
    </div>
    <div class="filter-field application-ops-job">
        <label for="jobId">Tin tuyển dụng</label>
        @Html.DropDownList("jobId", Model.Jobs, "Tất cả tin tuyển dụng", new { @class = "form-select", id = "jobId" })
    </div>
    <div class="filter-field application-ops-status">
        <label for="statusId">Trạng thái hồ sơ</label>
        @Html.DropDownList("statusId", Model.Statuses, "Tất cả trạng thái", new { @class = "form-select", id = "statusId" })
    </div>
    <div class="filter-field application-ops-date">
        <label for="fromDate">Nộp từ ngày</label>
        <input id="fromDate" name="fromDate" type="date" class="form-control" value="@(Model.FromDate.HasValue ? Model.FromDate.Value.ToString("yyyy-MM-dd") : null)" />
    </div>
    <div class="filter-field application-ops-date">
        <label for="toDate">Nộp đến ngày</label>
        <input id="toDate" name="toDate" type="date" class="form-control" value="@(Model.ToDate.HasValue ? Model.ToDate.Value.ToString("yyyy-MM-dd") : null)" />
    </div>
    <div class="application-ops-filter-actions">
        <button class="btn btn-primary" type="submit">Lọc hồ sơ</button>
        <a class="btn btn-outline-secondary" href="@Url.Action("Index", "Applications")">Đặt lại</a>
    </div>
</div>
```

- [ ] **Step 3: Enrich the existing table without changing its actions**

Under the candidate name and application ID, add:

```cshtml
<span class="application-ops-contact">
    <small>@item.CandidateEmail</small>
    <small>@item.CandidatePhone</small>
</span>
```

Keep `actionText`, `actionUrl`, interview scheduling, Review links, row status classes, queue navigation, empty state, and the complete pagination route object unchanged.

- [ ] **Step 4: Run the UI contract test**

Run the new script. Expected: it now advances beyond the removed disclosure and fails on the first missing CSS fragment.

### Task 3: Apply the scoped visual system and responsive behavior

**Files:**
- Modify: `ATSMiniProject/Content/css/ats-ui-v2.css`
- Test: `tests/AdminApplicationsDashboard.UI.Tests.ps1`

- [ ] **Step 1: Replace obsolete filter disclosure rules**

Remove `.application-filter-details`, its `summary` rules, and `.application-filter-detail-grid`. Add page-scoped rules with these layout contracts:

```css
.application-ops-page {
    --application-ops-line: #d7e5e3;
    --application-ops-soft: #f4f9f8;
}

.application-ops-page .application-queue-header {
    margin-bottom: 1.15rem;
}

.application-ops-page .application-queue-tabs {
    margin-bottom: 1.25rem;
    border-color: var(--application-ops-line);
}

.application-ops-page .application-filter-panel {
    border: 1px solid var(--application-ops-line);
    border-top: 3px solid var(--ats-primary);
    background: #ffffff;
}

.application-ops-filter-heading {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 1.5rem;
    padding: 1.2rem 1.25rem 0;
}

.application-ops-filter-heading h2 {
    margin: 0.15rem 0 0;
    color: var(--ats-navy);
    font-size: 1.05rem;
}

.application-ops-filter-heading p,
.application-ops-filter-kicker {
    margin: 0;
    color: var(--ats-muted);
    font-size: 0.76rem;
}

.application-ops-filter-kicker {
    color: var(--ats-primary);
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
}

.application-ops-filter-grid {
    display: grid;
    grid-template-columns: minmax(16rem, 1.8fr) minmax(14rem, 1.35fr) minmax(11rem, 1fr);
    gap: 0.9rem;
    padding: 1rem 1.25rem 1.25rem;
}

.application-ops-filter-grid .filter-field {
    margin: 0;
}

.application-ops-filter-grid label {
    display: block;
    margin-bottom: 0.42rem;
    color: #486364;
    font-size: 0.72rem;
    font-weight: 750;
}

.application-ops-date {
    min-width: 0;
}

.application-ops-filter-actions {
    display: flex;
    align-items: flex-end;
    gap: 0.6rem;
}

.application-ops-filter-actions .btn {
    min-height: 3rem;
}

.application-ops-contact {
    display: flex;
    flex-wrap: wrap;
    gap: 0.2rem 0.65rem;
    margin-top: 0.3rem;
}

.application-ops-contact small {
    overflow-wrap: anywhere;
}
```

- [ ] **Step 2: Add exact responsive contracts**

```css
@media (max-width: 1099.98px) {
    .application-ops-filter-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .application-ops-search,
    .application-ops-job,
    .application-ops-filter-actions {
        grid-column: 1 / -1;
    }
}

@media (max-width: 679.98px) {
    .application-ops-filter-heading {
        align-items: flex-start;
        flex-direction: column;
        gap: 0.35rem;
    }

    .application-ops-filter-grid {
        grid-template-columns: minmax(0, 1fr);
    }

    .application-ops-filter-actions {
        flex-direction: column;
    }

    .application-ops-filter-actions .btn {
        width: 100%;
    }
}
```

Keep existing queue-tab and table rules unless a visual check proves a scoped correction is needed.

- [ ] **Step 3: Run the UI test and build**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/AdminApplicationsDashboard.UI.Tests.ps1
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Build /p:Configuration=Debug /m
```

Expected: UI test passes; build exits 0 with no compilation errors.

### Task 4: Final verification

**Files:**
- Verify all files changed above.

- [ ] **Step 1: Run every PowerShell test**

Run all `tests/*.Tests.ps1`; expected: every script exits 0.

- [ ] **Step 2: Rebuild Razor views**

Run:

```powershell
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' ATSMiniProject.sln /t:Rebuild /p:Configuration=Debug /p:MvcBuildViews=true /m
```

Expected: 0 errors.

- [ ] **Step 3: Inspect scope and whitespace**

Run `git diff --check` and inspect only the view, page CSS, and new test. Do not stage source files because the view and stylesheet contain pre-existing user changes.

- [ ] **Step 4: Verify the rendered page when browser control is available**

At desktop and mobile widths, confirm all five filters are visible without interaction, queue tabs remain usable, candidate contacts wrap, the table does not overlap actions, and filtering/pagination preserve query parameters. If browser control is unavailable, report this limitation rather than inferring a visual pass.
