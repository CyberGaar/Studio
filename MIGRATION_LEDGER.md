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
| P10 Licensing | `migration/0.1-scaffolding` | | Passed | SPDX and canonical-license checks passed | Gitleaks: zero findings | | | Ready for review |
| P11 Security platform | `migration/0.2-security-bootstrap` | | | | | | | Not started |
| P12 Versioning | `migration/0.1-scaffolding` | | Schema passed | Initial manifest validated | Gitleaks: zero findings | | | Ready for review |
| 0.1 Governance and scaffolding | `migration/0.1-scaffolding` | | Passed | Phase 0.1 validation passed | Gitleaks: zero findings | | | Ready for review |
| 0.2 Security and CI bootstrap | `migration/0.2-security-bootstrap` | | | | | | | Not started |

Allowed statuses are `Not started`, `In progress`, `Blocked`, `Ready for review`, `Ready for staging`, `Staging passed`, `Merged`, and `Verified`.
