$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Candidate\Profile.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view 'Html\.BeginForm\(\s*"UploadAvatar",\s*"Candidate"' 'Avatar upload form contract is missing.'
Assert-Contains $view 'Html\.BeginForm\(\s*"RemoveAvatar",\s*"Candidate"' 'Avatar removal form contract is missing.'
Assert-Contains $view 'Html\.BeginForm\(\s*"Profile",\s*"Candidate"' 'Contact profile form contract is missing.'
Assert-Contains $view 'Html\.BeginForm\(\s*"ChangePassword",\s*"Candidate"' 'Password form contract is missing.'
Assert-Contains $view 'enctype\s*=\s*"multipart/form-data"' 'Avatar upload must remain multipart.'

$antiForgeryCount = ([regex]::Matches($view, '@Html\.AntiForgeryToken\(\)')).Count
if ($antiForgeryCount -lt 4) {
    throw "Expected four anti-forgery tokens, found $antiForgeryCount."
}

foreach ($hook in @('data-avatar-input', 'data-avatar-preview', 'data-avatar-fallback', 'data-avatar-file-name')) {
    Assert-Contains $view ([regex]::Escape($hook)) "Avatar preview hook '$hook' is missing."
}

foreach ($className in @(
    'account-profile-hero',
    'account-profile-grid',
    'account-profile-identity',
    'account-profile-contact',
    'account-profile-security'
)) {
    Assert-Contains $view ([regex]::Escape($className)) "Approved profile structure '$className' is missing."
}

Assert-Contains $css '\.account-profile-grid\s*\{' 'Profile grid styles are missing.'
Assert-Contains $css 'grid-template-columns:\s*minmax\(0,\s*20rem\)\s+minmax\(0,\s*1fr\)' 'Profile desktop grid contract is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*899\.98px\)' 'Profile tablet breakpoint is missing.'
Assert-Contains $css '@media\s*\(prefers-reduced-motion:\s*reduce\)' 'Reduced-motion handling is missing.'

Write-Output 'Candidate profile page UI contract tests passed.'
