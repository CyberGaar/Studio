# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param(
    [string]$TaskId
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $TaskId) {
    $TaskId = (Get-Content -Raw -LiteralPath (Join-Path $root '.migration/active-task.txt')).Trim()
}
if ($TaskId -notmatch '^[A-Za-z0-9._-]+$') {
    Write-Error 'The active migration task identifier is invalid.'
    exit 1
}

$allowlistPath = Join-Path $root ".migration/allowlists/$TaskId.txt"
if (-not (Test-Path -LiteralPath $allowlistPath -PathType Leaf)) {
    Write-Error "Missing staged-file allowlist for task $TaskId."
    exit 1
}

$allowed = @{}
Get-Content -LiteralPath $allowlistPath | ForEach-Object {
    $entry = $_.Trim()
    if ($entry -and -not $entry.StartsWith('#')) {
        $allowed[$entry] = $true
    }
}

$unexpected = @()
$staged = @(git diff --cached --name-only --diff-filter=ACMRDT)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
foreach ($path in $staged) {
    if (-not $allowed.ContainsKey($path)) {
        $unexpected += $path
    }
}

if ($unexpected.Count -gt 0) {
    $unexpected | Sort-Object | ForEach-Object { Write-Error "outside-task-allowlist:$_" }
    exit 1
}

Write-Output "Staged-file allowlist passed for task $TaskId ($($staged.Count) paths)."
