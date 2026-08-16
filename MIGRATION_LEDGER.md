<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Migration Ledger

The detailed evidence for pre-flight work is retained outside the public repository. This ledger records only public-safe identifiers and outcomes.

| Task | Branch | Candidate SHA | Clean build | Tests | Security result | PR | Main SHA | Status |
|---|---|---|---|---|---|---|---|---|
| P0 Source scope | — | — | N/A | Scope reviewed | Approved current working tree | — | — | Verified |
| P1 Frozen snapshot | — | — | N/A | 1,187 files hash-verified | Snapshot `20260808_03` | — | — | Verified |
| P2 Case audit | — | — | N/A | Zero collisions | Passed | — | — | Verified |
| P3 Generated boundary | — | — | N/A | 21 generated paths excluded | Passed | — | — | Verified |
| P4 Disposition | — | — | N/A | 1,336 rows reconciled | Passed | — | — | Verified |
| P5 Binary and symlink policy | — | — | N/A | Manifest records modes and links | Review pending | — | — | Ready for review |
| P6 Sensitive-data review | — | — | N/A | Gitleaks 8.30.1 | Zero findings | — | — | Verified |
| P7 Security remediation | — | — | N/A | 36 findings remediated and rescanned | Passed | — | — | Verified |
| P8 Dependency map | — | — | N/A | Per-task mapping generated | Detailed review pending | — | — | In progress |
| P9 Complete disposition | — | — | N/A | Zero unassigned/colliding paths | Passed | — | — | Verified |
| P10 Licensing | `migration/0.1-scaffolding` | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Passed | SPDX and canonical-license checks passed | Gitleaks: zero findings | Bootstrap exception | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Verified |
| P11 Security platform | `migration/0.2-security-bootstrap` | `3ae2e1fcee33324cf4d6cf83891a8341ad0e66b4` | N/A | Phase 0 validation and actionlint passed | Gitleaks: zero findings; 23 action references pinned | #1 | `1abd18a911dc075826d4312b95d373a2d7a7f9e7` | Verified |
| P12 Versioning | `migration/0.1-scaffolding` | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Schema passed | Initial manifest validated | Gitleaks: zero findings | Bootstrap exception | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Verified |
| 0.1 Governance and scaffolding | `migration/0.1-scaffolding` | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Passed | Phase 0.1 validation passed | Gitleaks: zero findings | Bootstrap exception | `3d86e8a07d0982a4a8278f48809e48ccbe2693f3` | Verified |
| 0.2 Security and CI bootstrap | `migration/0.2-security-bootstrap` | `3ae2e1fcee33324cf4d6cf83891a8341ad0e66b4` | N/A | Phase 0 validation and actionlint passed | Gitleaks: zero findings; 23 action references pinned | #1 | `1abd18a911dc075826d4312b95d373a2d7a7f9e7` | Verified |
| 0.3 Team migration agent contract | `migration/0.3-agent-contract` | | N/A | Phase 0 validation passed | Gitleaks: zero findings; disclosure gate passed | | | Ready for review |
| 1.1 Canonical Prisma schema | `migration/1.1-prisma-schema` | `84a64328d9683caff5a24c02a583c9499726101f` | Passed | Static checks and disposable empty/populated PostgreSQL rehearsal passed | Plaintext credentials removed; database-enforced tenant isolation passed | #6 | `cafe888e0e925e8850048d0b0b4f12d0af78a775` | Merged |
| 1.2 Shared data contract and roles | `migration/1.2-shared-data-contract` | | Passed | Contract validation, deterministic role generation, and disposable role-boundary rehearsal passed | Five application roles denied DDL, migration-role escalation, and unrelated-table probes | | | In progress |
| 2.1 Backend build scaffold | `migration/2.1-backend-scaffold` | | Passed | Strict lint, TypeScript build, 4 native tests, 100% scaffold coverage, and hardened standalone container smoke passed | npm audit, Semgrep, and Gitleaks: zero findings; Trivy: zero High/Critical findings | | | In progress |

Allowed statuses are `Not started`, `In progress`, `Blocked`, `Ready for review`, `Ready for staging`, `Staging passed`, `Merged`, and `Verified`.
