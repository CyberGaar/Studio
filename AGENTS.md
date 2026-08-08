<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# CyberGaar Studio Agent Instructions

These instructions apply to every person and AI agent working anywhere in this repository. More specific instructions may add requirements for a subdirectory, but they may not weaken this file, `SECURITY.md`, `CONTRIBUTING.md`, or the protected-branch policy.

## Mission

Build CyberGaar Studio in a new, auditable Git history by migrating one bounded feature or service slice at a time. Review source content before copying it. Every included, excluded, renamed, generated, deferred, or deliberately deleted source path must have an explicit disposition.

The old repository is a source of content only. Never copy its `.git` directory, branches, tags, commit messages, contributor history, runtime state, or credentials.

## Required task inputs

Do not begin assembly until the task defines:

- task ID, title, owner, and destination branch `migration/<task-id>-<slug>`;
- change type: feature, bug, security, documentation, or maintenance;
- platform and affected-service SemVer impact;
- immutable source snapshot identifier and verified manifest;
- exact source and destination path allowlists;
- acceptance criteria, known dependencies, and security-sensitive areas;
- expected build, test, security, and clean-room commands;
- whether the task completes a runnable feature or service milestone.

Use `docs/migration/agent-task-prompt.md` to start each task. If required information cannot be derived safely, stop and ask one focused question.

## Mandatory workflow

1. **Verify source truth.** Confirm the immutable snapshot manifest before reading files. Treat the source and snapshot as read-only.
2. **Review before migration.** Inspect every allowlisted file, its imports, callers, tests, configuration, licensing, and security boundary. Do not blindly copy directories.
3. **Classify every path.** Record `migrated`, `renamed`, `generated`, `excluded`, `deferred`, or `deleted-by-decision` in the disposition inventory. Explain every non-migrated path.
4. **Resolve findings.** Fix Critical and High findings before merge. Medium and Low findings need a public-safe issue, owner, deadline, justification, and maintainer approval. Do not suppress a failing check merely to make it pass.
5. **Assemble minimally.** Copy only allowlisted files. Make the smallest edits necessary for the task to stand alone. Never use broad copy operations or broad staging commands such as `git add .` or `git add -A`.
6. **Preserve service independence.** A runnable service must start without unrelated CyberGaar services. Optional missing integrations return an explicit feature-unavailable result; production must never silently use demo data or test doubles.
7. **Test locally.** Run repository validation, formatting, type checks, discovered relevant tests, staged Gitleaks, and targeted Semgrep. Investigate every error. Record commands and results.
8. **Create a candidate.** Confirm staged paths exactly equal the task allowlist, review the full staged diff, and commit on the task branch with a Conventional Commit subject.
9. **Verify cleanly.** Test the candidate SHA in a fresh clone or worktree where source files and unstaged local state are unavailable.
10. **Review security.** Run the task-specific secret, SAST, dependency, license, contract, container, and infrastructure checks. Manually review authentication, authorization, tenant isolation, input validation, data exposure, and failure behavior where applicable.
11. **Pass the public gate.** Before pushing any branch, rerun disclosure, sensitive-path, SPDX, allowlist, and repository-history secret checks. Never push directly to `main` and never bypass branch protection.
12. **Use a pull request.** Declare type, version impact, tests, findings, and milestone status. A new commit invalidates prior approval and staging evidence.
13. **Stage completed milestones.** When the task completes a runnable feature or service, deploy its immutable candidate images to isolated feature-branch staging. Run health, integration, E2E, negative RBAC, leakage, and allowlisted Nuclei tests. Attach signed results to the PR. Nuclei does not run in routine repository CI.
14. **Merge and attest.** Obtain required independent approvals, squash-merge through protected `main`, verify the merged SHA in a fresh checkout, and update the migration ledger and compatibility manifest.

## Content that must not migrate

Never migrate real environment files, credentials, private keys, tokens, customer or personal data, logs, reports containing sensitive details, caches, dependencies, build output, coverage, local databases, temporary files, editor/agent state, generated clients, or disposable runtime state. Generate sanitized samples with obvious placeholders when a test or demonstration needs data.

Do not publish licensed standards text or third-party content unless CyberGaar has confirmed redistribution rights and recorded the disposition. Public documentation may demonstrate mappings to standards using approved synthetic data and separately owned control content.

## Security-sensitive changes

Treat authentication, authorization, tenant isolation, uploads, URL fetching, AI prompts/tools, MCP, database migrations, infrastructure, cryptography, secrets, webhooks, and command execution as security-sensitive. These changes require negative tests and the designated security review defined by repository governance.

Never log secrets, authorization headers, session material, raw request/response bodies, sensitive prompts, personal data, or scanner exploit details. Use structured logs, configurable `LOG_LEVEL` with default `info`, and explicit redaction tests.

## Dependencies and supply chain

Use supported libraries from authoritative registries. Pin runtimes, tools, lockfiles, GitHub Actions by full commit SHA, and container bases by immutable digest where required. Do not introduce a dependency without checking maintenance, provenance, license compatibility, vulnerabilities, and whether the capability already exists locally.

GHCR is the canonical runtime artifact registry. Publish service-version and commit-SHA tags, attach checksums/SBOM/provenance, and deploy by immutable digest. Never deploy `latest`. Promote the exact staging-tested image without rebuilding it.

## Testing rules

- Discover expected tests; zero discovered tests is not a pass when tests should exist.
- Do not use `|| true`, broad ignores, disabled assertions, blanket exclusions, or reduced thresholds to hide failures.
- New security-critical logic targets at least 90% branch coverage; other newly migrated feature code targets at least 70%.
- A scaffolding commit need not start a service. The commit that completes a service or feature milestone must prove it dynamically in isolated staging.
- Required infrastructure may use a minimal isolated fixture. Unrelated application services may not be required unless their contract is explicitly part of the task.

## Stop conditions

Stop immediately and report the evidence when:

- the source snapshot hash differs from its approved manifest;
- any staged path is outside the task allowlist;
- a secret, private key, sensitive dataset, or prohibited path is detected;
- a Critical or High finding remains unresolved;
- builds or tests fail, expected tests are not discovered, or clean-room results differ;
- generated or disposable content appears in the candidate;
- required service independence or explicit unavailable behavior is missing;
- the reviewed candidate SHA differs from the pushed SHA;
- branch protection, required CI, review, or staging would need to be bypassed.

Do not claim completion from a verbal assertion. Cite a command result, CI URL, artifact/report path, candidate SHA, or reviewer sign-off in `MIGRATION_LEDGER.md`.

## Agent response contract

During work, report the current subtask, files under review, discovered risks, and executed gates without exposing sensitive content. At handoff, provide:

- disposition counts and exact changed paths;
- findings by severity and their resolution;
- build, test, security, and clean-room results;
- service/milestone and version impact;
- candidate SHA, PR link, staging evidence when required, and remaining blockers.

Never describe a task as verified until the protected-main merge and fresh-checkout verification are complete.
