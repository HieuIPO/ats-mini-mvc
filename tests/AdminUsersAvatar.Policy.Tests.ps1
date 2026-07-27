$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$controller = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $projectRoot 'ATSMiniProject\Controllers\AdminController.cs')
$viewModel = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $projectRoot 'ATSMiniProject\ViewModels\Admin\UserManagementViewModels.cs')
$view = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $projectRoot 'ATSMiniProject\Views\Admin\Users.cshtml')
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css')

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $viewModel 'public\s+string\s+AvatarUrl\s*\{' 'User list view model must expose AvatarUrl.'
Assert-Contains $controller 'AccountAvatarPathResolver\.FindLatestFileName' 'Admin user list must resolve stored avatar files.'
Assert-Contains $controller 'user\.AvatarUrl\s*=' 'Admin user list must populate AvatarUrl after the database query.'
Assert-Contains $view '!string\.IsNullOrWhiteSpace\(user\.AvatarUrl\)' 'User row must branch on AvatarUrl.'
Assert-Contains $view '<img[^>]+account-user-avatar' 'User row must render an avatar image.'
Assert-Contains $view 'Url\.Content\(user\.AvatarUrl\)' 'User avatar must use the resolved local URL.'
Assert-Contains $view '<span[^>]+account-user-initial' 'User row must retain the initial fallback.'
Assert-Contains $css '\.account-user-avatar' 'Admin user avatar image styles are missing.'

Write-Output 'Admin users avatar policy tests passed.'
