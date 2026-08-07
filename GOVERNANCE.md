<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Governance

## Ownership

CyberGaar Studio is owned and stewarded by **CyberGaar (Omer Rastgar)**. The repository is licensed under `AGPL-3.0-or-later`; governance authority does not override contributor copyrights or third-party licenses.

## Maintainers

Designated maintainers and security maintainers are listed in `MAINTAINERS.md` and enforced through CODEOWNERS and protected-branch rules. New maintainers are appointed through a reviewed governance pull request.

## Decision model

- Routine, non-sensitive changes require one designated maintainer approval.
- Security-sensitive changes require two approvals, including a security maintainer.
- Critical and High findings block merge. Medium and Low findings follow the documented exception process.
- Architecture and compatibility decisions are recorded in versioned documents or decision records.
- The owner resolves deadlocks while documenting the rationale and any dissent.

## Break-glass process

Emergency changes require two designated maintainers, a linked security incident or availability issue, the smallest safe change, and a public follow-up record that excludes sensitive exploit details. Branch protection is restored immediately, and normal review and staging evidence are completed retrospectively within the incident timeline.

No single maintainer may invoke break-glass alone.
