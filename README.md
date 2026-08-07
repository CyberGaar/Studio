<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# CyberGaar Studio

CyberGaar Studio is an open-source security and compliance platform being rebuilt through a clean-room, security-gated migration.

> **Current status:** pre-release migration scaffold. No production service is available from this repository yet.

## Migration principles

- Every service must become independently runnable before dependent services are added.
- Missing integrations must return an explicit feature-unavailable result; production must never silently use test doubles.
- Secrets, real customer data, runtime files, generated clients, and historical Git metadata are not migrated.
- Changes are developed on task branches and reviewed through pull requests. Completed feature milestones must pass isolated staging tests before merge.
- Security findings are fixed or formally tracked according to severity; Critical and High findings block merge.

## Repository status

The initial commits establish licensing, governance, local safety gates, versioning, and security automation. Application code will arrive later in small, reviewed migration tasks.

## Documentation

- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Governance](GOVERNANCE.md)
- [Migration ledger](MIGRATION_LEDGER.md)
- [Versioning policy](docs/governance/versioning.md)
- [Testing and staging gates](docs/testing/staging-gates.md)

## License

CyberGaar Studio is licensed under the [GNU Affero General Public License v3.0 or later](LICENSE). See [NOTICE](NOTICE) for ownership and attribution information.
