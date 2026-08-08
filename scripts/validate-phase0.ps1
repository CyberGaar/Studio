# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    'README.md', 'LICENSE', 'NOTICE', 'AGENTS.md', '.gitignore', '.gitattributes', '.editorconfig',
    '.env.example', '.node-version', '.npmrc', 'package.json', 'SECURITY.md',
    'CONTRIBUTING.md', 'CODE_OF_CONDUCT.md', 'GOVERNANCE.md', 'MAINTAINERS.md',
    'CHANGELOG.md', 'MIGRATION_LEDGER.md', 'lefthook.yml',
    '.migration/active-task.txt', '.migration/allowlists/0.1.txt', '.migration/allowlists/0.2.txt',
    '.migration/allowlists/0.3.txt',
    '.github/CODEOWNERS', '.github/dependabot.yml', '.github/pull_request_template.md',
    '.github/codeql/codeql-config.yml', '.github/workflows/pr-gate.yml',
    '.github/workflows/codeql.yml', '.github/workflows/scorecard.yml',
    '.github/workflows/security-scheduled.yml', '.gitleaks.toml', '.semgrep.yml',
    'scripts/check-action-pins.ps1', 'scripts/check-staged-allowlist.ps1',
    'scripts/check-task-diff-allowlist.ps1', 'scripts/check-workflow-security.ps1',
    'scripts/run-repository-gitleaks.ps1', 'scripts/run-targeted-semgrep.ps1',
    'scripts/ci/install-actionlint.sh', 'scripts/ci/install-gitleaks.sh',
    'scripts/ci/install-osv-scanner.sh',
    'schemas/migration-disposition.schema.json',
    'schemas/compatibility-manifest.schema.json',
    'versions/compatibility-manifest.json', 'tools/versions.json',
    'docs/architecture/service-independence.md',
    'docs/governance/repository-policy.md', 'docs/governance/versioning.md',
    'docs/migration/agent-task-prompt.md',
    'docs/security/tooling-matrix.md', 'docs/testing/staging-gates.md'
)

foreach ($relative in $requiredFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $relative) -PathType Leaf)) {
        Write-Error "missing-required-file:$relative"
        exit 1
    }
}

$licenseText = Get-Content -Raw -LiteralPath (Join-Path $root 'LICENSE')
if ($licenseText -notmatch 'GNU AFFERO GENERAL PUBLIC LICENSE' -or $licenseText -notmatch 'Version 3, 19 November 2007') {
    Write-Error 'LICENSE does not contain the canonical GNU AGPL v3 heading.'
    exit 1
}

$package = Get-Content -Raw -LiteralPath (Join-Path $root 'package.json') | ConvertFrom-Json
if ($package.license -ne 'AGPL-3.0-or-later' -or $package.version -ne '0.1.0') {
    Write-Error 'package.json license or platform version is incorrect.'
    exit 1
}

$compatibility = Get-Content -Raw -LiteralPath (Join-Path $root 'versions/compatibility-manifest.json') | ConvertFrom-Json
if ($compatibility.platform.version -ne '0.1.0') {
    Write-Error 'The platform must start at version 0.1.0.'
    exit 1
}
foreach ($service in $compatibility.services) {
    if ($service.version -ne '0.1.0' -or $service.status -ne 'unavailable') {
        Write-Error "Invalid initial service state: $($service.name)"
        exit 1
    }
}

Get-Content -Raw -LiteralPath (Join-Path $root 'schemas/migration-disposition.schema.json') | ConvertFrom-Json | Out-Null
Get-Content -Raw -LiteralPath (Join-Path $root 'schemas/compatibility-manifest.schema.json') | ConvertFrom-Json | Out-Null
Get-Content -Raw -LiteralPath (Join-Path $root 'tools/versions.json') | ConvertFrom-Json | Out-Null

& (Join-Path $PSScriptRoot 'check-spdx.ps1')
& (Join-Path $PSScriptRoot 'check-public-disclosure.ps1')
& (Join-Path $PSScriptRoot 'check-action-pins.ps1')
& (Join-Path $PSScriptRoot 'check-workflow-security.ps1')

Write-Output 'Phase 0 validation passed.'
