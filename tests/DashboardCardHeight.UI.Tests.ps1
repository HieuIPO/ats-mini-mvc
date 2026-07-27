$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)
    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains `
    $css `
    '\.dashboard-detail-grid\s*\{[^}]*align-items:\s*start' `
    'Dashboard detail cards must align to the start instead of stretching to equal height.'

Assert-Contains `
    $css `
    '\.dashboard-detail-grid\s*>\s*\.dashboard-card\s*,\s*\.dashboard-activity-card\s*\{[^}]*min-height:\s*0' `
    'Dashboard interview and activity cards must opt out of the shared 100% minimum height.'

Write-Output 'Dashboard card height UI contract tests passed.'
