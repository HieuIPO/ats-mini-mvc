$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\AccountController.cs'
$source = Get-Content -Raw -Encoding UTF8 -LiteralPath $controllerPath

$methodMatch = [regex]::Match(
    $source,
    'private\s+ActionResult\s+RedirectAfterLogin\s*\(string\s+returnUrl\)\s*\{(?<body>[\s\S]*?)\n\s{8}\}',
    [System.Text.RegularExpressions.RegexOptions]::Multiline
)

if (-not $methodMatch.Success) {
    throw 'RedirectAfterLogin method was not found.'
}

$body = $methodMatch.Groups['body'].Value
$roleIndex = $body.IndexOf('Session[AuthSessionKeys.RoleName]')
$internalRoleIndex = $body.IndexOf('InternalAccountRolePolicy.IsAllowedRoleName')
$localUrlIndex = $body.IndexOf('Url.IsLocalUrl(returnUrl)')
$dashboardIndex = $body.IndexOf('RedirectToAction("Index", "Dashboard")')

if ($roleIndex -lt 0 -or $internalRoleIndex -lt 0 -or $localUrlIndex -lt 0 -or $dashboardIndex -lt 0) {
    throw 'RedirectAfterLogin must contain role, internal-account, local-return-url, and Dashboard checks.'
}

if ($roleIndex -gt $localUrlIndex -or $internalRoleIndex -gt $localUrlIndex -or $dashboardIndex -gt $localUrlIndex) {
    throw 'Admin/HR must be redirected to Dashboard before any public local returnUrl is honored.'
}

Write-Output 'Account login redirect policy tests passed.'
