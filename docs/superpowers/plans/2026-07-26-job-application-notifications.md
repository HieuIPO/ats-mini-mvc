# Job Application Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add secure in-app notifications that go to the job creator after a successful application, with active Admin accounts as the fallback recipients.

**Architecture:** Add a `Notifications` table and matching EF6 Database-First-style entity/mapping. A small pure recipient policy decides between the eligible job creator and active Admin IDs; `NotificationService` loads the application and persists idempotent notifications only after the application transaction commits. `NotificationsController` owns recipient-scoped reads and POST-only read-state changes, while a child action renders the bell in the existing admin topbar.

**Tech Stack:** ASP.NET MVC 5, .NET Framework 4.8, Entity Framework 6.4.4, SQL Server, Razor, PowerShell policy tests, existing ATS CSS.

---

## File map

**Create**

- `ATSMiniProject/Models/Notification.cs` — database entity only.
- `ATSMiniProject/Helpers/NotificationRecipientPolicy.cs` — pure, database-free recipient selection.
- `ATSMiniProject/Services/NotificationService.cs` — query application/job owner and persist notifications.
- `ATSMiniProject/ViewModels/Notifications/NotificationViewModels.cs` — topbar and index DTOs.
- `ATSMiniProject/Controllers/NotificationsController.cs` — authorized list, bell, open, and mark-all actions.
- `ATSMiniProject/Views/Notifications/_TopbarBell.cshtml` — compact bell/dropdown.
- `ATSMiniProject/Views/Notifications/Index.cshtml` — full notification list.
- `tests/NotificationRecipientPolicy.Tests.ps1` — executable policy behavior tests.
- `tests/NotificationFeature.Policy.Tests.ps1` — schema/security/integration guardrails.

**Modify carefully; these files already contain uncommitted user changes**

- `database/ATSMiniDB_StudentPlus_Schema_Seed.sql` — idempotent table, indexes, quick-check query.
- `ATSMiniProject/Models/ATSMiniDBContext.cs` — `DbSet` and fluent mapping.
- `ATSMiniProject/Controllers/JobsController.cs` — best-effort notification call after commit.
- `ATSMiniProject/Views/Shared/_AdminTopbar.cshtml` — render notification child action.
- `ATSMiniProject/Content/css/ats-ui-v2.css` — bell, dropdown, list, responsive states.
- `ATSMiniProject/ATSMiniProject.csproj` — explicit Compile/Content entries required by old-style MSBuild.

Do not stage whole modified files when they contain pre-existing work. Before each commit, inspect `git diff` and stage only the feature-owned patch. If exact hunk staging cannot isolate the work safely, leave the mixed file unstaged and report it rather than committing someone else’s changes.

### Task 1: Lock the database contract with a failing policy test

**Files:**

- Create: `tests/NotificationFeature.Policy.Tests.ps1`
- Modify: `database/ATSMiniDB_StudentPlus_Schema_Seed.sql`

- [ ] **Step 1: Write the failing schema assertions**

Create `tests/NotificationFeature.Policy.Tests.ps1` with the initial schema checks:

```powershell
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$schemaPath = Join-Path $projectRoot 'database\ATSMiniDB_StudentPlus_Schema_Seed.sql'
$schema = Get-Content -Raw -LiteralPath $schemaPath

$requiredSchemaFragments = @(
    "OBJECT_ID(N'dbo.Notifications', N'U')",
    'CREATE TABLE dbo.Notifications',
    'RecipientUserID INT NOT NULL',
    'ApplicationID INT NULL',
    'NotificationType NVARCHAR(50) NOT NULL',
    'ReadAt DATETIME NULL',
    'FK_Notifications_Recipient',
    'FK_Notifications_Application',
    'UX_Notifications_Application_Recipient_Type',
    'IX_Notifications_Recipient_Read_Created'
)

foreach ($fragment in $requiredSchemaFragments) {
    if (-not $schema.Contains($fragment)) {
        throw "Notification schema is missing: $fragment"
    }
}

Write-Output 'Notification schema policy checks passed.'
```

