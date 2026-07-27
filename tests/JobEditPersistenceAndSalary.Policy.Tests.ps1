$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\JobsController.cs'
$viewModelPath = Join-Path $projectRoot 'ATSMiniProject\ViewModels\Jobs\JobFormViewModel.cs'
$formPath = Join-Path $projectRoot 'ATSMiniProject\Views\Jobs\_Form.cshtml'
$policyPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\SalaryRangePolicy.cs'

$controller = Get-Content -Raw -Encoding UTF8 -LiteralPath $controllerPath
$viewModel = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewModelPath
$form = Get-Content -Raw -Encoding UTF8 -LiteralPath $formPath

foreach ($fragment in @(
    'ViewBag.DepartmentOptions = BuildDepartmentItems(departmentId);',
    'ViewBag.JobPositionOptions = BuildJobPositionItems(jobPositionId);',
    'd.DepartmentID == selectedId.Value',
    'p.JobPositionID == selectedId.Value',
    'ValidateSalaryRange(model);',
    'SalaryRangePolicy.TryNormalize'
)) {
    if (-not $controller.Contains($fragment)) {
        throw "JobsController is missing edit persistence or salary validation: $fragment"
    }
}

foreach ($fragment in @(
    '(IEnumerable<SelectListItem>)ViewBag.DepartmentOptions',
    '(IEnumerable<SelectListItem>)ViewBag.JobPositionOptions',
    'type = "text"',
    'inputmode = "numeric"',
    'Html.ValidationMessageFor(m => m.SalaryRange'
)) {
    if (-not $form.Contains($fragment)) {
        throw "Job form is missing a selection or salary input contract: $fragment"
    }
}

if ($viewModel -notmatch '(?s)\[AllowHtml\]\s*public\s+string\s+SalaryRange\s*\{') {
    throw 'SalaryRange must allow model binding so malicious HTML receives a validation error instead of HTTP 500.'
}

if ($controller -match '\[ValidateInput\(false\)\]') {
    throw 'Request validation must not be disabled for the whole job action.'
}

if (-not (Test-Path -LiteralPath $policyPath)) {
    throw "Missing salary range policy: $policyPath"
}

$policySource = Get-Content -Raw -Encoding UTF8 -LiteralPath $policyPath
Add-Type -TypeDefinition $policySource -Language CSharp -ReferencedAssemblies @('System.dll', 'System.Core.dll')

$vnd = 'VN' + [char]272
$million = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('dHJp4buHdQ=='))
$negotiable = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('VGjhu49hIHRodeG6rW4='))

$validCases = @(
    @{ Input = '1'; Expected = "1 $vnd" },
    @{ Input = '12000000'; Expected = "12.000.000 $vnd" },
    @{ Input = "12.000.000 - 18.000.000 $vnd"; Expected = "12.000.000 - 18.000.000 $vnd" },
    @{ Input = "8 - 15 $million"; Expected = "8.000.000 - 15.000.000 $vnd" },
    @{ Input = $negotiable; Expected = $null }
)

foreach ($case in $validCases) {
    $normalized = $null
    $errorMessage = $null
    $valid = [ATSMiniProject.Helpers.SalaryRangePolicy]::TryNormalize(
        $case.Input,
        [ref]$normalized,
        [ref]$errorMessage)

    if (-not $valid -or $normalized -ne $case.Expected) {
        throw "Expected salary '$($case.Input)' => '$($case.Expected)', got valid=$valid normalized='$normalized' error='$errorMessage'."
    }
}

foreach ($invalid in @('0', '-1', '10 - 0', '20 - 10', '<b>100</b>', '100<script>alert(1)</script>', 'abc')) {
    $normalized = $null
    $errorMessage = $null
    $valid = [ATSMiniProject.Helpers.SalaryRangePolicy]::TryNormalize(
        $invalid,
        [ref]$normalized,
        [ref]$errorMessage)

    if ($valid -or [string]::IsNullOrWhiteSpace($errorMessage)) {
        throw "Salary '$invalid' must be rejected with a friendly validation error."
    }
}

Write-Output 'Job edit persistence and salary policy tests passed.'
