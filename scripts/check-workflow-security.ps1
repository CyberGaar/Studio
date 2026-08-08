# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$workflowRoot = Join-Path $root '.github/workflows'
$problems = New-Object System.Collections.Generic.List[string]
$forbidden = @(
    '(?m)^\s*pull_request_target\s*:',
    '(?m)^\s*permissions\s*:\s*write-all\s*$',
    '(?i)persist-credentials\s*:\s*true',
    '\$\{\{\s*secrets\.',
    '(?i)curl\b[^\r\n|]*\|\s*(?:ba)?sh\b',
    '(?i)(?:image|container)\s*:\s*[^\r\n]+:latest\b'
)

$workflows = @(Get-ChildItem -LiteralPath $workflowRoot -File | Where-Object { $_.Extension -in @('.yml', '.yaml') })
if ($workflows.Count -eq 0) {
    Write-Error 'no-workflows-found'
    exit 1
}
foreach ($workflow in $workflows) {
    $relative = $workflow.FullName.Substring($root.Length + 1).Replace('\', '/')
    $content = Get-Content -Raw -LiteralPath $workflow.FullName
    if ($content -notmatch '(?m)^permissions\s*:') {
        $problems.Add("missing-top-level-permissions:$relative")
    }
    if ($content -notmatch 'step-security/harden-runner@') {
        $problems.Add("missing-harden-runner:$relative")
    }
    foreach ($pattern in $forbidden) {
        if ($content -match $pattern) {
            $problems.Add("unsafe-workflow-pattern:$relative")
            break
        }
    }
}

if ($problems.Count -gt 0) {
    $problems | Sort-Object -Unique | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Output "Workflow security validation passed for $($workflows.Count) workflows."
