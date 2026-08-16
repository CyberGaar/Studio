# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$packageRoot = Join-Path $root 'database/schema'
$required = @(
    'database/schema/package.json',
    'pnpm-lock.yaml',
    'database/schema/prisma.config.ts',
    'database/schema/prisma/schema.prisma',
    'database/schema/prisma/migration_lock.toml',
    'database/schema/prisma/migrations/20260809_000000_canonical_baseline/migration.sql',
    'database/schema/scripts/apply-synthetic-fixtures.mjs',
    'database/schema/scripts/assert-baseline-reproducible.mjs',
    'database/schema/scripts/assert-generated-untracked.mjs'
)

foreach ($relative in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        Write-Error "missing-task-1.1-file:$relative"
        exit 1
    }
}

$package = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'package.json') | ConvertFrom-Json
if ($package.devDependencies.prisma -ne '7.9.1' -or $package.dependencies.'@prisma/client' -ne '7.9.1') {
    Write-Error 'Prisma CLI and client must be exact-pinned to 7.9.1.'
    exit 1
}

$schema = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'prisma/schema.prisma')
$forbidden = @(
    '(?m)^\s*credentials\s+Json',
    '(?m)^\s*password\s+String',
    'provider\s*=\s*"prisma-client-js"',
    'url\s*=\s*env\("DATABASE_URL"\)'
)
foreach ($pattern in $forbidden) {
    if ($schema -match $pattern) {
        Write-Error "unsafe-schema-pattern:$pattern"
        exit 1
    }
}

$requiredSecurityPatterns = @(
    '@@unique\(\[id, customerId\]\)',
    'fields:\s*\[projectId, customerId\],\s*references:\s*\[id, customerId\]',
    'fields:\s*\[evidenceId, customerId\],\s*references:\s*\[id, customerId\]'
)
foreach ($pattern in $requiredSecurityPatterns) {
    if ($schema -notmatch $pattern) {
        Write-Error "missing-tenant-isolation-pattern:$pattern"
        exit 1
    }
}

$fixture = Get-Content -Raw -LiteralPath (Join-Path $packageRoot 'scripts/apply-synthetic-fixtures.mjs')
if ($fixture -notmatch '\.example\.invalid' -or $fixture -match 'password123' -or $fixture -notmatch 'cross_tenant_check') {
    Write-Error 'Synthetic fixture identity or credential policy is invalid.'
    exit 1
}

Push-Location $packageRoot
try {
    $pnpmName = if ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT) { 'pnpm.cmd' } else { 'pnpm' }
    $pnpmCommand = (Get-Command $pnpmName -ErrorAction Stop).Source
    & $pnpmCommand run check
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
