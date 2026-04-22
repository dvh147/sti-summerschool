<#
.SYNOPSIS
    Copy the latest website source from this private repo into a local clone
    of the public site repo, ready for you to commit and push.

.DESCRIPTION
    Run this from the private repo root (or anywhere) after a `git pull`
    on the feature branch. It copies all website files into the public
    repo path you pass in, leaving the .git directory there intact.

.PARAMETER PublicRepoPath
    Absolute path to your local clone of dvh147/sti-summerschool
    (the folder that contains its .git directory).

.EXAMPLE
    .\scripts\sync-to-public.ps1 -PublicRepoPath "C:\Users\dennis.verhoeven\Dropbox (Personal)\Desktop\Conferences\Patent Workshops KUL\2026\sti-public-export"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$PublicRepoPath
)

$ErrorActionPreference = "Stop"

# The private repo root is the parent of this script's directory.
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

if (-not (Test-Path (Join-Path $PublicRepoPath ".git"))) {
    throw "Path '$PublicRepoPath' is not a git repo (no .git folder). Pass the root of your local clone of dvh147/sti-summerschool."
}

Write-Host "Source (private repo): $repoRoot" -ForegroundColor Cyan
Write-Host "Target (public repo):  $PublicRepoPath" -ForegroundColor Cyan
Write-Host ""

# robocopy exits 0-7 on success; 8+ is a real error. We only flag >= 8.
robocopy $repoRoot $PublicRepoPath /E `
    /XD 2026 node_modules dist .git .astro `
    /XF "*.log" ".DS_Store" ".env" ".env.local" | Out-Null

$rc = $LASTEXITCODE
if ($rc -ge 8) {
    throw "robocopy failed with exit code $rc"
}

Write-Host "Sync complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps (run these in the public repo):" -ForegroundColor Yellow
Write-Host "  cd `"$PublicRepoPath`""
Write-Host "  git status"
Write-Host "  git add -A"
Write-Host "  git commit -m `"Update website`""
Write-Host "  git push"
Write-Host ""
Write-Host "GitHub Actions will deploy automatically (~1-2 min)."
