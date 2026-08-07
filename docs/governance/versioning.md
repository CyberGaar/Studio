<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Versioning Policy

CyberGaar Studio uses Semantic Versioning for the platform and independently for each service. The platform and every planned service begin at `0.1.0`.

## Version impact

- `MAJOR`: breaking API, schema, authentication, deployment, or compatibility contract.
- `MINOR`: backward-compatible feature.
- `PATCH`: backward-compatible bug fix or security fix.
- `NONE`: documentation, tests, or maintenance with no shipped behavior or artifact impact.

Security fixes use normal SemVer and are additionally identified through the `security` change category, labels, changelog entries, and advisories. Nonstandard security suffixes are not used.

Every pull request declares one platform impact and an impact for each changed service. A service version changes only when that service changes.

## Compatibility manifest

`versions/compatibility-manifest.json` maps a platform version to exact service versions. Releases also record immutable GHCR image digests, the database schema version, and compatibility constraints. A service remains `unavailable` until it satisfies its independent runnable milestone.

## Releases

Releases are created only from protected `main` after staging. Tags, images, checksums, SBOMs, and provenance are signed. The exact image digest tested in staging is promoted without rebuilding; the `latest` tag is never a deployment input.
