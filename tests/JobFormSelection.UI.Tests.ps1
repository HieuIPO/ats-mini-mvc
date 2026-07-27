$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Jobs\_Form.cshtml'
$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath

function Assert-Contains {
    param([string]$Pattern, [string]$Message)

    if ($view -notmatch $Pattern) {
        throw $Message
    }
}

function Convert-FromUtf8Base64 {
    param([string]$Value)

    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

Assert-Contains 'DropDownListFor\(m => m\.JobType' 'JobType must be rendered as a dropdown.'

if ($view -match 'TextBoxFor\(m => m\.JobType') {
    throw 'JobType must no longer be a free-text input.'
}

$jobTypes = @(
    'VG/DoG4gdGjhu51pIGdpYW4=',
    'QsOhbiB0aOG7nWkgZ2lhbg==',
    'VGjhu7FjIHThuq1w',
    'SOG7o3AgxJHhu5NuZw=='
) | ForEach-Object { Convert-FromUtf8Base64 $_ }

foreach ($jobType in $jobTypes) {
    Assert-Contains ([regex]::Escape($jobType)) "JobType option '$jobType' is missing."
}

Assert-Contains 'TextBoxFor\(m => m\.Industry' 'Industry must remain a free-text input.'
Assert-Contains 'list\s*=\s*"industry-suggestions"' 'Industry input must reference its suggestion list.'
Assert-Contains '<datalist\s+id="industry-suggestions"' 'Industry datalist is missing.'

$industries = @(
    'Q8O0bmcgbmdo4buHIHRow7RuZyB0aW4=',
    'S2luaCBkb2FuaA==',
    'TWFya2V0aW5n',
    'TmjDom4gc+G7sQ==',
    'VMOgaSBjaMOtbmggLSBL4bq/IHRvw6Fu',
    'VGhp4bq/dCBr4bq/',
    'VuG6rW4gaMOgbmg='
) | ForEach-Object { Convert-FromUtf8Base64 $_ }

foreach ($industry in $industries) {
    Assert-Contains ([regex]::Escape($industry)) "Industry suggestion '$industry' is missing."
}

Write-Output 'Job form selection UI tests passed.'
