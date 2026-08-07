<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Contributing

CyberGaar Studio accepts reviewed contributions that preserve its clean-room migration, security, licensing, and service-isolation requirements.

## Before contributing

1. Read `SECURITY.md`, `GOVERNANCE.md`, and the relevant architecture and testing documents.
2. Use an issue or migration task with a defined scope, owner, acceptance criteria, and version impact.
3. Never copy old Git metadata, credentials, customer information, runtime output, generated clients, or unreviewed third-party content.
4. Report vulnerabilities privately instead of opening a public issue.

## Branches and commits

- Migration branches use `migration/<task-id>-<slug>`.
- Other work uses `feature/`, `fix/`, `security/`, `docs/`, or `chore/` prefixes.
- Direct and force pushes to `main` are prohibited after bootstrap protection is enabled.
- Use Conventional Commit subjects such as `feat:`, `fix:`, `security:`, `docs:`, or `chore:`.
- Keep each migration parent task independently reviewable and buildable.

## Pull requests

Every pull request must declare:

- change category: feature, bug, security, documentation, or maintenance;
- platform and service version impact: `MAJOR`, `MINOR`, `PATCH`, or `NONE`;
- tests and security checks executed;
- any Medium or Low finding with its issue, owner, due date, and approval;
- staging evidence when the change completes a runnable service or feature milestone.

Standard changes require one designated maintainer approval. Authentication, authorization, uploads, AI tools, database migrations, infrastructure, cryptography, secrets, and security-control changes require two approvals, including a security maintainer.

## Required quality gates

- Local pre-commit and pre-push checks must pass without suppressing errors.
- Expected tests must be discovered and executed.
- Critical and High findings block merge.
- A new commit invalidates previous review and staging evidence.
- Pull requests are squash-merged through protected `main` after required checks and approvals.

By contributing, you agree that your contribution is licensed under `AGPL-3.0-or-later` and that you have the right to submit it.
