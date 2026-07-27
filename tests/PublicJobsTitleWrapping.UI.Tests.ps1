$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$layoutPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_Layout.cshtml'
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath
$layout = Get-Content -Raw -Encoding UTF8 -LiteralPath $layoutPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $css '\.career-job-main\s*\{[\s\S]*?min-width:\s*0' 'Public job content must be allowed to shrink inside the grid.'

$titleRule = [regex]::Match($css, '\.career-job-item\s+h2\s+a\s*\{(?<body>[\s\S]*?)\}')
if (-not $titleRule.Success) {
    throw 'Public job title link style rule is missing.'
}

$body = $titleRule.Groups['body'].Value
Assert-Contains $body 'overflow-wrap:\s*anywhere' 'A 150-character public job title must wrap inside its card.'
Assert-Contains $body 'word-break:\s*break-word' 'Public job title wrapping needs a browser fallback.'
Assert-Contains $body 'white-space:\s*normal' 'Public job titles must be allowed to wrap.'
Assert-Contains $body '-webkit-line-clamp:\s*3' 'Public job titles must be capped at three visible lines.'
Assert-Contains $body 'overflow:\s*hidden' 'Public job titles must not overlap the detail action.'
Assert-Contains $layout 'ats-ui-v2\.css\?v=20260727-3' 'Public layout must force browsers to load the corrected title CSS.'

Write-Output 'Public jobs title wrapping UI tests passed.'
