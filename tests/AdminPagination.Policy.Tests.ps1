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
        $expectedName = if ($property -eq 'Page') {
            'ExpectedPage'
        }
        elseif ($property -eq 'TotalPages') {
            'ExpectedPages'
        }
        elseif ($property -eq 'Offset') {
            'ExpectedOffset'
        }
        elseif ($property -eq 'FirstItem') {
            'ExpectedFirst'
        }
        else {
            'ExpectedLast'
        }

        if ($result.$property -ne $case.$expectedName) {
            throw "Pagination case failed for $property`: expected $($case.$expectedName), got $($result.$property)."
        }
    }
}

Write-Output 'Pagination calculation tests passed: 4/4.'

$jobsController = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Controllers\JobsController.cs')
$jobsModel = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Jobs\JobFilterViewModel.cs')
$jobsView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Jobs\AdminIndex.cshtml')

foreach ($fragment in @(
    'private const int AdminPageSize = 12;',
    'int page = 1',
    'Pagination.Calculate(page, filteredJobs, AdminPageSize)',
    '.Skip(pagination.Offset)',
    '.Take(pagination.PageSize)',
    '.ThenBy(j => j.JobID)'
)) {
    if (-not $jobsController.Contains($fragment)) {
        throw "Jobs pagination is missing: $fragment"
    }
}

foreach ($fragment in @(
    'public int Page { get; set; }',
    'public int TotalPages { get; set; }',
    'public int FirstItem { get; set; }',
    'public int LastItem { get; set; }'
)) {
    if (-not $jobsModel.Contains($fragment)) {
        throw "JobFilterViewModel pagination is missing: $fragment"
    }
}

foreach ($fragment in @(
    'aria-label="Phân trang tin tuyển dụng"',
    'page = pageNumber',
    'keyword = Model.Keyword',
    'sort = Model.Sort',
    'aria-current'
)) {
    if (-not $jobsView.Contains($fragment)) {
        throw "Jobs view pagination is missing: $fragment"
    }
}

Write-Output 'Admin job pagination policy checks passed.'

$catalogCases = @(
    @{ Name = 'Departments'; Controller = 'DepartmentsController.cs'; View = 'Departments\Index.cshtml'; Model = '@model ATSMiniProject.ViewModels.Jobs.DepartmentListViewModel' },
    @{ Name = 'JobPositions'; Controller = 'JobPositionsController.cs'; View = 'JobPositions\Index.cshtml'; Model = '@model ATSMiniProject.ViewModels.Jobs.JobPositionListViewModel' }
)
$catalogModel = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Jobs\AdminCatalogListViewModels.cs')

foreach ($fragment in @(
    'class DepartmentListItemViewModel',
    'IList<DepartmentListItemViewModel> Items',
    'class JobPositionListItemViewModel',
    'IList<JobPositionListItemViewModel> Items'
)) {
    if (-not $catalogModel.Contains($fragment)) {
        throw "Catalog list DTO contract is missing: $fragment"
    }
}

foreach ($case in $catalogCases) {
    $controller = Get-Content -Raw (Join-Path $projectRoot "ATSMiniProject\Controllers\$($case.Controller)")
    $view = Get-Content -Raw (Join-Path $projectRoot "ATSMiniProject\Views\$($case.View)")

    foreach ($fragment in @(
        'private const int PageSize = 12;',
        'int page = 1',
        'Pagination.Calculate(page, totalItems, PageSize)',
        '.Skip(pagination.Offset)',
        '.Take(pagination.PageSize)'
    )) {
        if (-not $controller.Contains($fragment)) {
            throw "$($case.Name) pagination is missing: $fragment"
        }
    }

    foreach ($fragment in @(
        $case.Model,
        'Model.Items',
        'Model.TotalItems',
        'aria-current',
        'keyword = Model.Keyword',
        'page = pageNumber'
    )) {
        if (-not $view.Contains($fragment)) {
            throw "$($case.Name) view pagination is missing: $fragment"
        }
    }
}

Write-Output 'Recruitment catalog pagination policy checks passed.'

$notificationController = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Controllers\NotificationsController.cs')
$notificationModel = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Notifications\NotificationViewModels.cs')
$notificationView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Notifications\Index.cshtml')

foreach ($fragment in @(
    'private const int PageSize = 12;',
    'Index(int page = 1)',
    'Pagination.Calculate(page, totalItems, PageSize)',
    '.ThenByDescending(n => n.NotificationID)',
    '.Skip(pagination.Offset)',
    '.Take(pagination.PageSize)'
)) {
    if (-not $notificationController.Contains($fragment)) {
        throw "Notification pagination is missing: $fragment"
    }
}

foreach ($fragment in @(
    'public int Page { get; set; }',
    'public int TotalPages { get; set; }',
    'public int TotalItems { get; set; }',
    'public int FirstItem { get; set; }',
    'public int LastItem { get; set; }'
)) {
    if (-not $notificationModel.Contains($fragment)) {
        throw "Notification model pagination is missing: $fragment"
    }
}

foreach ($fragment in @(
    'aria-label="Phân trang thông báo"',
    'aria-current',
    'page = pageNumber'
)) {
    if (-not $notificationView.Contains($fragment)) {
        throw "Notification view pagination is missing: $fragment"
    }
}

Write-Output 'Notification pagination policy checks passed.'
