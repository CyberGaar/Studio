# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$requiredCopyright = 'SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)'
$requiredLicense = 'SPDX-License-Identifier: AGPL-3.0-or-later'
$namedFiles = @('.gitignore', '.gitattributes', '.editorconfig', '.env.example', '.npmrc', 'NOTICE')
$extensions = @('.md', '.ps1', '.yml', '.yaml', '.toml', '.sh', '.py', '.ts', '.tsx', '.js', '.mjs')
$problems = New-Object System.Collections.Generic.List[string]

$candidatePaths = @(git -C $root ls-files --cached --others --exclude-standard)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
foreach ($relativePath in $candidatePaths) {
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $root $relativePath))
    if ([System.IO.File]::Exists($fullPath)) {
        $files.Add([System.IO.FileInfo]::new($fullPath))
    } elseif (-not [System.IO.Directory]::Exists($fullPath)) {
        $normalized = $relativePath.Replace('\', '/')
        $problems.Add("missing-repository-path:$normalized")
    }
}

foreach ($file in $files) {
    $requiresHeader = $namedFiles -contains $file.Name -or $extensions -contains $file.Extension.ToLowerInvariant()
    if (-not $requiresHeader) {
        continue
    }

    $header = (Get-Content -LiteralPath $file.FullName -TotalCount 12 -ErrorAction Stop) -join "`n"
    $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
    if ($header -notmatch [regex]::Escape($requiredCopyright)) {
        $problems.Add("missing-copyright:$relative")
    }
    if ($header -notmatch [regex]::Escape($requiredLicense)) {
        $problems.Add("missing-license:$relative")
    }
}

if ($problems.Count -gt 0) {
    $problems | Sort-Object | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "SPDX validation passed for $($files.Count) repository files."
