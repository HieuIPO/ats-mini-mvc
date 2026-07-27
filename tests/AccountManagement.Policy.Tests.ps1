$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$policyPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\InternalAccountRolePolicy.cs'

if (-not (Test-Path -LiteralPath $policyPath)) {
    throw "Missing internal account role policy: $policyPath"
}

$source = Get-Content -Raw -LiteralPath $policyPath
Add-Type -TypeDefinition $source -Language CSharp

$cases = @(
    @{ Role = 'Admin'; Expected = $true },
    @{ Role = 'HR'; Expected = $true },
    @{ Role = 'Candidate'; Expected = $false },
    @{ Role = ''; Expected = $false },
    @{ Role = $null; Expected = $false },
    @{ Role = 'SuperAdmin'; Expected = $false }
)

foreach ($case in $cases) {
    $actual = [ATSMiniProject.Helpers.InternalAccountRolePolicy]::IsAllowedRoleName($case.Role)
    if ($actual -ne $case.Expected) {
        throw "Role policy failed for '$($case.Role)': expected $($case.Expected), got $actual."
    }
}

Write-Output 'Account role policy tests passed: 6/6.'
