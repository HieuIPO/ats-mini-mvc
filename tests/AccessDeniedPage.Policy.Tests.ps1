$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Account\AccessDenied.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\access-denied.css'
$imagePath = Join-Path $projectRoot 'ATSMiniProject\Content\images\errors\access-denied-door.png'
$projectPath = Join-Path $projectRoot 'ATSMiniProject\ATSMiniProject.csproj'

if (-not (Test-Path -LiteralPath $viewPath)) {
    throw "Missing access denied view: $viewPath"
}

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$project = Get-Content -Raw -Encoding UTF8 -LiteralPath $projectPath

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

function Assert-NotContains {
    param(
        [string]$Source,
        [string]$Pattern,
        [string]$Message
    )

    if ($Source -match $Pattern) {
        throw $Message
    }
}

function TextFromCodePoints {
    param([int[]]$CodePoints)

    return -join ($CodePoints | ForEach-Object { [char]$_ })
}

$approvedHeadline = TextFromCodePoints @(66,7841,110,32,99,104,432,97,32,116,104,7875,32,109,7903,32,116,114,97,110,103,32,110,224,121)
$approvedMessage = TextFromCodePoints @(84,224,105,32,107,104,111,7843,110,32,104,105,7879,110,32,116,7841,105,32,99,104,432,97,32,99,243,32,118,97,105,32,116,114,242,32,112,104,249,32,104,7907,112,32,273,7875,32,116,114,117,121,32,99,7853,112,32,99,104,7913,99,32,110,259,110,103,32,110,224,121,46,32,66,7841,110,32,99,243,32,116,104,7875,32,113,117,97,121,32,118,7873,32,107,104,117,32,118,7921,99,32,97,110,32,116,111,224,110,32,104,111,7863,99,32,273,259,110,103,32,110,104,7853,112,32,98,7857,110,103,32,116,224,105,32,107,104,111,7843,110,32,107,104,225,99,46)
$approvedPrimary = TextFromCodePoints @(86,7873,32,116,114,97,110,103,32,112,104,249,32,104,7907,112)
$approvedSecondary = TextFromCodePoints @(272,259,110,103,32,110,104,7853,112,32,116,224,105,32,107,104,111,7843,110,32,107,104,225,99)
$blockedPathLabel = TextFromCodePoints @(272,432,7901,110,103,32,100,7851,110)

Assert-Contains $view 'Layout\s*=\s*null' 'Access denied page must be standalone without the public/admin layout.'
Assert-Contains $view '<main\s+class="access-denied-page"' 'Access denied page must expose a semantic main region.'
Assert-Contains $view 'class="access-denied-copy"' 'Text column must be on the left.'
Assert-Contains $view 'class="access-denied-visual"' 'Illustration column must be on the right.'
Assert-Contains $view '403' 'Approved status code copy is missing.'
Assert-Contains $view ([regex]::Escape($approvedHeadline)) 'Approved headline copy is missing.'
Assert-Contains $view ([regex]::Escape($approvedMessage)) 'Approved guidance copy is missing.'
Assert-Contains $view ([regex]::Escape($approvedPrimary)) 'Approved primary action copy is missing.'
Assert-Contains $view ([regex]::Escape($approvedSecondary)) 'Approved secondary action copy is missing.'
Assert-Contains $view 'Url\.Action\("Index",\s*"Dashboard"\)' 'Back-office users must be sent to Dashboard.'
Assert-Contains $view 'Url\.Action\("Index",\s*"Home"\)' 'Other users must be sent to public home.'
Assert-Contains $view 'Url\.Action\("Login",\s*"Account"\)' 'Secondary action must sign in with another account.'
Assert-Contains $view 'access-denied-door\.png' 'Door illustration asset must be rendered.'
Assert-Contains $view 'alt=""\s+aria-hidden="true"' 'Decorative illustration must be hidden from assistive technology.'
Assert-Contains $view 'Content/css/access-denied\.css' 'Page must load dedicated access denied CSS.'

Assert-NotContains $view 'ReturnUrl|returnUrl|ViewBag\.ReturnUrl' 'Blocked/requested URL must not be read or rendered by the view.'
Assert-NotContains $view ([regex]::Escape($blockedPathLabel) + '|duong dan|blocked|bị chặn|bi chan') 'Blocked/requested URL copy must be removed from the UI.'

$copyIndex = $view.IndexOf('class="access-denied-copy"')
$visualIndex = $view.IndexOf('class="access-denied-visual"')
if ($copyIndex -lt 0 -or $visualIndex -lt 0 -or $copyIndex -gt $visualIndex) {
    throw 'Desktop layout contract is text on the left, illustration on the right.'
}

if (-not (Test-Path -LiteralPath $cssPath)) {
    throw "Missing dedicated CSS: $cssPath"
}

if (-not (Test-Path -LiteralPath $imagePath)) {
    throw "Missing door illustration asset: $imagePath"
}

$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath
Assert-Contains $css 'grid-template-columns:\s*minmax\(0,\s*1fr\)\s+minmax\(20rem,\s*0\.86fr\)' 'Desktop two-column layout must keep text left and image right.'
Assert-Contains $css '@media\s*\(max-width:\s*767\.98px\)' 'Mobile breakpoint must stack the page.'
Assert-Contains $css 'grid-template-columns:\s*1fr' 'Mobile layout must use one column.'
Assert-Contains $css 'width:\s*100%' 'Mobile actions must be able to span full width.'

Assert-Contains $project 'Content\\css\\access-denied\.css' 'Project file must include access denied CSS.'
Assert-Contains $project 'Content\\images\\errors\\access-denied-door\.png' 'Project file must include door illustration.'

Write-Output 'Access denied page policy checks passed.'
