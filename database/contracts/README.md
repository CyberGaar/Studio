<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# CyberGaar Data Contracts

This package publishes the versioned database access contract without publishing a generated Prisma client. The canonical schema remains in `database/schema`; only the migration owner may apply schema changes.

`service-access.json` is the source of truth for group roles and table permissions. `npm run generate:roles` creates the reviewed SQL in `database/schema/sql/service-roles.sql`, and `npm run check` fails when that SQL or the canonical schema hash drifts.

Application credentials receive membership in one `NOLOGIN` group role. They must not own schema objects, inherit the migration role, or receive broad `public` privileges. Table grants are only one layer of authorization; services must still enforce user, role, and tenant checks.
