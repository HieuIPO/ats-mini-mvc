$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Account\Profile.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param(
        [string]$Source,
        [string]$Pattern,
        [string]$Message
    )

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view 'Html\.BeginForm\("Profile",\s*"Account",\s*FormMethod\.Post' 'Profile POST form contract is missing.'
Assert-Contains $view 'multipart/form-data' 'Profile form must preserve multipart upload encoding.'
Assert-Contains $view '@Html\.AntiForgeryToken\(\)' 'Profile form must preserve the anti-forgery token.'
Assert-Contains $view '@Html\.HiddenFor\(m => m\.(Username|RoleName|AvatarPath)\)' 'Profile form must preserve hidden account values.'
Assert-Contains $view 'class="profile-page-shell"' 'Profile page shell is missing.'
Assert-Contains $view 'class="profile-breadcrumb"' 'Accessible profile breadcrumb is missing.'
Assert-Contains $view 'class="profile-role-badge"' 'Profile role badge is missing.'
Assert-Contains $view 'class="profile-contact-row"' 'Separate profile contact rows are missing.'
Assert-Contains $view 'class="profile-avatar-action"' 'Clickable avatar upload trigger is missing.'
Assert-Contains $view 'for="AvatarFile"' 'Avatar trigger must be linked to the native file input.'
Assert-Contains $view 'id="AvatarFile"\s+name="AvatarFile"' 'Native AvatarFile input contract is missing.'
Assert-Contains $view 'data-profile-avatar-image' 'Selected avatar preview image contract is missing.'
Assert-Contains $view 'data-avatar-selection' 'Compact selected-file feedback is missing.'
if ($view -match 'class="profile-upload-zone') {
    throw 'The large avatar upload zone must be removed.'
}
Assert-Contains $view 'data-profile-submit' 'Duplicate-submit prevention hook is missing.'
Assert-Contains $view 'data-profile-submit-label' 'Submit loading copy hook is missing.'

$cancelIndex = $view.IndexOf('data-profile-cancel')
$saveIndex = $view.IndexOf('data-profile-submit')
if ($cancelIndex -lt 0 -or $saveIndex -lt 0 -or $cancelIndex -gt $saveIndex) {
    throw 'Cancel action must appear before the save action.'
}

Assert-Contains $css '\.profile-page-shell' 'Profile page-scoped styles are missing.'
Assert-Contains $css 'grid-template-columns:\s*minmax\(20rem,\s*21rem\)\s+minmax\(0,\s*1fr\)' 'Desktop profile grid contract is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*899\.98px\)' 'Profile responsive breakpoint is missing.'
Assert-Contains $css '\.profile-avatar-action:focus-visible' 'Avatar trigger keyboard focus style is missing.'

Write-Output 'Profile page UI contract tests passed.'
