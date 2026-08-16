# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$manifest = Get-Content -Raw -LiteralPath (Join-Path $root 'package.json') | ConvertFrom-Json
$expectedManager = 'pnpm@11.20.0+sha512-mm8zCpW2ZEbqCI+vFSFAWooB8H/ecSTMmVjf7VLUu0NnN+ZbCPhfN7Rvy6N1CSVYrFEmK4FoRLIvY0Bu0Wa/7g=='
if ($manifest.packageManager -ne $expectedManager -or $manifest.engines.pnpm -ne '11.20.0') {
    Write-Error 'The root pnpm version or integrity pin is invalid.'
    exit 1
}

$workspacePath = Join-Path $root 'pnpm-workspace.yaml'
$lockPath = Join-Path $root 'pnpm-lock.yaml'
foreach ($required in @($workspacePath, $lockPath)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        Write-Error "missing-pnpm-policy-file:$required"
        exit 1
    }
}
$workspace = Get-Content -Raw -LiteralPath $workspacePath
foreach ($setting in @('minimumReleaseAge: 10080', 'minimumReleaseAgeStrict: true', 'engineStrict: true', 'saveExact: true', 'sharedWorkspaceLockfile: true', 'strictDepBuilds: true', "'@prisma/engines': true", 'prisma: true')) {
    if (-not $workspace.Contains($setting)) {
        Write-Error "missing-pnpm-policy-setting:$setting"
        exit 1
    }
}

$npmLocks = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter 'package-lock.json' | Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' })
if ($npmLocks.Count -ne 0) {
    $npmLocks | ForEach-Object { Write-Error "prohibited-npm-lock:$($_.FullName)" }
    exit 1
}

$pnpmName = if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) { 'pnpm.cmd' } else { 'pnpm' }
$pnpmCommand = (Get-Command $pnpmName -ErrorAction Stop).Source
$actualVersion = (& $pnpmCommand --version).Trim()
if ($actualVersion -ne '11.20.0') {
    Write-Error "unexpected-pnpm-version:$actualVersion"
    exit 1
}

Push-Location $root
try {
    & $pnpmCommand install --frozen-lockfile
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $pnpmCommand audit --audit-level high
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

& (Join-Path $PSScriptRoot 'validate-task-1.2.ps1')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'Task 0.4 pnpm supply-chain validation passed.'
