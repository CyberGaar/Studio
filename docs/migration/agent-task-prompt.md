<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Migration Task Prompt

Copy this prompt into the coding agent used by a contributor. Replace every `<...>` value before starting. The agent must also read and follow the repository-root `AGENTS.md`.

```text
You are migrating one bounded task into the new public CyberGaar Studio repository. Read AGENTS.md, SECURITY.md, CONTRIBUTING.md, GOVERNANCE.md, MAINTAINERS.md, MIGRATION_LEDGER.md, docs/architecture/service-independence.md, docs/testing/staging-gates.md, and tools/versions.json before taking action.

TASK
- Task ID: <task-id>
- Title: <title>
- Owner: <owner>
- Destination branch: migration/<task-id>-<slug>
- Change type: <feature|bug|security|documentation|maintenance>
- Platform version impact: <major|minor|patch|none>
- Affected services and version impact: <service: impact>
- Runnable feature/service milestone: <yes|no>

SOURCE AUTHORITY
- Read-only source workspace: <absolute-path>
- Immutable snapshot: <absolute-path-or-approved-identifier>
- Snapshot manifest: <absolute-path-and-sha256>
- Destination repository: <absolute-path>
- Disposable clean verification workspace: <absolute-path>

SCOPE
- Exact source paths: <list or approved manifest slice>
- Exact destination paths: <list>
- Known generated paths: <list or none>
- Known exclusions/deletions/deferred paths: <list with reasons or none>
- Dependencies/contracts: <list>
- Security-sensitive areas: <list>

ACCEPTANCE CRITERIA
<numbered, testable criteria>

REQUIRED COMMANDS/GATES
- Build/typecheck: <commands or N/A with reason>
- Unit/contract tests: <commands and expected discovery>
- Security checks: <commands>
- Clean-room checks: <commands>
- Dynamic staging checks if milestone=yes: <commands and acceptance tests>

EXECUTION CONTRACT
1. Do not modify the source or snapshot. Verify the manifest before using either.
2. Review each scoped file and its imports, callers, tests, configuration, licensing, and threat boundary before copying it. Report risks and missing dependencies.
3. Produce a proposed disposition table for every scoped source path: migrated, renamed, generated, excluded, deferred, or deleted-by-decision. Do not assemble until the disposition and exact destination allowlist are internally consistent.
4. Scan selected content for secrets, personal/customer data, unsafe samples, runtime artifacts, generated output, suspicious binaries, and incompatible third-party content. Never print discovered secret values.
5. Fix Critical/High security issues in this task before merge. Do not suppress errors. Record Medium/Low findings with issue, owner, deadline, justification, and required approval.
6. Copy only approved files and make minimal dependency-order changes. Do not bulk-copy directories, old Git metadata/history, real environment files, logs, caches, builds, local databases, generated clients, or agent/editor state.
7. Keep the service independently testable. If a downstream CyberGaar service is not present, return an explicit feature-unavailable result; do not add silent production mocks or demo responses.
8. Add or migrate colocated tests with the implementation. Discover expected tests and enforce coverage thresholds from AGENTS.md.
9. Stage only explicit literal paths. Prove the staged paths exactly equal .migration/allowlists/<task-id>.txt and review the complete diff.
10. Run all local gates, create the candidate commit, and repeat required checks from a fresh checkout/worktree at the candidate SHA.
11. Perform the task-specific security review and resolve all blocking findings. Rerun every invalidated check after a change.
12. Pass the public pre-push disclosure gate before pushing the migration branch. Never push directly to main or bypass protection.
13. Open a PR declaring change type, platform/service version impact, checks, findings, and milestone status. Obtain required independent review.
14. If milestone=yes, wait for authorized ready-for-staging approval, deploy isolated immutable candidate images, run integration/E2E/RBAC/leakage/Nuclei tests, and attach signed results. A new commit invalidates this evidence.
15. Squash-merge only through protected main. Verify the merged SHA in a fresh checkout and update the ledger, disposition inventory, and compatibility manifest.

STOP AND ASK ONE FOCUSED QUESTION if a required input is missing or if proceeding would change scope, expose sensitive information, weaken a gate, introduce an unapproved dependency, or require bypassing repository policy.

HANDOFF FORMAT
- Current status and completed subtask
- Included/renamed/generated/excluded/deferred/deleted disposition counts
- Exact changed paths
- Findings by severity and resolution
- Commands executed and pass/fail results
- Clean-room candidate SHA and verification result
- Platform/service version impact
- PR and CI links
- Staging evidence, if required
- Remaining blockers and the next single action

Do not claim "Verified" until the protected-main squash merge and fresh-checkout verification succeed.
```

## Maintainer task setup checklist

Before giving the prompt to a contributor or agent, the maintainer confirms:

- the source snapshot and manifest are immutable and current;
- the task is small enough for a complete human diff review;
- all compile-time dependencies appear in this or earlier tasks;
- the acceptance criteria include negative security cases where relevant;
- the expected tests and staging milestone are explicit;
- the task allowlist can be exact rather than directory-wide;
- the contributor has no need for production secrets or sensitive datasets.
