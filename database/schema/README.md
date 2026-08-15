<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Canonical Database Schema

This package owns CyberGaar Studio's PostgreSQL schema and Prisma migration history. Other services consume generated contracts but do not own migrations.

Prisma and related dependencies are exact-pinned. Generated client output is created under `generated/` and must remain ignored and untracked.

## Synthetic accounts

`npm run fixtures:apply` creates fictional `.example.invalid` accounts using fresh random passwords. It logs only usernames and roles. Login credentials are written to `.runtime/demo-credentials.json` with restricted permissions; this path is ignored by Git and is destroyed with the isolated environment.

The fixture command is for disposable local or feature-branch staging databases only. It must never target production.
