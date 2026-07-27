$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$createView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Admin\UserCreate.cshtml')
$editView = Get-Content -Raw (Join-Path $projectRoot 'ATSMiniProject\Views\Admin\UserEdit.cshtml')

function Assert-Contains($Content, $Pattern, $Message) {
    if ($Content -notmatch $Pattern) {
        throw $Message
    }
}

foreach ($case in @(
    @{ Name = 'create'; Content = $createView },
    @{ Name = 'edit'; Content = $editView }
)) {
    Assert-Contains $case.Content 'ViewData\.ModelState\[string\.Empty\]' "The $($case.Name) account view must inspect form-level errors before rendering the summary."
    Assert-Contains $case.Content 'formErrors\s*!=\s*null\s*&&\s*formErrors\.Errors\.Count\s*>\s*0' "The $($case.Name) account view must only render the summary when form-level errors exist."
    Assert-Contains $case.Content 'ValidationSummary\(true' "The $($case.Name) account view must keep model-level validation messages visible."
}

Write-Output 'Admin account validation summary UI tests passed.'
