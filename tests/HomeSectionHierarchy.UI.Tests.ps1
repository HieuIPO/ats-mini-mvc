$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Home\Index.cshtml'
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)
    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $view 'class="process-section"' 'Application process section is missing.'
Assert-Contains $view 'class="process-flow"' 'Application process flow is missing.'
Assert-Contains $view 'class="featured-jobs-section"' 'Featured jobs section is missing.'
Assert-Contains $css '/\* Home process and jobs hierarchy \*/' 'Home section hierarchy override is missing.'
Assert-Contains $css '\.process-section \.process-card\s*\{[\s\S]*?border:\s*0' 'Process steps must no longer look like bordered cards.'
Assert-Contains $css '\.process-section \.process-flow::before' 'Connected process timeline is missing.'
Assert-Contains $css '\.featured-jobs-section\s*\{[\s\S]*?background:\s*#ffffff' 'Featured jobs must retain a distinct white surface.'
Assert-Contains $css '@media\s*\(max-width:\s*767\.98px\)[\s\S]*?\.process-section \.process-flow' 'Mobile process timeline is missing.'

Write-Output 'Home section visual hierarchy tests passed.'
