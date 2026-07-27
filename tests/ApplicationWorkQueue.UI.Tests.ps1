$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\ApplicationsController.cs'
$modelPath = Join-Path $projectRoot 'ATSMiniProject\ViewModels\Applications\AdminApplicationViewModels.cs'
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Applications\Index.cshtml'
$stylePath = Join-Path $projectRoot 'ATSMiniProject\Content\css\ats-ui-v2.css'

$controller = Get-Content -Raw -LiteralPath $controllerPath
$model = Get-Content -Raw -LiteralPath $modelPath
$view = Get-Content -Raw -LiteralPath $viewPath
$styles = Get-Content -Raw -LiteralPath $stylePath

foreach ($fragment in @(
    'string queue = "attention"',
    'NormalizeQueue(queue)',
    'queue == "attention"',
    'queue == "new"',
    'queue == "review"',
    'queue == "interview"',
    'queue == "final"',
    'a.ApplicationStatus.IsFinal',
    'ThenBy(a => a.AppliedDate)',
    'DbFunctions.DiffDays(a.AppliedDate, now)'
)) {
    if (-not $controller.Contains($fragment)) {
        throw "Application queue controller contract is missing: $fragment"
    }
}

foreach ($fragment in @(
    'public string Queue { get; set; }',
    'public int AttentionCount { get; set; }',
    'public int NewCount { get; set; }',
    'public int ReviewingCount { get; set; }',
    'public int InterviewCount { get; set; }',
    'public int FinalCount { get; set; }',
    'public int WaitingDays { get; set; }'
)) {
    if (-not $model.Contains($fragment)) {
        throw "Application queue view model contract is missing: $fragment"
    }
}

foreach ($fragment in @(
    'class="application-queue-tabs"',
    'queueUrl("attention")',
    'queueUrl("new")',
    'queueUrl("review")',
    'queueUrl("interview")',
    'queueUrl("final")',
    'queueUrl("all")',
    'class="application-ops-filter-grid"',
    'class="application-wait-cell"',
    'class="application-next-action"',
    'application-new-indicator',
    'application-wait-warning',
    'queue = Model.Queue',
    'aria-current',
    '@item.CandidateEmail',
    '@item.CandidatePhone'
)) {
    if (-not $view.Contains($fragment)) {
        throw "Application queue view contract is missing: $fragment"
    }
}

foreach ($fragment in @(
    '.application-queue-tabs',
    '.application-queue-tab',
    '.application-ops-filter-grid',
    '.application-ops-contact',
    '.application-new-indicator',
    '.application-wait-warning',
    '.application-next-action'
)) {
    if (-not $styles.Contains($fragment)) {
        throw "Application queue styles are missing: $fragment"
    }
}

Write-Output 'Application work queue UI contract checks passed.'
