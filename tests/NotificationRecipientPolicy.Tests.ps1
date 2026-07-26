$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$policyPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\NotificationRecipientPolicy.cs'

if (-not (Test-Path -LiteralPath $policyPath)) {
    throw "Missing notification recipient policy: $policyPath"
}

$source = Get-Content -Raw -LiteralPath $policyPath
Add-Type -TypeDefinition $source -Language CSharp

$creator = [Nullable[int]]42
$admins = [int[]](1, 2, 2)

$creatorResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($creator, $true, $admins)
if (($creatorResult -join ',') -ne '42') {
    throw "Eligible creator should be the only recipient. Got: $($creatorResult -join ',')"
}

$fallbackResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($creator, $false, $admins)
if (($fallbackResult -join ',') -ne '1,2') {
    throw "Inactive creator should fall back to distinct Admin IDs. Got: $($fallbackResult -join ',')"
}

$missingResult = [ATSMiniProject.Helpers.NotificationRecipientPolicy]::Resolve($null, $false, [int[]]@())
if ($missingResult.Count -ne 0) {
    throw 'Missing creator and Admins should produce no recipients.'
}

Write-Output 'Notification recipient policy tests passed: 3/3.'
