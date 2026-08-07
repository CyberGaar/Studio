<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Security Tooling Matrix

Tool versions and GitHub Action commit SHAs are pinned in Phase 0.2. A missing required tool is a failed gate, not a skipped check.

| Layer | Purpose | Tool | Trigger | Blocking policy |
|---|---|---|---|---|
| Local pre-commit | Staged secret detection | Gitleaks | Every commit | Any unresolved finding blocks commit |
| Local pre-commit | Change-scoped static analysis | Semgrep | Relevant staged code | Critical/High blocks; other findings require disposition |
| Local pre-commit/push | Format, SPDX, allowlist, types, unit tests | Lefthook orchestration | Every commit/push | Any unexplained error blocks |
| Pull request | Repository secret scan | Gitleaks | Every PR update | Any unresolved finding blocks |
| Pull request | Dependency vulnerabilities | OSV-Scanner, npm audit, pip-audit | Changed lockfiles/manifests | Critical/High blocks |
| Pull request | License policy | SPDX/REUSE-compatible validation | Changed files/dependencies | Unknown or prohibited license blocks |
| Pull request | IaC and container lint | Checkov, Hadolint, Trivy | Changed IaC/container files | Critical/High blocks |
| Scheduled/security/release | Full SAST | CodeQL and Semgrep | Weekly and security/release changes | Critical/High blocks |
| Scheduled/release | Repository posture | OpenSSF Scorecard | Weekly and release | High-risk failures block merge; score below 7 blocks release |
| Build/release | SBOM and provenance | Syft plus signing/provenance tools | Every image/release | Missing signature, digest, SBOM, or provenance blocks release |
| Isolated staging | Dynamic application scan | Nuclei | Runnable feature milestone | Any confirmed Critical/High blocks merge |

Nuclei is never run against arbitrary public targets. CI remains change-scoped; compute-heavy integration, E2E, RBAC, and dynamic tests execute in the isolated feature-branch staging environment and their signed results are attached to the pull request.
