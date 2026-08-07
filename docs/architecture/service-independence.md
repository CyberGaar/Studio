<!-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar) -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# Service Independence

Each CyberGaar Studio service is migrated as an independently verifiable unit.

## Minimum runnable service contract

A service is considered runnable only when it can start without unrelated application services and provides:

- deterministic configuration validation;
- a health or readiness signal appropriate to the service;
- structured logs with configurable `LOG_LEVEL`, defaulting to `info`;
- sensitive-field and personal-data redaction;
- graceful behavior when optional dependencies are absent;
- unit tests and a documented local smoke test;
- a version recorded in the compatibility manifest.

Required infrastructure such as a database may be supplied through a minimal isolated test fixture. Another CyberGaar application service must not be required unless the task explicitly migrates and tests that contract.

## Unavailable features

An integration or feature whose service has not yet migrated must return an explicit feature-unavailable result. Production code must not silently return demo responses, use test doubles, or claim success.

## Milestones

Early scaffolding commits do not need to start a service. When a parent task completes a runnable service or complete feature, that branch must deploy to isolated staging and pass its dynamic acceptance and security tests before merge.
