$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$cssPath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'
$layoutPath = Join-Path $projectRoot 'ATSMiniProject\Views\Shared\_Layout.cshtml'
$css = Get-Content -Raw -Encoding UTF8 -LiteralPath $cssPath
$layout = Get-Content -Raw -Encoding UTF8 -LiteralPath $layoutPath

function Assert-RuleContains {
    param([string]$Selector, [string[]]$Patterns, [string]$Message)

    $rule = [regex]::Match($css, [regex]::Escape($Selector) + '\s*\{(?<body>[\s\S]*?)\}')
    if (-not $rule.Success) {
        throw "$Message Rule '$Selector' is missing."
    }

    foreach ($pattern in $Patterns) {
        if ($rule.Groups['body'].Value -notmatch $pattern) {
            throw "$Message Missing '$pattern' in '$Selector'."
        }
    }
}

$safeTitlePatterns = @(
    'max-width:\s*100%',
    'overflow:\s*hidden',
    'overflow-wrap:\s*anywhere',
    'word-break:\s*break-word',
    'white-space:\s*normal',
    '-webkit-box-orient:\s*vertical',
    '-webkit-line-clamp:\s*3'
)

Assert-RuleContains '.career-detail-heading h1' $safeTitlePatterns 'Job detail hero title can overflow.'
Assert-RuleContains '.career-apply-card > h2' $safeTitlePatterns 'Job detail sidebar title can overflow.'
Assert-RuleContains '.career-application-heading p' $safeTitlePatterns 'Application hero job title can overflow.'
Assert-RuleContains '.career-application-summary h2' $safeTitlePatterns 'Application summary title can overflow.'

if ($layout -notmatch 'ats-ui-v2\.css\?v=20260727-3') {
    throw 'Public layout must force browsers to load all corrected long-title rules.'
}

Write-Output 'Job long-title surface UI tests passed.'
