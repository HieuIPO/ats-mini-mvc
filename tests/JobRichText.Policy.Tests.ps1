$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewModelPath = Join-Path $projectRoot 'ATSMiniProject\ViewModels\Jobs\JobFormViewModel.cs'
$controllerPath = Join-Path $projectRoot 'ATSMiniProject\Controllers\JobsController.cs'
$viewModel = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewModelPath
$controller = Get-Content -Raw -Encoding UTF8 -LiteralPath $controllerPath

function Assert-Contains {
    param([string]$Source, [string]$Pattern, [string]$Message)

    if ($Source -notmatch $Pattern) {
        throw $Message
    }
}

Assert-Contains $viewModel '\[AllowHtml\]\s*public\s+string\s+Description\s*\{' 'Description must explicitly allow editor HTML during MVC model binding.'
Assert-Contains $viewModel '\[AllowHtml\]\s*public\s+string\s+Requirements\s*\{' 'Requirements must explicitly allow editor HTML during MVC model binding.'
Assert-Contains $controller 'SanitizeRichTextFields\(model\);' 'Posted rich text must be sanitized before validation and persistence.'

if ($controller -match '\[ValidateInput\(false\)\]') {
    throw 'Request validation must not be disabled for the whole job action.'
}

Write-Output 'Job rich-text policy tests passed.'
