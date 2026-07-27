$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\ApplicationsController.cs'
$controller = Get-Content -Raw -Encoding UTF8 -LiteralPath $controllerPath

function Assert-Contains {
    param([string]$Pattern, [string]$Message)

    if ($controller -notmatch $Pattern) {
        throw $Message
    }
}

function Convert-FromUtf8Base64 {
    param([string]$Value)

    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

Assert-Contains 'j\.IsActive\s*&&\s*\(!j\.Deadline\.HasValue\s*\|\|\s*j\.Deadline\.Value\s*>=\s*today\)' 'Open jobs must be determined by active state and deadline.'
Assert-Contains 'new\s*\{\s*j\.JobID,\s*j\.Title,\s*j\.IsActive,\s*j\.Deadline\s*\}' 'Job filter projection must include status fields.'

$statusLabels = @(
    '8J+foiDEkGFuZyB0dXnhu4Nu',
    '8J+UtCDEkMOjIMSRw7NuZw==',
    '8J+foCBI4bq/dCBo4bqhbg=='
) | ForEach-Object { Convert-FromUtf8Base64 $_ }

foreach ($label in $statusLabels) {
    if (-not $controller.Contains($label)) {
        throw "Job filter status label '$label' is missing."
    }
}

Write-Output 'Application job filter status policy tests passed.'
