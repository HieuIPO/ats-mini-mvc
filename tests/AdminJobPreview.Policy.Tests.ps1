$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$controller = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Controllers\JobsController.cs')
$applicationReview = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Views\Applications\Review.cshtml')
$adminIndex = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Views\Jobs\AdminIndex.cshtml')
$jobEdit = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Views\Jobs\Edit.cshtml')
$candidateDetails = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Views\Jobs\Details.cshtml')
$model = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\ViewModels\Jobs\CandidateJobViewModels.cs')
$project = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\ATSMiniProject.csproj')
$styles = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Content\css\ats-ui-v2.css')
$previewPath = Join-Path $root 'ATSMiniProject\Views\Jobs\AdminPreview.cshtml'

$actionSignature = @'
[AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult AdminPreview(int? id)
'@

foreach ($fragment in @(
    $actionSignature.Trim(),
    '.Where(j => j.JobID == id.Value && !j.IsDeleted)',
    'return View(model);'
)) {
    if (-not $controller.Contains($fragment)) {
        throw "Admin job preview controller contract is missing: $fragment"
    }
}

foreach ($view in @($applicationReview, $adminIndex, $jobEdit)) {
    if (-not $view.Contains('Url.Action("AdminPreview", "Jobs"')) {
        throw 'An Admin/HR job link still bypasses the internal preview.'
    }
}

if (-not $candidateDetails.Contains('Url.Action("Apply", "Jobs"')) {
    throw 'The public candidate job details flow must keep its Apply action.'
}

if (-not (Test-Path -LiteralPath $previewPath)) {
    throw 'The Admin/HR job preview view is missing.'
}

$preview = Get-Content -Raw -LiteralPath $previewPath

foreach ($fragment in @(
    'Layout = "~/Views/Shared/_AdminLayout.cshtml";',
    'Xem trước tin tuyển dụng',
    'RichTextSanitizer.Sanitize(Model.Description)',
    'RichTextSanitizer.Sanitize(Model.Requirements)',
    'Url.Action("AdminIndex", "Jobs")',
    'Url.Action("Edit", "Jobs", new { id = Model.JobId })'
)) {
    if (-not $preview.Contains($fragment)) {
        throw "Admin job preview view contract is missing: $fragment"
    }
}

foreach ($forbidden in @('Url.Action("Apply"', 'Ứng tuyển', 'career-apply-button')) {
    if ($preview.Contains($forbidden)) {
        throw "Admin job preview contains a candidate-only action: $forbidden"
    }
}

if (-not $model.Contains('public bool IsActive { get; set; }')) {
    throw 'Job details model is missing the internal publication state.'
}

if (-not $controller.Contains('IsActive = j.IsActive')) {
    throw 'Admin job preview does not project the publication state.'
}

if (-not $styles.Contains('.admin-job-preview')) {
    throw 'Admin job preview styles are missing.'
}

if (-not $project.Contains('<Content Include="Views\Jobs\AdminPreview.cshtml" />')) {
    throw 'Admin job preview is not registered in the web project.'
}

Write-Output 'Admin job preview policy tests passed.'
