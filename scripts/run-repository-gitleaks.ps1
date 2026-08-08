# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
if (-not $gitleaks) {
    Write-Error 'Gitleaks is required and must match tools/versions.json.'
    exit 1
}

& $gitleaks.Definition git $root --config (Join-Path $root '.gitleaks.toml') --redact=100 --no-banner --no-color --log-level warn
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $gitleaks.Definition dir $root --config (Join-Path $root '.gitleaks.toml') --redact=100 --no-banner --no-color --log-level warn
exit $LASTEXITCODE
