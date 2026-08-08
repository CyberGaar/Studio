# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param(
    [string]$BaseSha = 'origin/main',
    [string]$TaskId
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $TaskId) {
    $TaskId = (Get-Content -Raw -LiteralPath (Join-Path $root '.migration/active-task.txt')).Trim()
}
$allowlistPath = Join-Path $root ".migration/allowlists/$TaskId.txt"
if (-not (Test-Path -LiteralPath $allowlistPath -PathType Leaf)) {
    Write-Error "Missing diff allowlist for task $TaskId."
    exit 1
}

$allowed = @{}
Get-Content -LiteralPath $allowlistPath | ForEach-Object {
    $entry = $_.Trim()
    if ($entry -and -not $entry.StartsWith('#')) { $allowed[$entry] = $true }
}

$changed = @(git diff --name-only --diff-filter=ACMRDT "$BaseSha...HEAD")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$unexpected = @($changed | Where-Object { -not $allowed.ContainsKey($_) })
if ($unexpected.Count -gt 0) {
    $unexpected | Sort-Object | ForEach-Object { Write-Error "outside-task-diff-allowlist:$_" }
    exit 1
}
Write-Output "Task diff allowlist passed for task $TaskId ($($changed.Count) paths)."