- [ ] **Step 2: Run the test and verify the missing table failure**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\NotificationFeature.Policy.Tests.ps1
```

Expected: FAIL with `Notification schema is missing: OBJECT_ID(N'dbo.Notifications', N'U')`.

- [ ] **Step 3: Add the idempotent SQL table and indexes**

Insert after the `Applications` table block in `database/ATSMiniDB_StudentPlus_Schema_Seed.sql`:

```sql
IF OBJECT_ID(N'dbo.Notifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notifications (
        NotificationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RecipientUserID INT NOT NULL,
        ApplicationID INT NULL,
        NotificationType NVARCHAR(50) NOT NULL,
        Title NVARCHAR(150) NOT NULL,
        Message NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT GETDATE(),
        ReadAt DATETIME NULL,
        CONSTRAINT FK_Notifications_Recipient
            FOREIGN KEY (RecipientUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Notifications_Application
            FOREIGN KEY (ApplicationID) REFERENCES dbo.Applications(ApplicationID)
    );
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_Notifications_Application_Recipient_Type'
      AND object_id = OBJECT_ID(N'dbo.Notifications')
)
BEGIN
    CREATE UNIQUE INDEX UX_Notifications_Application_Recipient_Type
        ON dbo.Notifications (ApplicationID, RecipientUserID, NotificationType)
        WHERE ApplicationID IS NOT NULL;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Notifications_Recipient_Read_Created'
      AND object_id = OBJECT_ID(N'dbo.Notifications')
)
BEGIN
    CREATE INDEX IX_Notifications_Recipient_Read_Created
        ON dbo.Notifications (RecipientUserID, ReadAt, CreatedAt DESC);
END
GO
```

Append to the quick-check queries:

```sql
SELECT NotificationID, RecipientUserID, ApplicationID, NotificationType, CreatedAt, ReadAt
FROM dbo.Notifications
ORDER BY NotificationID;
```

- [ ] **Step 4: Re-run the schema policy test**

Run the same PowerShell command. Expected: `Notification schema policy checks passed.`

- [ ] **Step 5: Commit only safely isolatable files**

Stage the new test. Stage the SQL hunk only if it can be isolated from pre-existing SQL edits, then commit:

```powershell
git commit -m "feat: define notification database contract"
```

### Task 2: Implement and test recipient selection

**Files:**

- Create: `ATSMiniProject/Helpers/NotificationRecipientPolicy.cs`
- Create: `tests/NotificationRecipientPolicy.Tests.ps1`

- [ ] **Step 1: Write failing executable behavior tests**

Create `tests/NotificationRecipientPolicy.Tests.ps1`:

```powershell
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$policyPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\NotificationRecipientPolicy.cs'

if (-not (Test-Path -LiteralPath $policyPath)) {
    throw "Missing notification recipient policy: $policyPath"
}

$source = Get-Content -Raw -LiteralPath $policyPath
Add-Type -TypeDefinition $source -Language CSharp

$creator = [Nullable[int]]42
$admins = [int[]](1, 2, 2)

$creatorResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($creator, $true, $admins)
if (($creatorResult -join ',') -ne '42') {
    throw "Eligible creator should be the only recipient. Got: $($creatorResult -join ',')"
}

$fallbackResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($creator, $false, $admins)
if (($fallbackResult -join ',') -ne '1,2') {
    throw "Inactive creator should fall back to distinct Admin IDs. Got: $($fallbackResult -join ',')"
}

$missingResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($null, $false, [int[]]@())
if ($missingResult.Count -ne 0) {
    throw 'Missing creator and Admins should produce no recipients.'
}

