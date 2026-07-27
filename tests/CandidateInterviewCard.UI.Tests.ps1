$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Applications\Details.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

function Convert-FromUtf8Base64 {
    param([string]$Value)

    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

foreach ($className in @(
    'candidate-interview-card',
    'candidate-interview-card__date',
    'candidate-interview-card__content',
    'candidate-interview-card__action',
    'candidate-interview-state--upcoming',
    'candidate-interview-state--waiting',
    'candidate-interview-state--complete'
)) {
    Assert-Contains $view ([regex]::Escape($className)) "Interview card contract '$className' is missing."
}

foreach ($encodedText in @(
    'U+G6r3AgZGnhu4VuIHJh',
    'Q2jhu50gY+G6rXAgbmjhuq10IGvhur90IHF14bqj',
    'S+G6v3QgcXXhuqM6',
    'xJDhu4thIMSRaeG7g206'
)) {
    $expectedText = Convert-FromUtf8Base64 $encodedText
    if (-not $view.Contains($expectedText)) {
        throw "Interview card text '$expectedText' is missing."
    }
}

Assert-Contains $view '<time[^>]+datetime=' 'Interview date must use a semantic time element.'
Assert-Contains $view 'ToString\("dd/MM/yyyy"\)' 'Interview card must show the full date.'
Assert-Contains $view 'CanAddToCalendar' 'Calendar visibility contract is missing.'
Assert-Contains $view 'DownloadInterviewCalendar' 'Calendar download route must be preserved.'

Assert-Contains $css '\.candidate-interview-card\s*\{' 'Interview card styles are missing.'
Assert-Contains $css 'grid-template-columns:\s*5rem\s+minmax\(0,\s*1fr\)\s+auto' 'Desktop interview card grid is missing.'
Assert-Contains $css '@media\s*\(max-width:\s*575\.98px\)' 'Mobile breakpoint is missing.'

Write-Output 'Candidate interview card UI tests passed.'
