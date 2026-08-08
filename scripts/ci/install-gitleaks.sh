#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

set -euo pipefail

version="8.30.1"
archive="gitleaks_${version}_linux_x64.tar.gz"
expected="551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb"
temporary="$(mktemp -d)"
trap 'rm -rf -- "$temporary"' EXIT

curl --fail --location --proto '=https' --tlsv1.2 \
  "https://github.com/gitleaks/gitleaks/releases/download/v${version}/${archive}" \
  --output "$temporary/$archive"
echo "$expected  $temporary/$archive" | sha256sum --check --strict
tar -xzf "$temporary/$archive" -C "$temporary" gitleaks
install -d "$RUNNER_TEMP/cybergaar-bin"
install -m 0755 "$temporary/gitleaks" "$RUNNER_TEMP/cybergaar-bin/gitleaks"
echo "$RUNNER_TEMP/cybergaar-bin" >> "$GITHUB_PATH"
"$RUNNER_TEMP/cybergaar-bin/gitleaks" version | grep -Fx "$version"
