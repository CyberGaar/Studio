<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Repository Policy

## Protected main branch

After the repository bootstrap commit, `main` must require pull requests, squash merges, required status checks, conversation resolution, and current approvals. Direct pushes, force pushes, branch deletion, and approval by the change author are prohibited.

Standard changes require one designated maintainer. Security-sensitive changes require two approvals, including a security maintainer. Dismiss approvals when new commits are pushed.

The repository must require two-factor authentication for maintainers and contributors with write access. Administrative bypass is limited to the two-maintainer break-glass process in `GOVERNANCE.md`.

## Public branches

Every branch is treated as public before it is pushed. The pre-push disclosure gate must verify secrets, sensitive paths, licensing, task allowlists, and clean-room test evidence. Pushing a branch never authorizes merging it.

## Empty-repository bootstrap

GitHub cannot open a pull request into an unborn branch. On 2026-08-08, owner Omer Rastgar authorized one reviewed bootstrap commit and push to create `main`. Branch protection must be enabled immediately after that push and before any further repository work. This authorization applies only to the initial Phase 0.1 commit and is not a continuing bypass.

## Repository settings

- Enable private vulnerability reporting.
- Disable merge commits and rebase merges; permit squash merges only.
- Automatically delete merged branches.
- Enable secret scanning, push protection, dependency graph, Dependabot alerts, and security updates where GitHub makes them available.
- Apply least-privilege workflow permissions and prevent untrusted pull requests from accessing secrets.
