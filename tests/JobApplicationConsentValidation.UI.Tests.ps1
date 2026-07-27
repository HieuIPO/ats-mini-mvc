$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Jobs\Apply.cshtml'
$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath

function Assert-Contains {
    param([string]$Pattern, [string]$Message)

    if ($view -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains 'ViewData\.ModelState\[string\.Empty\]' 'The view must inspect model-level errors before rendering the summary.'
Assert-Contains 'generalErrors\.Errors\.Count\s*>\s*0' 'The general error summary must only render when it has content.'
Assert-Contains 'ValidationSummary\(true' 'Model-level errors must remain visible.'
Assert-Contains 'ValidationMessageFor\(\s*model\s*=>\s*model\.AcceptPrivacyPolicy' 'Consent validation must remain beside the checkbox.'
Assert-Contains 'id\s*=\s*"privacy-consent-error"' 'Consent error must keep its accessible description id.'

Write-Output 'Job application consent validation UI tests passed.'
