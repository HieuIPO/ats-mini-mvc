$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$layoutPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_AdminLayout.cshtml'
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath
$layout = Get-Content -Raw -Encoding UTF8 -LiteralPath $layoutPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

$tableRule = [regex]::Match($css, '\.jobs-table\s*\{(?<body>[\s\S]*?)\}')
if (-not $tableRule.Success) {
    throw 'Jobs table style rule is missing.'
}

Assert-Contains $tableRule.Groups['body'].Value 'table-layout:\s*fixed' 'Long content must not change the jobs table column widths.'
Assert-Contains $tableRule.Groups['body'].Value 'width:\s*100%' 'The fixed jobs table must stay within its container.'

$titleRule = [regex]::Match($css, '\.jobs-table\s+\.job-title-link\s*\{(?<body>[\s\S]*?)\}')
if (-not $titleRule.Success) {
    throw 'Scoped job title link style rule is missing.'
}

$body = $titleRule.Groups['body'].Value
Assert-Contains $body 'overflow-wrap:\s*anywhere' 'A 150-character unbroken title must wrap inside its column.'
Assert-Contains $body 'word-break:\s*break-word' 'Long-title wrapping needs a browser fallback.'
Assert-Contains $body 'white-space:\s*normal' 'Job titles must be allowed to wrap onto multiple lines.'
Assert-Contains $body '-webkit-line-clamp:\s*3' 'Long job titles must be capped at three visible lines.'
Assert-Contains $body 'overflow:\s*hidden' 'Clamped job titles must not overlap adjacent columns.'
Assert-Contains $layout 'ats-ui-v2\.css\?v=20260727-1' 'Admin layout must force browsers to load the corrected jobs table CSS.'

Write-Output 'Admin jobs title wrapping UI tests passed.'
