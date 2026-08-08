# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$targets = @(git diff --cached --name-only --diff-filter=ACMR | Where-Object { $_ -match '\.(?:cjs|js|jsx|mjs|py|ts|tsx)$' })
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($targets.Count -eq 0) {
    Write-Output 'No staged application files require targeted Semgrep.'
    exit 0
}

$semgrep = Get-Command semgrep -ErrorAction SilentlyContinue
if (-not $semgrep) {
    Write-Error 'Semgrep is required and must match tools/versions.json.'
    exit 1
}

Push-Location $root
try {
    & $semgrep.Definition scan --config .semgrep.yml --error --metrics=off -- $targets
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
