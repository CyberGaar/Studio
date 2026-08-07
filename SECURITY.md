<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Security Policy

## Supported versions

CyberGaar Studio is currently pre-release. No production release is supported yet. Security fixes are applied to the protected `main` branch and to explicitly listed supported releases after the first release is published.

## Report a vulnerability privately

Use GitHub's **Private vulnerability reporting** feature in this repository. Do not open a public issue, discussion, or pull request containing vulnerability details, proof-of-concept code, credentials, customer data, or exploitable configuration.

Include the affected component and version, impact, reproduction conditions, and a safe method for contacting you. Provide only the minimum data needed to reproduce the issue.

If private vulnerability reporting is temporarily unavailable, contact a listed security maintainer through a private channel and wait for confirmation before sending sensitive details.

## Response process

- We aim to acknowledge a report within three business days and provide an initial triage within seven business days.
- Critical and High findings block merge and release until resolved.
- Medium and Low findings require a tracked owner, due date, risk justification, and maintainer approval.
- Coordinated disclosure timing is agreed with the reporter after a fix and deployment plan exist.
- Security advisories identify affected versions, fixed versions, severity, and remediation without exposing private customer information.

These targets are goals, not a service-level agreement.

## Safe testing

Test only systems and data you own or are explicitly authorized to assess. Do not target CyberGaar production systems, other users, public infrastructure, or third parties. Avoid privacy violations, persistence, destructive testing, denial of service, social engineering, and data exfiltration.

Nuclei and other dynamic scanners may run only against the isolated, allowlisted staging environment created for the relevant pull request.
