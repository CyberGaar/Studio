# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$required = @(
    'database/contracts/package.json',
    'database/contracts/package-lock.json',
    'database/contracts/service-access.json',
    'database/contracts/service-access.schema.json',
    'database/contracts/scripts/generate-roles.mjs',
    'database/contracts/scripts/validate-contract.mjs',
    'database/schema/sql/service-roles.sql',
    'database/schema/scripts/apply-service-roles.mjs',
    'database/schema/scripts/assert-service-role-boundaries.mjs'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        Write-Error "missing-task-1.2-file:$relative"
        exit 1
    }
}

$contract = Get-Content -Raw -LiteralPath (Join-Path $root 'database/contracts/service-access.json') | ConvertFrom-Json
if ($contract.contractVersion -ne '0.1.0' -or $contract.migrationRole -ne 'cybergaar_backend_migrator') {
    Write-Error 'The data-contract version or migration owner is invalid.'
    exit 1
}
if (@($contract.services | Where-Object { $_.allTables }).Count -ne 1) {
    Write-Error 'Exactly one application role may have all-table access.'
    exit 1
}

Push-Location (Join-Path $root 'database/contracts')
try {
    $npmName = if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) { 'npm.cmd' } else { 'npm' }
    $npmCommand = (Get-Command $npmName -ErrorAction Stop).Source
    & $npmCommand run check
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

& (Join-Path $PSScriptRoot 'validate-task-1.1.ps1')
exit $LASTEXITCODE
