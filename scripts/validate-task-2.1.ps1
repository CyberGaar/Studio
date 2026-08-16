# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $root 'backend'
$required = @(
    'backend/.dockerignore',
    'backend/.env.example',
    'backend/Dockerfile',
    'backend/eslint.config.mjs',
    'backend/package-lock.json',
    'backend/package.json',
    'backend/src/config.ts',
    'backend/src/index.ts',
    'backend/src/server.ts',
    'backend/test/config.test.ts',
    'backend/test/server.test.ts',
    'backend/tsconfig.json'
)
foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        Write-Error "missing-task-2.1-file:$relative"
        exit 1
    }
}

$prohibited = @(
    'backend/jest.config.js',
    'backend/src/constants.ts',
    'backend/src/lib/python_core',
    'backend/tsconfig.eslint.json'
)
foreach ($relative in $prohibited) {
    if (Test-Path -LiteralPath (Join-Path $root $relative)) {
        Write-Error "prohibited-task-2.1-path:$relative"
        exit 1
    }
}

$package = Get-Content -Raw -LiteralPath (Join-Path $backend 'package.json') | ConvertFrom-Json
if ($package.engines.node -ne '22.20.0' -or $package.engines.npm -ne '10.9.3') {
    Write-Error 'Backend runtime pins do not match the repository runtime pins.'
    exit 1
}
if ($null -ne $package.dependencies -and @($package.dependencies.PSObject.Properties).Count -ne 0) {
    Write-Error 'The backend scaffold must not have production dependencies.'
    exit 1
}
foreach ($property in $package.devDependencies.PSObject.Properties) {
    if ($property.Value -notmatch '^\d+\.\d+\.\d+$') {
        Write-Error "non-exact-dependency:$($property.Name)=$($property.Value)"
        exit 1
    }
}

$dockerfile = Get-Content -Raw -LiteralPath (Join-Path $backend 'Dockerfile')
if ($dockerfile -notmatch 'node:22\.20\.0-alpine@sha256:[a-f0-9]{64}') {
    Write-Error 'The backend container base is not pinned by immutable digest.'
    exit 1
}
$requiredRuntimePackages = @(
    'libcrypto3=3.5.7-r0',
    'libssl3=3.5.7-r0',
    'musl=1.2.5-r12',
    'musl-utils=1.2.5-r12',
    'zlib=1.3.2-r0'
)
foreach ($runtimePackage in $requiredRuntimePackages) {
    if (-not $dockerfile.Contains($runtimePackage)) {
        Write-Error "missing-patched-runtime-package:$runtimePackage"
        exit 1
    }
}
foreach ($packageManagerPath in @('/usr/local/lib/node_modules/npm', '/usr/local/lib/node_modules/corepack', '/opt/yarn-v*')) {
    if (-not $dockerfile.Contains($packageManagerPath)) {
        Write-Error "runtime-package-manager-not-removed:$packageManagerPath"
        exit 1
    }
}

$trackedText = Get-ChildItem -LiteralPath $backend -Recurse -File |
    Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]|[\\/]dist[\\/]' } |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }
if (($trackedText -join "`n") -match '\|\|\s*true|FEATURE_FLAG.*demo|detect-object-injection.*off') {
    Write-Error 'A prohibited failure suppression, demo fallback, or blanket security-rule disable was found.'
    exit 1
}

Push-Location $backend
try {
    $npmName = if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) { 'npm.cmd' } else { 'npm' }
    $npmCommand = (Get-Command $npmName -ErrorAction Stop).Source
    & $npmCommand ci
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $npmCommand run check
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $npmCommand audit --audit-level=high
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
    Pop-Location
}

Write-Output 'Task 2.1 backend scaffold validation passed.'
