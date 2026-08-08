# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$workflowRoot = Join-Path $root '.github/workflows'
$versions = Get-Content -Raw -LiteralPath (Join-Path $root 'tools/versions.json') | ConvertFrom-Json
$problems = New-Object System.Collections.Generic.List[string]
$count = 0

$workflows = @(Get-ChildItem -LiteralPath $workflowRoot -File | Where-Object { $_.Extension -in @('.yml', '.yaml') })
if ($workflows.Count -eq 0) {
    Write-Error 'no-workflows-found'
    exit 1
}

$workflows | ForEach-Object {
    $relative = $_.FullName.Substring($root.Length + 1).Replace('\', '/')
    $content = Get-Content -Raw -LiteralPath $_.FullName
    foreach ($match in [regex]::Matches($content, '(?m)^\s*uses:\s*([^\s#]+)')) {
        $count++
        $reference = $match.Groups[1].Value.Trim('"', "'")
        if ($reference.StartsWith('./')) { continue }
        if ($reference.StartsWith('docker://')) {
            if ($reference -notmatch '@sha256:[a-f0-9]{64}$') {
                $problems.Add("unpinned-container-action:${relative}:${reference}")
            }
            continue
        }
        if ($reference -notmatch '^([^/@]+/[^/@]+)(?:/[^@]+)?@([a-f0-9]{40})$') {
            $problems.Add("unpinned-action:${relative}:${reference}")
            continue
        }
        $repository = $Matches[1]
        $sha = $Matches[2]
        $expected = $versions.github_actions.PSObject.Properties[$repository].Value.sha
        if (-not $expected) {
            $problems.Add("unregistered-action:${relative}:${repository}")
        } elseif ($sha -ne $expected) {
            $problems.Add("action-sha-mismatch:${relative}:${repository}")
        }
    }
}

if ($problems.Count -gt 0) {
    $problems | Sort-Object -Unique | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Output "GitHub Action pin validation passed for $count action references."
