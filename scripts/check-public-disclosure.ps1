# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$problems = New-Object System.Collections.Generic.List[string]
$forbiddenDirectories = @('node_modules', 'dist', 'build', '.next', 'coverage', '__pycache__', 'test-results', 'playwright-report', 'outputs')
$forbiddenExtensions = @('.pem', '.key', '.p12', '.pfx', '.jks', '.db', '.sqlite', '.sqlite3', '.log', '.pyc')
$contentPatterns = @(
    '-----BEGIN [A-Z ]*PRIVATE KEY-----',
    '(?i)C:\\Users\\',
    '(?i)D:\\studio(?:[\\/]|$)',
    '(?i)password\s*[:=]\s*["''][^<${][^"'']{5,}["'']'
)

$candidatePaths = @(git -C $root ls-files --cached --others --exclude-standard)
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$files = @($candidatePaths | ForEach-Object { Get-Item -LiteralPath (Join-Path $root $_) } | Where-Object { -not $_.PSIsContainer })

foreach ($file in $files) {
    $relative = $file.FullName.Substring($root.Length + 1).Replace('\', '/')
    $parts = $relative.Split('/')
    if (@($parts | Where-Object { $forbiddenDirectories -contains $_ }).Count -gt 0) {
        $problems.Add("runtime-path:$relative")
        continue
    }
    if ($file.Name -match '^\.env(?:\..+)?$' -and $file.Name -ne '.env.example') {
        $problems.Add("environment-file:$relative")
        continue
    }
    if ($forbiddenExtensions -contains $file.Extension.ToLowerInvariant()) {
        $problems.Add("sensitive-or-runtime-extension:$relative")
        continue
    }
    if ($file.Length -gt 2MB -or $relative -eq 'scripts/check-public-disclosure.ps1') {
        continue
    }

    $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction SilentlyContinue
    foreach ($pattern in $contentPatterns) {
        if ($content -match $pattern) {
            $problems.Add("disclosure-pattern:$relative")
            break
        }
    }
}

if ($problems.Count -gt 0) {
    $problems | Sort-Object -Unique | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Public-disclosure path and content checks passed for $($files.Count) files."
