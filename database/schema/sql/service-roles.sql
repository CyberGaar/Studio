-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
-- SPDX-License-Identifier: AGPL-3.0-or-later

-- Generated from database/contracts/service-access.json. Do not edit manually.
-- Login roles are environment-owned and receive membership in exactly one group role.

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_backend_migrator') THEN
    CREATE ROLE "cybergaar_backend_migrator" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_backend_app') THEN
    CREATE ROLE "cybergaar_backend_app" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_ai_app') THEN
    CREATE ROLE "cybergaar_ai_app" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_fleet_app') THEN
    CREATE ROLE "cybergaar_fleet_app" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_viewer_app') THEN
    CREATE ROLE "cybergaar_viewer_app" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

DO $role$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cybergaar_worker_app') THEN
    CREATE ROLE "cybergaar_worker_app" NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
  END IF;
END
$role$;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE, CREATE ON SCHEMA public TO "cybergaar_backend_migrator";

GRANT USAGE ON SCHEMA public TO "cybergaar_backend_app";
REVOKE CREATE ON SCHEMA public FROM "cybergaar_backend_app";
REVOKE "cybergaar_backend_migrator" FROM "cybergaar_backend_app";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "cybergaar_backend_app";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "cybergaar_backend_app";
ALTER DEFAULT PRIVILEGES FOR ROLE "cybergaar_backend_migrator" IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "cybergaar_backend_app";
ALTER DEFAULT PRIVILEGES FOR ROLE "cybergaar_backend_migrator" IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO "cybergaar_backend_app";

GRANT USAGE ON SCHEMA public TO "cybergaar_ai_app";
REVOKE CREATE ON SCHEMA public FROM "cybergaar_ai_app";
REVOKE "cybergaar_backend_migrator" FROM "cybergaar_ai_app";
GRANT SELECT ON TABLE "users", "projects", "frameworks", "controls", "project_controls", "document_types", "evidence", "project_evidence_links", "document_chunks", "agent_memories", "conversations", "conversation_participants", "messages", "website_scans" TO "cybergaar_ai_app";
GRANT INSERT, UPDATE, DELETE ON TABLE "evidence", "project_evidence_links", "document_chunks", "agent_memories", "conversations", "conversation_participants", "messages", "website_scans" TO "cybergaar_ai_app";
GRANT UPDATE ("dashboard_view") ON TABLE "users" TO "cybergaar_ai_app";

GRANT USAGE ON SCHEMA public TO "cybergaar_fleet_app";
REVOKE CREATE ON SCHEMA public FROM "cybergaar_fleet_app";
REVOKE "cybergaar_backend_migrator" FROM "cybergaar_fleet_app";
GRANT SELECT ON TABLE "users", "projects", "frameworks", "project_controls", "agents", "agent_deployments", "asset_profiles", "asset_profile_vulnerabilities", "asset_profile_threats", "findings", "notifications", "evidence" TO "cybergaar_fleet_app";
GRANT INSERT, UPDATE, DELETE ON TABLE "agents", "agent_deployments", "asset_profiles", "asset_profile_vulnerabilities", "asset_profile_threats", "findings", "notifications", "evidence" TO "cybergaar_fleet_app";

GRANT USAGE ON SCHEMA public TO "cybergaar_viewer_app";
REVOKE CREATE ON SCHEMA public FROM "cybergaar_viewer_app";
REVOKE "cybergaar_backend_migrator" FROM "cybergaar_viewer_app";
GRANT SELECT ON TABLE "users", "projects", "project_shares" TO "cybergaar_viewer_app";

GRANT USAGE ON SCHEMA public TO "cybergaar_worker_app";
REVOKE CREATE ON SCHEMA public FROM "cybergaar_worker_app";
REVOKE "cybergaar_backend_migrator" FROM "cybergaar_worker_app";
GRANT SELECT ON TABLE "agents", "projects", "project_controls", "evidence", "project_evidence_links", "document_chunks", "findings", "prowler_scans", "prowler_findings", "agent_memories" TO "cybergaar_worker_app";
GRANT INSERT, UPDATE, DELETE ON TABLE "evidence", "project_evidence_links", "document_chunks", "findings", "prowler_scans", "prowler_findings", "agent_memories" TO "cybergaar_worker_app";
