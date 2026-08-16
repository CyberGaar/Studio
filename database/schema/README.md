<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Canonical Database Schema

This package owns CyberGaar Studio's PostgreSQL schema and Prisma migration history. Other services consume generated contracts but do not own migrations.

Prisma and related dependencies are exact-pinned. Generated client output is created under `generated/` and must remain ignored and untracked.

## Synthetic accounts

`pnpm run fixtures:apply` creates fictional `.example.invalid` accounts using fresh random passwords. It logs only usernames and roles. Login credentials are written to `.runtime/demo-credentials.json` with restricted permissions; this path is ignored by Git and is destroyed with the isolated environment.

The fixture command is for disposable local or feature-branch staging databases only. It must never target production.

## Service database roles

`pnpm run roles:apply` installs generated `NOLOGIN` group roles from the versioned data contract. `pnpm run roles:check` creates short-lived random login roles and proves that every application role can read an allowed table, cannot create schema objects, cannot assume the migration role, and cannot read its unrelated-table probe. Test credentials are never logged, and the temporary roles are dropped after each assertion.
