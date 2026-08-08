# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
if (-not $gitleaks) {
    Write-Error 'Gitleaks is required and must match the version pinned in tools/versions.json.'
    exit 1
}

$stagedNames = @(git diff --cached --name-only --diff-filter=ACMR)
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
if ($stagedNames.Count -eq 0) {
    Write-Output 'No staged files require secret scanning.'
    exit 0
}

git diff --cached --no-ext-diff --no-color --unified=0 |
    & $gitleaks.Definition stdin --redact=100 --no-banner --no-color --log-level warn
exit $LASTEXITCODE