Write-Output 'Notification recipient policy tests passed: 3/3.'
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\NotificationRecipientPolicy.Tests.ps1
```

Expected: FAIL with `Missing notification recipient policy`.

- [ ] **Step 3: Add the minimal pure policy**

Create `ATSMiniProject/Helpers/NotificationRecipientPolicy.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace ATSMiniProject.Helpers
{
    public static class NotificationRecipientPolicy
    {
        public static IReadOnlyList<int> Resolve(
            int? creatorUserId,
            bool creatorIsEligible,
            IEnumerable<int> activeAdminUserIds)
        {
            if (creatorIsEligible && creatorUserId.HasValue)
            {
                return new[] { creatorUserId.Value };
            }

            return (activeAdminUserIds ?? Enumerable.Empty<int>())
                .Distinct()
                .OrderBy(id => id)
                .ToList();
        }
    }
}
```

- [ ] **Step 4: Run the test and verify all cases pass**

Expected: `Notification recipient policy tests passed: 3/3.`

- [ ] **Step 5: Commit the isolated helper and test**

```powershell
git add ATSMiniProject\Helpers\NotificationRecipientPolicy.cs tests\NotificationRecipientPolicy.Tests.ps1
git commit -m "feat: select notification recipients"
```

### Task 3: Add the EF entity, mapping, and persistence service

**Files:**

- Create: `ATSMiniProject/Models/Notification.cs`
- Create: `ATSMiniProject/Services/NotificationService.cs`
- Modify: `ATSMiniProject/Models/ATSMiniDBContext.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`
- Modify: `tests/NotificationFeature.Policy.Tests.ps1`

- [ ] **Step 1: Extend the policy test with model/service contract checks**

Append before the final success output:

```powershell
$notificationModelPath = Join-Path $projectRoot 'ATSMiniProject\Models\Notification.cs'
$notificationServicePath = Join-Path $projectRoot 'ATSMiniProject\Services\NotificationService.cs'
$contextPath = Join-Path $projectRoot 'ATSMiniProject\Models\ATSMiniDBContext.cs'

