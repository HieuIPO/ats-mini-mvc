$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_Navbar.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)
    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view '<details class="candidate-account-menu"' 'Candidate account menu container is missing.'
Assert-Contains $view '<summary class="candidate-user candidate-user-trigger"' 'Candidate identity trigger is missing.'
Assert-Contains $view 'class="candidate-account-popover"' 'Candidate account popover is missing.'
Assert-Contains $view 'Html\.BeginForm\("Logout",\s*"Account",\s*FormMethod\.Post' 'Logout must remain a POST form.'
Assert-Contains $view '@Html\.AntiForgeryToken\(\)' 'Logout anti-forgery token is missing.'

if ($view -match 'returnUrl\s*=\s*Url\.Action\("Status",\s*"Applications"\)') {
    throw 'Guest navigation must not include the application tracking link.'
}

$jobsIndex = $view.IndexOf('href="@Url.Action("Index", "Jobs")"')
$overviewIndex = $view.IndexOf('href="@Url.Action("Index", "Candidate")"')
if ($jobsIndex -lt 0 -or $overviewIndex -lt 0 -or $overviewIndex -le $jobsIndex) {
    throw 'Candidate overview must appear after Jobs at the end of the main navigation.'
}

$applicationRouteCount = ([regex]::Matches($view, 'href="@Url\.Action\("Status",\s*"Applications"\)"')).Count
$profileRouteCount = ([regex]::Matches($view, 'href="@Url\.Action\("Profile",\s*"Candidate"\)"')).Count
if ($applicationRouteCount -ne 1) {
    throw "Application profile route must appear once inside the account menu; found $applicationRouteCount."
}
if ($profileRouteCount -ne 1) {
    throw "Candidate profile route must appear once inside the account menu; found $profileRouteCount."
}

Assert-Contains $css '\.candidate-account-menu\[open\]\s+\.candidate-account-popover' 'Click-open account menu behavior is missing.'
Assert-Contains $css '\.candidate-user-trigger:focus-visible' 'Candidate menu trigger focus style is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*991\.98px\)[\s\S]*\.candidate-account-menu' 'Candidate menu mobile layout is missing.'

Write-Output 'Candidate navbar account menu contract tests passed.'
