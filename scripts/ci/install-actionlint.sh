#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
# SPDX-License-Identifier: AGPL-3.0-or-later

set -euo pipefail

version="1.7.12"
archive="actionlint_${version}_linux_amd64.tar.gz"
expected="8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8"
temporary="$(mktemp -d)"
trap 'rm -rf -- "$temporary"' EXIT

curl --fail --location --proto '=https' --tlsv1.2 \
  "https://github.com/rhysd/actionlint/releases/download/v${version}/${archive}" \
  --output "$temporary/$archive"
echo "$expected  $temporary/$archive" | sha256sum --check --strict
tar -xzf "$temporary/$archive" -C "$temporary" actionlint
install -d "$RUNNER_TEMP/cybergaar-bin"
install -m 0755 "$temporary/actionlint" "$RUNNER_TEMP/cybergaar-bin/actionlint"
echo "$RUNNER_TEMP/cybergaar-bin" >> "$GITHUB_PATH"
"$RUNNER_TEMP/cybergaar-bin/actionlint" -version
