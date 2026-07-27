$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Candidate\Index.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)
    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view 'class="candidate-overview-page"' 'Candidate overview page root is missing.'
Assert-Contains $view 'class="candidate-overview-header"' 'Compact candidate header is missing.'
Assert-Contains $view 'class="candidate-overview-metrics"' 'Candidate metric strip is missing.'
Assert-Contains $view 'class="candidate-overview-layout"' 'Candidate content layout is missing.'
Assert-Contains $view 'class="candidate-activity-panel"' 'Application activity panel is missing.'
Assert-Contains $view 'class="candidate-opportunity-panel"' 'Recommended opportunity panel is missing.'
Assert-Contains $view 'class="candidate-profile-prompt"' 'Incomplete profile prompt is missing.'
Assert-Contains $view '@Model\.TotalApplications' 'Total application metric was removed.'
Assert-Contains $view '@Model\.ActiveApplications' 'Active application metric was removed.'
Assert-Contains $view '@Model\.UpcomingInterviews' 'Interview metric was removed.'

if ($view -match 'class="candidate-dashboard-hero"') {
    throw 'The oversized legacy candidate dashboard hero must be removed.'
}

$requiredRoutes = @(
    'Url\.Action\("Index",\s*"Jobs"\)',
    'Url\.Action\("Profile",\s*"Candidate"\)',
    'Url\.Action\("Status",\s*"Applications"\)',
    'Url\.Action\("Details",\s*"Applications"',
    'Url\.Action\("Details",\s*"Jobs"'
)
foreach ($route in $requiredRoutes) {
    Assert-Contains $view $route "Required dashboard route is missing: $route"
}

Assert-Contains $css '\.candidate-overview-page' 'Candidate overview scoped styles are missing.'
Assert-Contains $css '\.candidate-activity-item:focus-visible' 'Application row focus state is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*991\.98px\)[\s\S]*\.candidate-overview-layout' 'Tablet dashboard layout is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*767\.98px\)[\s\S]*\.candidate-overview-metrics' 'Mobile metric layout is missing.'

Write-Output 'Candidate dashboard UI contract tests passed.'
