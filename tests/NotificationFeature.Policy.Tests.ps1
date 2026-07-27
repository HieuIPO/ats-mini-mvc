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

$notificationModelPath = Join-Path $projectRoot 'ATSMiniProject\Models\Notification.cs'
$notificationServicePath = Join-Path $projectRoot 'ATSMiniProject\Services\NotificationService.cs'
$contextPath = Join-Path $projectRoot 'ATSMiniProject\Models\ATSMiniDBContext.cs'

foreach ($path in @($notificationModelPath, $notificationServicePath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing notification implementation: $path"
    }
}

$context = Get-Content -Raw -LiteralPath $contextPath
if (-not $context.Contains('DbSet<Notification> Notifications')) {
    throw 'ATSMiniDBContext must expose Notifications.'
}

$service = Get-Content -Raw -LiteralPath $notificationServicePath
foreach ($fragment in @('CreateNewApplicationNotification', 'NotificationRecipientPolicy.Resolve', 'NEW_APPLICATION')) {
    if (-not $service.Contains($fragment)) {
        throw "Notification service is missing: $fragment"
    }
}

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

$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\NotificationsController.cs'
if (-not (Test-Path -LiteralPath $controllerPath)) {
    throw 'Missing NotificationsController.'
}

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
    if (-not $controller.Contains($fragment)) {
        throw "Notification controller is missing: $fragment"
    }
}

$topbarPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_AdminTopbar.cshtml'
$bellPath = Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\_TopbarBell.cshtml'
$indexViewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\Index.cshtml'
$topbar = Get-Content -Raw -LiteralPath $topbarPath
if (-not $topbar.Contains('Html.Action("TopbarBell", "Notifications")')) {
    throw 'Admin topbar must render the notification bell child action.'
}
foreach ($path in @($bellPath, $indexViewPath)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing notification view: $path"
    }
}

Write-Output 'Notification schema policy checks passed.'