foreach ($path in @($notificationModelPath, $notificationServicePath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing notification implementation: $path" }
}

$context = Get-Content -Raw -LiteralPath $contextPath
if (-not $context.Contains('DbSet<Notification> Notifications')) {
    throw 'ATSMiniDBContext must expose Notifications.'
}

$service = Get-Content -Raw -LiteralPath $notificationServicePath
foreach ($fragment in @('CreateNewApplicationNotification', 'NotificationRecipientPolicy.Resolve', 'NEW_APPLICATION')) {
    if (-not $service.Contains($fragment)) { throw "Notification service is missing: $fragment" }
}
```

- [ ] **Step 2: Run the policy test and verify missing implementation failure**

Expected: FAIL with `Missing notification implementation`.

- [ ] **Step 3: Create the entity**

Create `ATSMiniProject/Models/Notification.cs`:

```csharp
using System;

namespace ATSMiniProject.Models
{
    public partial class Notification
    {
        public int NotificationID { get; set; }
        public int RecipientUserID { get; set; }
        public int? ApplicationID { get; set; }
        public string NotificationType { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ReadAt { get; set; }

        public virtual User RecipientUser { get; set; }
        public virtual Application Application { get; set; }
    }
}
```

- [ ] **Step 4: Add context mapping**

Add `public virtual DbSet<Notification> Notifications { get; set; }`, then configure:

```csharp
modelBuilder.Entity<Notification>()
    .ToTable("Notifications")
    .HasKey(e => e.NotificationID);
modelBuilder.Entity<Notification>().Property(e => e.NotificationType).IsRequired().HasMaxLength(50);
modelBuilder.Entity<Notification>().Property(e => e.Title).IsRequired().HasMaxLength(150);
modelBuilder.Entity<Notification>().Property(e => e.Message).IsRequired().HasMaxLength(500);

modelBuilder.Entity<Notification>()
    .HasRequired(e => e.RecipientUser)
    .WithMany()
    .HasForeignKey(e => e.RecipientUserID)
    .WillCascadeOnDelete(false);

modelBuilder.Entity<Notification>()
    .HasOptional(e => e.Application)
    .WithMany()
    .HasForeignKey(e => e.ApplicationID)
    .WillCascadeOnDelete(false);
```

- [ ] **Step 5: Add the best-effort persistence service**

Create `ATSMiniProject/Services/NotificationService.cs`:

```csharp
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;

namespace ATSMiniProject.Services
{
    public class NotificationService
    {
        private const string NewApplicationType = "NEW_APPLICATION";

        public void CreateNewApplicationNotification(int applicationId)
        {
            using (var db = new ATSMiniDBContext())
            {
                var application = db.Applications
                    .Include(a => a.Job.User.Role)
                    .SingleOrDefault(a => a.ApplicationID == applicationId && !a.IsDeleted);
                if (application == null) return;

                var creator = application.Job == null ? null : application.Job.User;
                var creatorIsEligible = creator != null &&
                    creator.IsActive &&
                    creator.Role != null &&
                    InternalAccountRolePolicy.IsAllowedRoleName(creator.Role.RoleName);

                var adminIds = creatorIsEligible
                    ? Enumerable.Empty<int>()
                    : db.Users
                        .Where(u => u.IsActive && u.Role.RoleName == "Admin")
                        .Select(u => u.UserID)
                        .ToList();

                var recipientIds = NotificationRecipientPolicy.Resolve(
                    application.Job == null ? null : application.Job.CreatedByUserID,
                    creatorIsEligible,
                    adminIds);

                if (recipientIds.Count == 0)
                {
                    Trace.TraceWarning(
                        "No eligible notification recipient for application {0}.",
                        application.ApplicationID);
                    return;
                }

                foreach (var recipientId in recipientIds)
                {
                    var exists = db.Notifications.Any(n =>
                        n.ApplicationID == application.ApplicationID &&
                        n.RecipientUserID == recipientId &&
                        n.NotificationType == NewApplicationType);
                    if (exists) continue;

                    db.Notifications.Add(new Notification
                    {
                        RecipientUserID = recipientId,
                        ApplicationID = application.ApplicationID,
                        NotificationType = NewApplicationType,
                        Title = "Hồ sơ ứng tuyển mới",
                        Message = application.CandidateName + " vừa ứng tuyển " + application.Job.Title + ".",
                        CreatedAt = DateTime.Now
                    });
                }

                db.SaveChanges();
            }
        }
    }
}
```

- [ ] **Step 6: Add explicit project entries**

Add Compile items for `Helpers\NotificationRecipientPolicy.cs`, `Models\Notification.cs`, and `Services\NotificationService.cs`. Add a `Folder Include="Services\"` entry only if the folder is otherwise absent.

- [ ] **Step 7: Re-run both PowerShell tests and build**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\NotificationRecipientPolicy.Tests.ps1
powershell -ExecutionPolicy Bypass -File tests\NotificationFeature.Policy.Tests.ps1
msbuild ATSMiniProject.sln /t:Build /p:Configuration=Debug
```

Expected: both tests PASS and build ends with `Build succeeded` and zero errors.

- [ ] **Step 8: Commit isolated new files; stage mixed files only by verified hunks**

Commit message: `feat: persist application notifications`.

### Task 4: Trigger notifications only after application commit

**Files:**

- Modify: `ATSMiniProject/Controllers/JobsController.cs`
- Modify: `tests/NotificationFeature.Policy.Tests.ps1`

- [ ] **Step 1: Add a failing source-order test**

Append:

```powershell
$jobsControllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\JobsController.cs'
$jobsController = Get-Content -Raw -LiteralPath $jobsControllerPath
$commitIndex = $jobsController.IndexOf('transaction.Commit();')
$notifyIndex = $jobsController.IndexOf('CreateNewApplicationNotification(application.ApplicationID)')
if ($commitIndex -lt 0 -or $notifyIndex -lt 0 -or $notifyIndex -lt $commitIndex) {
    throw 'Notification creation must occur after the application transaction commits.'
}
if (-not $jobsController.Contains('Trace.TraceError')) {
    throw 'Notification failure must be logged without failing the application.'
}
```

- [ ] **Step 2: Run and verify it fails because the call is absent**

Expected: FAIL with `Notification creation must occur after the application transaction commits.`

- [ ] **Step 3: Add the post-commit best-effort call**

Add `using System.Diagnostics;` and `using ATSMiniProject.Services;`. Immediately after `transaction.Commit();` add:

```csharp
try
{
    new NotificationService()
        .CreateNewApplicationNotification(application.ApplicationID);
}
catch (Exception notificationException)
{
    Trace.TraceError(
        "Could not create notification for application {0}: {1}",
        application.ApplicationID,
        notificationException);
}
```

Do not move this call into the database transaction and do not change the success redirect.

- [ ] **Step 4: Run the policy test and build**

Expected: PASS and zero build errors.

- [ ] **Step 5: Stage only the new controller hunks if safe**

Commit message: `feat: notify job owner after application submission`.

### Task 5: Add secure notification endpoints and view models

**Files:**

- Create: `ATSMiniProject/ViewModels/Notifications/NotificationViewModels.cs`
- Create: `ATSMiniProject/Controllers/NotificationsController.cs`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`
- Modify: `tests/NotificationFeature.Policy.Tests.ps1`

- [ ] **Step 1: Add failing controller security checks**

Append:

```powershell
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\NotificationsController.cs'
if (-not (Test-Path -LiteralPath $controllerPath)) { throw 'Missing NotificationsController.' }
$controller = Get-Content -Raw -LiteralPath $controllerPath
foreach ($fragment in @(
    '[AuthorizeRole("Admin", "HR")]',
    '[ChildActionOnly]',
    '[HttpPost]',
    '[ValidateAntiForgeryToken]',
    'n.RecipientUserID == currentUserId',
    'MarkAllRead',
    'Open(int id)'
)) {
    if (-not $controller.Contains($fragment)) { throw "Notification controller is missing: $fragment" }
}
```

- [ ] **Step 2: Run and verify the missing controller failure**

Expected: FAIL with `Missing NotificationsController.`

- [ ] **Step 3: Add focused DTOs**

Create `NotificationViewModels.cs` containing:

```csharp
using System;
using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Notifications
{
    public class NotificationItemViewModel
    {
        public int NotificationId { get; set; }
        public int? ApplicationId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRead { get; set; }
    }

    public class NotificationTopbarViewModel
    {
        public int UnreadCount { get; set; }
        public IReadOnlyList<NotificationItemViewModel> RecentItems { get; set; }
    }

    public class NotificationIndexViewModel
    {
        public int UnreadCount { get; set; }
        public IReadOnlyList<NotificationItemViewModel> Items { get; set; }
    }
}
```

- [ ] **Step 4: Implement recipient-scoped controller actions**

Create `NotificationsController` with class-level `[AuthorizeRole("Admin", "HR")]`:

```csharp
using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Notifications;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class NotificationsController : Controller
    {
        [ChildActionOnly]
        public ActionResult TopbarBell()
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var query = db.Notifications.AsNoTracking()
                    .Where(n => n.RecipientUserID == currentUserId);
                return PartialView("_TopbarBell", new NotificationTopbarViewModel
                {
                    UnreadCount = query.Count(n => n.ReadAt == null),
                    RecentItems = query.OrderByDescending(n => n.CreatedAt)
                        .Take(5)
                        .Select(n => new NotificationItemViewModel
                        {
                            NotificationId = n.NotificationID,
                            ApplicationId = n.ApplicationID,
                            Title = n.Title,
                            Message = n.Message,
                            CreatedAt = n.CreatedAt,
                            IsRead = n.ReadAt != null
                        }).ToList()
                });
            }
        }

        [HttpGet]
        public ActionResult Index()
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var query = db.Notifications.AsNoTracking()
                    .Where(n => n.RecipientUserID == currentUserId);
                return View(new NotificationIndexViewModel
                {
                    UnreadCount = query.Count(n => n.ReadAt == null),
                    Items = query.OrderByDescending(n => n.CreatedAt)
                        .Select(n => new NotificationItemViewModel
                        {
                            NotificationId = n.NotificationID,
                            ApplicationId = n.ApplicationID,
                            Title = n.Title,
                            Message = n.Message,
                            CreatedAt = n.CreatedAt,
                            IsRead = n.ReadAt != null
                        }).ToList()
                });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Open(int id)
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var notification = db.Notifications
                    .SingleOrDefault(n => n.NotificationID == id &&
                                          n.RecipientUserID == currentUserId);
                if (notification == null) return HttpNotFound();
                if (notification.ReadAt == null)
                {
                    notification.ReadAt = DateTime.Now;
                    db.SaveChanges();
                }

                if (!notification.ApplicationID.HasValue ||
                    !db.Applications.Any(a => a.ApplicationID == notification.ApplicationID.Value && !a.IsDeleted))
                {
                    TempData["Error"] = "Hồ sơ liên quan không còn khả dụng.";
                    return RedirectToAction("Index");
                }

                return RedirectToAction("Review", "Applications", new { id = notification.ApplicationID.Value });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult MarkAllRead()
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var now = DateTime.Now;
                var unread = db.Notifications
                    .Where(n => n.RecipientUserID == currentUserId && n.ReadAt == null)
                    .ToList();
                foreach (var notification in unread) notification.ReadAt = now;
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        private int CurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }
    }
}
```

- [ ] **Step 5: Add Compile entries, run policy tests, and build**

Expected: all tests pass and build succeeds.

- [ ] **Step 6: Commit isolated new files and verified project hunks**

Commit message: `feat: add secure notification endpoints`.

### Task 6: Add the bell and full notification UI

**Files:**

- Create: `ATSMiniProject/Views/Notifications/_TopbarBell.cshtml`
- Create: `ATSMiniProject/Views/Notifications/Index.cshtml`
- Modify: `ATSMiniProject/Views/Shared/_AdminTopbar.cshtml`
- Modify: `ATSMiniProject/Content/css/ats-ui-v2.css`
- Modify: `ATSMiniProject/ATSMiniProject.csproj`

- [ ] **Step 1: Add failing view integration checks**

Append to the feature policy test:

```powershell
$topbarPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_AdminTopbar.cshtml'
$bellPath = Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\_TopbarBell.cshtml'
$indexViewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\Index.cshtml'
$topbar = Get-Content -Raw -LiteralPath $topbarPath
if (-not $topbar.Contains('Html.Action("TopbarBell", "Notifications")')) {
    throw 'Admin topbar must render the notification bell child action.'
}
foreach ($path in @($bellPath, $indexViewPath)) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing notification view: $path" }
}
```

- [ ] **Step 2: Run and verify the topbar integration failure**

Expected: FAIL with `Admin topbar must render the notification bell child action.`

- [ ] **Step 3: Create the compact bell partial**

Create `_TopbarBell.cshtml`:

```cshtml
@model ATSMiniProject.ViewModels.Notifications.NotificationTopbarViewModel

<details class="admin-notification-menu">
    <summary class="admin-notification-button"
             aria-label="Mở thông báo@(Model.UnreadCount > 0 ? ", " + Model.UnreadCount + " chưa đọc" : string.Empty)">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"></path>
            <path d="M10 21h4"></path>
        </svg>
        @if (Model.UnreadCount > 0)
        {
            <span class="admin-notification-badge">@(Model.UnreadCount > 99 ? "99+" : Model.UnreadCount.ToString())</span>
        }
    </summary>
    <div class="admin-notification-popover">
        <div class="admin-notification-heading">
            <strong>Thông báo</strong>
            <a href="@Url.Action("Index", "Notifications")">Xem tất cả</a>
        </div>
        @if (Model.RecentItems.Count == 0)
        {
            <p class="admin-notification-empty">Chưa có thông báo.</p>
        }
        else
        {
            <div class="admin-notification-items">
                @foreach (var item in Model.RecentItems)
                {
                    using (Html.BeginForm("Open", "Notifications", FormMethod.Post, new { @class = "admin-notification-form" }))
                    {
                        @Html.AntiForgeryToken()
                        @Html.Hidden("id", item.NotificationId)
                        <button class="admin-notification-item @(item.IsRead ? string.Empty : "notification-item-unread")" type="submit">
                            <strong>@item.Title</strong>
                            <span>@item.Message</span>
                            <small>@item.CreatedAt.ToString("dd/MM/yyyy HH:mm")</small>
                        </button>
                    }
                }
            </div>
        }
    </div>
</details>
```

- [ ] **Step 4: Create the full index view**

Create `Index.cshtml`:

```cshtml
@model ATSMiniProject.ViewModels.Notifications.NotificationIndexViewModel
@{
    ViewBag.Title = "Thông báo";
    Layout = "~/Views/Shared/_AdminLayout.cshtml";
}

<section class="notification-page">
    <header class="notification-page-header">
        <div>
            <span class="eyebrow">Hộp thư tuyển dụng</span>
            <h1>Thông báo</h1>
            <p>@Model.UnreadCount thông báo chưa đọc.</p>
        </div>
        @if (Model.UnreadCount > 0)
        {
            using (Html.BeginForm("MarkAllRead", "Notifications", FormMethod.Post))
            {
                @Html.AntiForgeryToken()
                <button class="btn btn-outline-primary" type="submit">Đánh dấu tất cả đã đọc</button>
            }
        }
    </header>

    @if (Model.Items.Count == 0)
    {
        <div class="notification-empty-state">
            <h2>Chưa có thông báo</h2>
            <p>Hồ sơ mới gửi tới tin tuyển dụng của bạn sẽ xuất hiện tại đây.</p>
        </div>
    }
    else
    {
        <div class="notification-list">
            @foreach (var item in Model.Items)
            {
                using (Html.BeginForm("Open", "Notifications", FormMethod.Post, new { @class = "notification-list-form" }))
                {
                    @Html.AntiForgeryToken()
                    @Html.Hidden("id", item.NotificationId)
                    <button class="notification-list-item @(item.IsRead ? string.Empty : "notification-item-unread")" type="submit">
                        <span class="notification-status-dot" aria-hidden="true"></span>
                        <span class="notification-list-copy">
                            <strong>@item.Title</strong>
                            <span>@item.Message</span>
                            <small>@item.CreatedAt.ToString("dd/MM/yyyy HH:mm")</small>
                        </span>
                    </button>
                }
            }
        </div>
    }
</section>
```

- [ ] **Step 5: Insert the bell before the account menu**

In `_AdminTopbar.cshtml`, inside `.admin-topbar-actions` and before `.admin-account-menu`, add:

```cshtml
@Html.Action("TopbarBell", "Notifications")
```

- [ ] **Step 6: Add scoped responsive CSS**

Append these scoped styles; do not alter existing account-menu selectors:

```css
.admin-notification-menu {
    position: relative;
}

.admin-notification-menu > summary {
    list-style: none;
}

.admin-notification-menu > summary::-webkit-details-marker {
    display: none;
}

.admin-notification-button {
    position: relative;
    display: grid;
    width: 2.75rem;
    height: 2.75rem;
    place-items: center;
    border: 1px solid var(--ats-border);
    border-radius: 50%;
    color: var(--ats-navy);
    background: var(--ats-surface);
    cursor: pointer;
}

.admin-notification-button svg {
    width: 1.2rem;
    fill: none;
    stroke: currentColor;
    stroke-linecap: round;
    stroke-linejoin: round;
    stroke-width: 1.8;
}

.admin-notification-button:focus-visible,
.admin-notification-item:focus-visible,
.notification-list-item:focus-visible {
    outline: 3px solid rgba(15, 118, 110, 0.2);
    outline-offset: 2px;
}

.admin-notification-badge {
    position: absolute;
    top: -0.25rem;
    right: -0.35rem;
    min-width: 1.25rem;
    padding: 0.12rem 0.32rem;
    border: 2px solid var(--ats-surface);
    border-radius: 999px;
    color: #fff;
    background: var(--ats-danger);
    font-size: 0.65rem;
    font-weight: 800;
    line-height: 1;
    text-align: center;
}

.admin-notification-popover {
    position: absolute;
    z-index: 60;
    top: calc(100% + 0.5rem);
    right: 0;
    display: none;
    width: min(22rem, calc(100vw - 2rem));
    overflow: hidden;
    border: 1px solid var(--ats-border);
    border-radius: 0.9rem;
    background: var(--ats-surface);
    box-shadow: var(--ats-shadow-md);
}

.admin-notification-menu[open] .admin-notification-popover {
    display: block;
}

.admin-notification-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0.85rem 1rem;
    border-bottom: 1px solid var(--ats-border);
}

.admin-notification-heading a {
    color: var(--ats-primary);
    font-size: 0.82rem;
    font-weight: 700;
}

.admin-notification-items {
    max-height: 24rem;
    overflow-y: auto;
}

.admin-notification-form,
.notification-list-form {
    margin: 0;
}

.admin-notification-item {
    display: grid;
    width: 100%;
    gap: 0.18rem;
    padding: 0.85rem 1rem;
    border: 0;
    border-bottom: 1px solid var(--ats-border);
    color: var(--ats-text);
    background: var(--ats-surface);
    text-align: left;
    cursor: pointer;
}

.admin-notification-item span,
.admin-notification-item small {
    color: var(--ats-muted);
}

.admin-notification-item.notification-item-unread,
.notification-list-item.notification-item-unread {
    background: var(--ats-primary-soft);
}

.admin-notification-empty {
    margin: 0;
    padding: 1.25rem;
    color: var(--ats-muted);
    text-align: center;
}

.notification-page {
    display: grid;
    gap: 1.25rem;
}

.notification-page-header {
    display: flex;
    align-items: flex-end;
    justify-content: space-between;
    gap: 1rem;
}

.notification-page-header h1,
.notification-page-header p {
    margin-bottom: 0;
}

.notification-list {
    overflow: hidden;
    border: 1px solid var(--ats-border);
    border-radius: 1rem;
    background: var(--ats-surface);
}

.notification-list-item {
    display: flex;
    width: 100%;
    gap: 0.8rem;
    align-items: flex-start;
    padding: 1rem 1.1rem;
    border: 0;
    border-bottom: 1px solid var(--ats-border);
    color: var(--ats-text);
    background: var(--ats-surface);
    text-align: left;
    cursor: pointer;
}

.notification-status-dot {
    width: 0.55rem;
    height: 0.55rem;
    flex: 0 0 0.55rem;
    margin-top: 0.4rem;
    border-radius: 50%;
    background: var(--ats-border);
}

.notification-item-unread .notification-status-dot {
    background: var(--ats-primary);
}

.notification-list-copy {
    display: grid;
    gap: 0.2rem;
}

.notification-list-copy span,
.notification-list-copy small,
.notification-empty-state p {
    color: var(--ats-muted);
}

.notification-empty-state {
    padding: 3rem 1.25rem;
    border: 1px dashed var(--ats-border);
    border-radius: 1rem;
    text-align: center;
}

@media (max-width: 575.98px) {
    .admin-notification-popover {
        position: fixed;
        top: 4.5rem;
        right: 1rem;
        left: 1rem;
        width: auto;
    }

    .notification-page-header {
        align-items: stretch;
        flex-direction: column;
    }
}
```

- [ ] **Step 7: Add Content entries for both views and build**

Expected: policy tests pass, Razor files are included, and build has zero errors.

- [ ] **Step 8: Commit only safely isolated UI work**

Commit message: `feat: add notification bell and inbox`.

### Task 7: End-to-end verification and evidence

**Files:**

- Test: `tests/NotificationRecipientPolicy.Tests.ps1`
- Test: `tests/NotificationFeature.Policy.Tests.ps1`
- Verify: all feature files above

- [ ] **Step 1: Run all repository policy tests**

```powershell
Get-ChildItem tests\*.Tests.ps1 | ForEach-Object {
    powershell -ExecutionPolicy Bypass -File $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "Failed: $($_.Name)" }
}
```

Expected: every script reports success.

- [ ] **Step 2: Run a clean solution build**

```powershell
msbuild ATSMiniProject.sln /t:Rebuild /p:Configuration=Debug
```

Expected: `Build succeeded`, zero errors. Existing warnings must be reported rather than hidden.

- [ ] **Step 3: Apply the SQL script to a disposable/local database**

Run the repository SQL script against the configured local SQL Server instance twice. Expected: both runs complete without duplicate-object or duplicate-index errors, and the final Notifications quick-check query succeeds.

- [ ] **Step 4: Verify the primary-recipient browser flow**

In a real browser:

1. Log in as HR and create a job.
2. Log in as Candidate and submit a valid CV to that job.
3. Log back in as the same HR.
4. Confirm the bell shows one unread item with the candidate and job names.
5. Open it; confirm it becomes read and redirects to the correct application review.
6. Log in as a different active HR; confirm the notification is absent.

- [ ] **Step 5: Verify fallback and authorization behavior**

On disposable data, deactivate the job creator or set the job’s `CreatedByUserID` to NULL, submit another application, and verify active Admin accounts receive it. Attempt to POST another user’s notification ID and expect 404 with no read-state change.

- [ ] **Step 6: Inspect the final diff for scope and secrets**

```powershell
git diff --check
git status --short
git diff --name-only
```

Confirm no CV data, connection-string secrets, build output, or unrelated formatting is introduced. Explicitly list pre-existing dirty files that remain outside feature ownership.

- [ ] **Step 7: Create a final commit only if remaining feature hunks are safely isolated**

Use `test: verify application notification workflow`. If mixed pre-existing hunks cannot be separated safely, do not commit them; hand off the verified working tree state with a precise list.
