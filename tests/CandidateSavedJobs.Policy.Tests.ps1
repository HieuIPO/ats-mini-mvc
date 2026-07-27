$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$migrationPath = Join-Path $root 'database/2026-07-27_AddSavedJobs.sql'
$entityPath = Join-Path $root 'ATSMiniProject/Models/SavedJob.cs'
$contextPath = Join-Path $root 'ATSMiniProject/Models/ATSMiniDBContext.cs'
$projectPath = Join-Path $root 'ATSMiniProject/ATSMiniProject.csproj'
$controllerPath = Join-Path $root 'ATSMiniProject/Controllers/JobsController.cs'
$jobViewModelsPath = Join-Path $root 'ATSMiniProject/ViewModels/Jobs/CandidateJobViewModels.cs'
$candidateControllerPath = Join-Path $root 'ATSMiniProject/Controllers/CandidateController.cs'
$savedJobViewModelsPath = Join-Path $root 'ATSMiniProject/ViewModels/Candidate/SavedJobViewModels.cs'
$savedJobsViewPath = Join-Path $root 'ATSMiniProject/Views/Candidate/SavedJobs.cshtml'

if (-not (Test-Path $migrationPath)) {
    throw 'SavedJobs migration is missing.'
}

if (-not (Test-Path $entityPath)) {
    throw 'SavedJob entity is missing.'
}

$sql = Get-Content -Raw $migrationPath
$context = Get-Content -Raw $contextPath
$project = Get-Content -Raw $projectPath
$controller = Get-Content -Raw $controllerPath
$jobViewModels = Get-Content -Raw $jobViewModelsPath
$candidateController = Get-Content -Raw $candidateControllerPath

foreach ($required in @(
    'CREATE TABLE dbo.SavedJobs',
    'CandidateUserID INT NOT NULL',
    'JobID INT NOT NULL',
    'SavedAt DATETIME NOT NULL',
    'UX_SavedJobs_Candidate_Job',
    'FOREIGN KEY (CandidateUserID)',
    'FOREIGN KEY (JobID)'
)) {
    if (-not $sql.Contains($required)) {
        throw "Missing persistence rule: $required"
    }
}

if ($context -notmatch 'DbSet<SavedJob>\s+SavedJobs') {
    throw 'SavedJobs DbSet is missing.'
}

if ($context -notmatch 'modelBuilder\.Entity<SavedJob>\(\)') {
    throw 'SavedJob EF mapping is missing.'
}

if ($project -notmatch 'Compile Include="Models\\SavedJob\.cs"') {
    throw 'SavedJob.cs is not included in the project.'
}

foreach ($signature in @(
    'ActionResult SaveJob(int jobId, string returnUrl)',
    'ActionResult UnsaveJob(int jobId, string returnUrl)'
)) {
    if (-not $controller.Contains($signature)) {
        throw "Missing action: $signature"
    }
}

foreach ($actionName in @('SaveJob', 'UnsaveJob')) {
    $pattern = '(?s)\[AuthorizeRole\("Candidate"\)\]\s*\[HttpPost\]\s*\[ValidateAntiForgeryToken\]\s*public\s+ActionResult\s+' + $actionName
    if ($controller -notmatch $pattern) {
        throw "$actionName must be a Candidate-only anti-forgery POST action."
    }
}

if (-not $controller.Contains('Url.IsLocalUrl(returnUrl)')) {
    throw 'Saved job redirects must reject non-local return URLs.'
}

if (-not $controller.Contains('CandidateUserID = userId')) {
    throw 'Saved jobs must derive CandidateUserID from the authenticated session.'
}

if (-not $jobViewModels.Contains('public bool IsSaved { get; set; }')) {
    throw 'Job card/detail models must expose IsSaved.'
}

if (-not $controller.Contains('j.SavedJobs.Any')) {
    throw 'Public job queries must project the saved state.'
}

if (-not (Test-Path $savedJobViewModelsPath)) {
    throw 'Saved jobs page view models are missing.'
}

if (-not (Test-Path $savedJobsViewPath)) {
    throw 'Candidate SavedJobs view is missing.'
}

if ($candidateController -notmatch '(?s)\[HttpGet\]\s*public\s+ActionResult\s+SavedJobs\(int page = 1\)') {
    throw 'Candidate SavedJobs GET action is missing.'
}

foreach ($queryRule in @(
    's.CandidateUserID == userId',
    '!s.Job.IsDeleted',
    'OrderByDescending(s => s.SavedAt)',
    'Pagination.Calculate'
)) {
    if (-not $candidateController.Contains($queryRule)) {
        throw "Saved jobs query rule is missing: $queryRule"
    }
}

if ($project -notmatch 'Compile Include="ViewModels\\Candidate\\SavedJobViewModels\.cs"') {
    throw 'Saved job view models are not included in the project.'
}

if ($project -notmatch 'Content Include="Views\\Candidate\\SavedJobs\.cshtml"') {
    throw 'SavedJobs view is not included in the project.'
}

'Candidate saved jobs policy tests passed.'
