$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$resolverPath = Join-Path $projectRoot 'ATSMiniProject\Helpers\AccountAvatarPathResolver.cs'

if (-not (Test-Path -LiteralPath $resolverPath)) {
    throw "Missing account avatar path resolver: $resolverPath"
}

$source = Get-Content -Raw -Encoding UTF8 -LiteralPath $resolverPath
Add-Type -TypeDefinition $source -Language CSharp

$temporaryFolder = Join-Path ([System.IO.Path]::GetTempPath()) ('ats-avatar-persistence-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporaryFolder | Out-Null

try {
    $older = Join-Path $temporaryFolder 'avatar-7-20260101090000.jpg'
    $latest = Join-Path $temporaryFolder 'avatar-7-20260201100000.png'
    $otherUser = Join-Path $temporaryFolder 'avatar-8-20260301100000.jpg'
    $candidateAvatar = Join-Path $temporaryFolder 'candidate-9.jpg'
    $invalid = Join-Path $temporaryFolder 'avatar-7-20260401100000.exe'
    $invalidCandidate = Join-Path $temporaryFolder 'candidate-10.exe'

    [System.IO.File]::WriteAllText($older, 'older')
    [System.IO.File]::WriteAllText($latest, 'latest')
    [System.IO.File]::WriteAllText($otherUser, 'other-user')
    [System.IO.File]::WriteAllText($candidateAvatar, 'candidate-avatar')
    [System.IO.File]::WriteAllText($invalid, 'invalid-extension')
    [System.IO.File]::WriteAllText($invalidCandidate, 'invalid-candidate-extension')

    [System.IO.File]::SetLastWriteTimeUtc($older, [DateTime]::UtcNow.AddMinutes(-4))
    [System.IO.File]::SetLastWriteTimeUtc($latest, [DateTime]::UtcNow.AddMinutes(-3))
    [System.IO.File]::SetLastWriteTimeUtc($otherUser, [DateTime]::UtcNow.AddMinutes(-2))
    [System.IO.File]::SetLastWriteTimeUtc($invalid, [DateTime]::UtcNow.AddMinutes(-1))

    $actual = [ATSMiniProject.Helpers.AccountAvatarPathResolver]::FindLatestFileName($temporaryFolder, 7)
    if ($actual -ne 'avatar-7-20260201100000.png') {
        throw "Expected the latest valid avatar for user 7, got '$actual'."
    }

    $candidateActual = [ATSMiniProject.Helpers.AccountAvatarPathResolver]::FindLatestFileName($temporaryFolder, 9)
    if ($candidateActual -ne 'candidate-9.jpg') {
        throw "Expected the candidate avatar for user 9, got '$candidateActual'."
    }

    $invalidCandidateActual = [ATSMiniProject.Helpers.AccountAvatarPathResolver]::FindLatestFileName($temporaryFolder, 10)
    if ($null -ne $invalidCandidateActual) {
        throw "Expected invalid candidate avatar to be ignored, got '$invalidCandidateActual'."
    }

    $missing = [ATSMiniProject.Helpers.AccountAvatarPathResolver]::FindLatestFileName($temporaryFolder, 99)
    if ($null -ne $missing) {
        throw "Expected no avatar for an unknown user, got '$missing'."
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryFolder) {
        Remove-Item -LiteralPath $temporaryFolder -Recurse -Force
    }
}

Write-Output 'Account avatar persistence tests passed.'
