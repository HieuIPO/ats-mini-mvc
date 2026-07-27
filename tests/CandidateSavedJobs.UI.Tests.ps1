$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$indexView = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Views/Jobs/Index.cshtml')
$detailsView = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Views/Jobs/Details.cshtml')
$savedJobsView = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Views/Candidate/SavedJobs.cshtml')
$navbar = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Views/Shared/_Navbar.cshtml')
$layout = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Views/Shared/_Layout.cshtml')
$css = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Content/css/site.css')
$interactions = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Scripts/app/site-interactions.js')
$controller = Get-Content -Raw (Join-Path $root 'ATSMiniProject/Controllers/JobsController.cs')

foreach ($view in @($indexView, $detailsView)) {
    foreach ($required in @('SaveJob', 'UnsaveJob', 'job-save-button', 'is-saved', 'AntiForgeryToken', 'Request.RawUrl')) {
        if (-not $view.Contains($required)) {
            throw "Public job saved-state control is missing: $required"
        }
    }

    if (-not $view.Contains('Url.Action("Login", "Account"')) {
        throw 'Guest save control must link to login.'
    }
}

if (-not $navbar.Contains('Url.Action("SavedJobs", "Candidate")')) {
    throw 'Candidate account menu SavedJobs link is missing.'
}

foreach ($required in @('UnsaveJob', 'AntiForgeryToken', 'candidate-saved-jobs-grid', 'candidate-saved-job-unavailable')) {
    if (-not $savedJobsView.Contains($required)) {
        throw "Saved jobs page UI rule is missing: $required"
    }
}

foreach ($selector in @('.job-save-button', '.job-save-button.is-saved', '.candidate-saved-jobs-grid')) {
    if (-not $css.Contains($selector)) {
        throw "Saved jobs styling is missing: $selector"
    }
}

foreach ($view in @($indexView, $detailsView, $savedJobsView)) {
    if (-not $view.Contains('job-save-button-icon-only')) {
        throw 'Saved job actions must use the compact heart control.'
    }

    if (-not $view.Contains('M12 20.5')) {
        throw 'Saved job actions must render the heart icon.'
    }
}

if (-not $css.Contains('.job-save-button-icon-only')) {
    throw 'Compact heart styling is missing.'
}

if ($layout -notmatch 'site\.css\?v=20260727-5') {
    throw 'site.css must be cache-busted after saved-jobs styling changes.'
}

foreach ($required in @(
    'initializeSavedJobForms',
    'event.preventDefault()',
    'fetch(form.action',
    'X-Requested-With',
    'data-saved-job-form'
)) {
    if (-not $interactions.Contains($required)) {
        throw "AJAX saved-job interaction is missing: $required"
    }
}

if (-not $interactions.Contains('parseInt(count.textContent, 10)')) {
    throw 'Removing a saved card must decrement the total count across paginated results.'
}

if ($layout -notmatch 'site-interactions\.js\?v=20260727-1') {
    throw 'Saved-job JavaScript must be cache-busted.'
}

if (-not $detailsView.Contains('career-detail-primary-actions')) {
    throw 'The detail save control must share the primary action row.'
}

if (-not $controller.Contains('Request.IsAjaxRequest()')) {
    throw 'Saved-job endpoints must return an AJAX response without redirecting the page.'
}

'Candidate saved jobs UI tests passed.'
