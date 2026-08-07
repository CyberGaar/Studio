<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Testing and Staging Gates

## Before commit and push

Lefthook runs formatting and repository validation, staged Gitleaks, targeted Semgrep, type-checking, and relevant unit tests. Errors are investigated and fixed; they are not hidden with broad ignores or permissive flags.

## Pull-request checks

Pull-request automation uses a clean checkout and change-scoped builds, tests, dependency and license checks, essential SAST, contract checks, and migration-manifest reconciliation. It must remain lightweight enough for routine contribution.

## Feature-branch staging

A designated maintainer applies `ready-for-staging` only after local and pull-request gates pass. The feature branch deploys to an isolated environment with unique networks, databases, volumes, ports, and generated credentials.

Completed service or feature milestones run:

- service startup and health tests;
- integration and end-to-end acceptance tests;
- authentication and role-based authorization negative tests;
- log-leakage and sensitive-data tests;
- allowlisted Nuclei templates against that staging environment;
- feature-specific dynamic tests.

Signed results are attached to the pull request. Any new commit invalidates approval and previous staging evidence. The environment and credentials are destroyed after merge or pull-request closure; signed reports are retained for one year.

## Merge

The feature branch must pass staging before pull-request approval and squash merge into protected `main`. A fresh checkout of the merged SHA repeats the appropriate smoke test.
