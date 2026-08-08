#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

set -euo pipefail

version="2.5.0"
binary="osv-scanner_linux_amd64"
expected="edcfc41d257db36148f065055655fe3fcfc434b0b423ea67468a84c207524e0c"
temporary="$(mktemp -d)"
trap 'rm -rf -- "$temporary"' EXIT

curl --fail --location --proto '=https' --tlsv1.2 \
  "https://github.com/google/osv-scanner/releases/download/v${version}/${binary}" \
  --output "$temporary/$binary"
echo "$expected  $temporary/$binary" | sha256sum --check --strict
install -d "$RUNNER_TEMP/cybergaar-bin"
install -m 0755 "$temporary/$binary" "$RUNNER_TEMP/cybergaar-bin/osv-scanner"
echo "$RUNNER_TEMP/cybergaar-bin" >> "$GITHUB_PATH"
"$RUNNER_TEMP/cybergaar-bin/osv-scanner" --version
