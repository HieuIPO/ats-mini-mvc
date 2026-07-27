$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$viewPath = Join-Path $projectRoot 'ATSMiniProject\Views\Account\Login.cshtml'
$view = Get-Content -Raw -Encoding UTF8 -LiteralPath $viewPath

function Assert-NotContains {
    param(
        [string]$Pattern,
        [string]$Message
    )

    if ($view -match $Pattern) {
        throw $Message
    }
}

Assert-NotContains 'demo-account-note' 'Login page must not render the demo account note.'
Assert-NotContains 'Tài khoản ứng viên mẫu' 'Login page must not expose demo account guidance.'
Assert-NotContains 'ungvien01' 'Login page must not expose a demo username.'
Assert-NotContains '123456' 'Login page must not expose a demo password.'

Write-Output 'Login page UI tests passed.'
