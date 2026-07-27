$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_AdminTopbar.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)
    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view '<details class="admin-account-menu"' 'Accessible account menu container is missing.'
Assert-Contains $view '<summary class="admin-user-chip"' 'Account menu trigger is missing.'
Assert-Contains $view 'class="admin-account-popover"' 'Account menu popover is missing.'
Assert-Contains $view 'Url\.Action\("Profile",\s*"Account"\)' 'Profile menu destination is missing.'
Assert-Contains $view 'Html\.BeginForm\("Logout",\s*"Account",\s*FormMethod\.Post' 'Logout POST form contract is missing.'
Assert-Contains $view '@Html\.AntiForgeryToken\(\)' 'Logout anti-forgery token is missing.'
Assert-Contains $css '\.admin-account-menu:hover\s+\.admin-account-popover' 'Hover menu behavior is missing.'
Assert-Contains $css '\.admin-account-menu:focus-within\s+\.admin-account-popover' 'Keyboard focus menu behavior is missing.'
Assert-Contains $css '\.admin-account-menu\[open\]\s+\.admin-account-popover' 'Click-open menu behavior is missing.'

Write-Output 'Admin topbar account menu contract tests passed.'
