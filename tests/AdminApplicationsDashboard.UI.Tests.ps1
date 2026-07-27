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
    'application-queue-card is-visible',
    'id="keyword"',
    'id = "jobId"',
    'id = "statusId"',
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
