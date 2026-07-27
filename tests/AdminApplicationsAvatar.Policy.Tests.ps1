$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$controller = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Controllers\ApplicationsController.cs')
$model = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\ViewModels\Applications\AdminApplicationViewModels.cs')
$view = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Views\Applications\Index.cshtml')
$css = Get-Content -Raw -LiteralPath (Join-Path $root 'ATSMiniProject\Content\css\ats-ui-v2.css')

foreach ($fragment in @(
    'public int? CandidateUserId { get; set; }',
    'public string CandidateAvatarUrl { get; set; }'
)) {
    if (-not $model.Contains($fragment)) {
        throw "Admin application avatar model is missing: $fragment"
    }
}

foreach ($fragment in @(
    '[AuthorizeRole("Admin", "HR")]',
    'public ActionResult CandidateAvatar(int id)',
    'a.ApplicationID == id && !a.IsDeleted',
    'CandidateUserId = a.CandidateUserID',
    'application.CandidateAvatarUrl = Url.Action(',
    '"candidate-" + candidateUserId.Value + ".jpg"',
    'Response.Cache.SetCacheability(System.Web.HttpCacheability.Private)',
    'return File(avatarPath, "image/jpeg")'
)) {
    if (-not $controller.Contains($fragment)) {
        throw "Admin application avatar endpoint is missing: $fragment"
    }
}

foreach ($fragment in @(
    'if (!string.IsNullOrWhiteSpace(item.CandidateAvatarUrl))',
    'class="application-ops-avatar-image"',
    'src="@item.CandidateAvatarUrl"',
    'alt=""'
)) {
    if (-not $view.Contains($fragment)) {
        throw "Admin application avatar view is missing: $fragment"
    }
}

if (-not $css.Contains('.application-ops-avatar-image')) {
    throw 'Admin application avatar image styling is missing.'
}

Write-Output 'Admin applications avatar policy tests passed.'
