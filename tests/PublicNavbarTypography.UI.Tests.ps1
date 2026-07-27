$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Pattern, [string]$Message)
    if ($css -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains '/\* Public navigation typography \*/' 'Public navigation typography override is missing.'
Assert-Contains '\.public-navbar \.public-nav-list \.nav-link\s*\{[\s\S]*?font-size:\s*1rem' 'Navigation labels must be larger.'
Assert-Contains '\.public-navbar \.public-nav-list \.nav-link\s*\{[\s\S]*?text-transform:\s*uppercase' 'Navigation labels must be uppercase.'
Assert-Contains '\.public-navbar \.public-nav-list \.nav-link\.active[\s\S]*?background:\s*transparent' 'Active navigation must not use a green box.'
Assert-Contains '\.public-navbar \.public-nav-list \.nav-link\.active::after[\s\S]*?background:\s*var\(--ats-coral\)' 'Active navigation must retain the coral underline.'

Write-Output 'Public navbar typography tests passed.'
