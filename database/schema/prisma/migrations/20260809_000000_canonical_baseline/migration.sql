-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
-- SPDX-License-Identifier: AGPL-3.0-or-later

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- RequiredExtension
CREATE EXTENSION IF NOT EXISTS "vector";

-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('pending', 'in_progress', 'review_pending', 'approved', 'rejected', 'returned', 'completed');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('admin', 'auditor', 'customer', 'manager', 'reviewer', 'compliance', 'employee');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('Active', 'Inactive');

-- CreateEnum
CREATE TYPE "AgentPlatform" AS ENUM ('windows', 'macos', 'linux', 'cloud');

-- CreateEnum
CREATE TYPE "AgentStatus" AS ENUM ('Active', 'Inactive', 'Pending', 'Offline', 'Error');

-- CreateEnum
CREATE TYPE "EvidenceType" AS ENUM ('document', 'screenshot', 'log', 'network', 'config', 'image', 'audio', 'video', 'spreadsheet', 'pdf', 'other');

-- CreateEnum
CREATE TYPE "AuditSeverity" AS ENUM ('Low', 'Medium', 'High');

-- CreateEnum
CREATE TYPE "CourseStatus" AS ENUM ('Not Started', 'In Progress', 'Completed');

-- CreateEnum
CREATE TYPE "ActivityStatus" AS ENUM ('Accepted', 'Rejected', 'Pending');

-- CreateEnum
CREATE TYPE "TagSource" AS ENUM ('manual', 'tagging_engine');

-- CreateEnum
CREATE TYPE "CASBIntegrationType" AS ENUM ('saas_office365', 'saas_google_workspace', 'saas_salesforce', 'saas_slack', 'saas_github', 'saas_aws', 'saas_azure', 'saas_gcp', 'onprem_exchange', 'onprem_sharepoint', 'onprem_active_directory', 'casb_netskope', 'casb_mcafee_mvision', 'casb_zscaler', 'casb_cisco_cloudlock', 'casb_cloudflare', 'agent_endpoint', 'agent_network', 'vps_ssh', 'kubernetes_k8s', 'saas_okta');

-- CreateEnum
CREATE TYPE "IntegrationStatus" AS ENUM ('pending', 'active', 'failed', 'disabled', 'syncing');

-- CreateEnum
CREATE TYPE "AuthType" AS ENUM ('oauth2', 'api_key', 'saml', 'certificate', 'basic_auth', 'ssh_key', 'ssh_password', 'kubeconfig');

-- CreateEnum
CREATE TYPE "FindingSeverity" AS ENUM ('critical', 'high', 'medium', 'low', 'info');

-- CreateEnum
CREATE TYPE "FindingCategory" AS ENUM ('data_leak', 'malware', 'unauthorized_access', 'policy_violation', 'compliance_gap', 'misconfiguration', 'anomaly', 'suspicious_activity', 'vulnerability', 'other', 'threat');

-- CreateEnum
CREATE TYPE "FindingStatus" AS ENUM ('open', 'investigating', 'in_progress', 'resolved', 'false_positive', 'accepted_risk', 'dismissed');

-- CreateEnum
CREATE TYPE "ChunkingStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "DownloadStatus" AS ENUM ('PENDING', 'DOWNLOADING', 'COMPLETED', 'FAILED');

-- CreateEnum
CREATE TYPE "SyncStatus" AS ENUM ('running', 'completed', 'failed', 'cancelled');

-- CreateEnum
CREATE TYPE "ControlStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'IMPLEMENTED', 'NOT_IN_PLACE', 'NOT_APPLICABLE');

-- CreateTable
CREATE TABLE "frameworks" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "has_sql_data" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "frameworks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "controls" (
    "id" TEXT NOT NULL,
    "framework_id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT,
    "sql_enabled" BOOLEAN NOT NULL DEFAULT false,
    "sql_query" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "controls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tags" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tags_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_controls" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "control_id" TEXT NOT NULL,
    "progress" INTEGER NOT NULL DEFAULT 0,
    "evidence_count" INTEGER NOT NULL DEFAULT 0,
    "notes" TEXT,
    "reviewer_notes" TEXT,
    "is_flagged" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "status" "ControlStatus" NOT NULL DEFAULT 'NOT_STARTED',

    CONSTRAINT "project_controls_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence_items" (
    "id" TEXT NOT NULL,
    "project_control_id" TEXT NOT NULL,
    "file_url" TEXT,
    "file_name" TEXT NOT NULL,
    "tags" TEXT[],
    "tag_source" "TagSource" NOT NULL DEFAULT 'manual',
    "uploaded_by_id" TEXT NOT NULL,
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "evidence_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "policy_reviews" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "evidence_id" TEXT NOT NULL,
    "reviewed_at" TIMESTAMP(3),
    "assigned_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "policy_reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "projects" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "customer_name" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "auditor_id" TEXT,
    "framework_id" TEXT,
    "status" "ProjectStatus" NOT NULL DEFAULT 'pending',
    "rejection_reason" TEXT,
    "reviewer_auditor_id" TEXT,
    "description" TEXT,
    "scope" TEXT,
    "start_date" TIMESTAMP(3),
    "due_date" TIMESTAMP(3),
    "end_date" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_demo" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "projects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_shares" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_shares_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "avatar_url" TEXT,
    "role" "UserRole" NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'Active',
    "last_active" TIMESTAMP(3),
    "created_by_id" TEXT,
    "manager_id" TEXT,
    "linked_customer_id" TEXT,
    "force_password_change" BOOLEAN NOT NULL DEFAULT false,
    "is_new_user" BOOLEAN NOT NULL DEFAULT true,
    "push_subscription" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "bio" TEXT,
    "dashboard_view" TEXT NOT NULL DEFAULT 'complex',
    "department" TEXT,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "link" TEXT,
    "read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auditors" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "experience" TEXT,
    "certifications" TEXT[],
    "progress" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auditors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agents" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "platform" "AgentPlatform" NOT NULL,
    "status" "AgentStatus" NOT NULL DEFAULT 'Pending',
    "project_id" TEXT,
    "hostname" TEXT,
    "ip_address" TEXT,
    "os_version" TEXT,
    "fleet_node_key" TEXT,
    "hardware_serial" TEXT,
    "last_sync" TIMESTAMP(3),
    "last_seen_at" TIMESTAMP(3),
    "version" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "customer_id" TEXT,
    "asset_category" TEXT,
    "asset_type" TEXT,
    "connectivity" TEXT,
    "criticality" TEXT DEFAULT 'Medium',
    "environment" TEXT DEFAULT 'Production',
    "location" TEXT DEFAULT 'Office',
    "is_manual" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "agents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_deployments" (
    "id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "platform" "AgentPlatform" NOT NULL,
    "downloaded_by" TEXT NOT NULL,
    "downloaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "linked_agent_id" TEXT,

    CONSTRAINT "agent_deployments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_types" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "document_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "document_type_tasks" (
    "id" TEXT NOT NULL,
    "document_type_id" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "is_critical" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "document_type_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence_tag_audits" (
    "id" TEXT NOT NULL,
    "evidence_id" TEXT NOT NULL,
    "tag_id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "source" TEXT NOT NULL DEFAULT 'ai',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "evidence_tag_audits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence" (
    "id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "agent_id" TEXT,
    "file_name" TEXT NOT NULL,
    "file_url" TEXT,
    "type" "EvidenceType" NOT NULL DEFAULT 'document',
    "uploaded_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "uploaded_by_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "chunking_status" "ChunkingStatus" NOT NULL DEFAULT 'PENDING',
    "download_error" TEXT,
    "download_status" "DownloadStatus",
    "is_url_based" BOOLEAN NOT NULL DEFAULT false,
    "is_demo" BOOLEAN NOT NULL DEFAULT false,
    "evaluation_result" JSONB,
    "detected_document_type_id" TEXT,
    "content_hash" TEXT,

    CONSTRAINT "evidence_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_evidence_links" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "evidence_id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "added_by_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "project_evidence_links_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL,
    "user_name" TEXT NOT NULL,
    "user_avatar_url" TEXT,
    "action" TEXT NOT NULL,
    "details" TEXT,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "severity" "AuditSeverity" NOT NULL DEFAULT 'Low',

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "courses" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "duration" TEXT,
    "thumbnail_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "courses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_courses" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "course_id" TEXT NOT NULL,
    "status" "CourseStatus" NOT NULL DEFAULT 'Not Started',
    "progress" INTEGER NOT NULL DEFAULT 0,
    "completion_date" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_courses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compliance_activities" (
    "id" TEXT NOT NULL,
    "evidence_name" TEXT NOT NULL,
    "status" "ActivityStatus" NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "compliance_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_requests" (
    "id" TEXT NOT NULL,
    "auditor_id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "project_id" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "due_date" TIMESTAMP(3),
    "status" TEXT NOT NULL DEFAULT 'Pending',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "control_id" TEXT,

    CONSTRAINT "audit_requests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_events" (
    "id" TEXT NOT NULL,
    "auditor_id" TEXT NOT NULL,
    "customer_id" TEXT,
    "project_id" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "start_time" TIMESTAMP(3) NOT NULL,
    "end_time" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "synced_to_jira" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "audit_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversations" (
    "id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "title" TEXT,

    CONSTRAINT "conversations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "conversation_participants" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "last_read_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "conversation_participants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "messages" (
    "id" TEXT NOT NULL,
    "conversation_id" TEXT NOT NULL,
    "sender_id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB,

    CONSTRAINT "messages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_time_logs" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "duration_seconds" INTEGER NOT NULL DEFAULT 0,
    "writing_seconds" INTEGER NOT NULL DEFAULT 0,
    "attaching_seconds" INTEGER NOT NULL DEFAULT 0,
    "chat_seconds" INTEGER NOT NULL DEFAULT 0,
    "review_seconds" INTEGER NOT NULL DEFAULT 0,
    "synced_seconds" INTEGER NOT NULL DEFAULT 0,
    "meeting_synced_seconds" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "project_time_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_issues" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'open',
    "resolution" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "project_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "evidence_annotations" (
    "id" TEXT NOT NULL,
    "evidence_id" TEXT NOT NULL,
    "author_id" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "page" INTEGER NOT NULL DEFAULT 1,
    "x" DOUBLE PRECISION NOT NULL,
    "y" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "evidence_annotations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "casb_integrations" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "CASBIntegrationType" NOT NULL,
    "vendor" TEXT,
    "status" "IntegrationStatus" NOT NULL DEFAULT 'pending',
    "authType" "AuthType" NOT NULL DEFAULT 'api_key',
    "config" JSONB,
    "credentials_ciphertext" BYTEA,
    "credentials_key_id" TEXT,
    "credentials_version" INTEGER NOT NULL DEFAULT 1,
    "tokenExpiry" TIMESTAMP(3),
    "syncFrequency" INTEGER NOT NULL DEFAULT 3600,
    "lastSyncAt" TIMESTAMP(3),
    "nextSyncAt" TIMESTAMP(3),
    "created_by_id" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_demo" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "casb_integrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "findings" (
    "id" TEXT NOT NULL,
    "integration_id" TEXT,
    "agent_id" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "alert_name" TEXT,
    "severity" "FindingSeverity" NOT NULL,
    "category" "FindingCategory" NOT NULL,
    "type" TEXT NOT NULL,
    "status" "FindingStatus" NOT NULL DEFAULT 'open',
    "notified" BOOLEAN NOT NULL DEFAULT false,
    "assigned_to_id" TEXT,
    "affected_resource" TEXT,
    "affected_user" TEXT,
    "resource_type" TEXT,
    "location" TEXT,
    "cloud_service" TEXT,
    "raw_data" JSONB,
    "evidence" TEXT[],
    "frameworks" TEXT[],
    "controls" TEXT[],
    "recommendation" TEXT,
    "remediation_steps" TEXT,
    "due_date" TIMESTAMP(3),
    "resolved_at" TIMESTAMP(3),
    "resolved_by_id" TEXT,
    "first_seen_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_seen_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "occurrence_count" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "template_id" TEXT,
    "stride" TEXT,

    CONSTRAINT "findings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "finding_comments" (
    "id" TEXT NOT NULL,
    "finding_id" TEXT NOT NULL,
    "author_id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "finding_comments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "integration_sync_logs" (
    "id" TEXT NOT NULL,
    "integration_id" TEXT NOT NULL,
    "status" "SyncStatus" NOT NULL,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),
    "records_processed" INTEGER NOT NULL DEFAULT 0,
    "findings_created" INTEGER NOT NULL DEFAULT 0,
    "findings_updated" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "details" JSONB,

    CONSTRAINT "integration_sync_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_integrations" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "config" JSONB NOT NULL,
    "credentials_ciphertext" BYTEA,
    "credentials_key_id" TEXT,
    "credentials_version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_integrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "vulnerability_templates" (
    "id" TEXT NOT NULL,
    "template_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "severity" "FindingSeverity" NOT NULL,
    "category" TEXT,
    "description" TEXT NOT NULL,
    "recommendation" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "cvss_score" DOUBLE PRECISION,

    CONSTRAINT "vulnerability_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "threat_templates" (
    "id" TEXT NOT NULL,
    "template_id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "likelihood" TEXT NOT NULL,
    "impact" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "stride" TEXT,

    CONSTRAINT "threat_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_risk_triggers" (
    "id" TEXT NOT NULL,
    "question_id" TEXT NOT NULL,
    "vulnerability_id" TEXT,
    "threat_id" TEXT,
    "trigger_condition" TEXT NOT NULL,

    CONSTRAINT "question_risk_triggers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asset_profiles" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "asset_category" TEXT NOT NULL,
    "asset_type" TEXT NOT NULL,
    "platform" TEXT,
    "conditions" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "asset_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asset_profile_vulnerabilities" (
    "profile_id" TEXT NOT NULL,
    "vulnerability_id" TEXT NOT NULL,

    CONSTRAINT "asset_profile_vulnerabilities_pkey" PRIMARY KEY ("profile_id","vulnerability_id")
);

-- CreateTable
CREATE TABLE "asset_profile_threats" (
    "profile_id" TEXT NOT NULL,
    "threat_id" TEXT NOT NULL,

    CONSTRAINT "asset_profile_threats_pkey" PRIMARY KEY ("profile_id","threat_id")
);

-- CreateTable
CREATE TABLE "document_chunks" (
    "id" TEXT NOT NULL,
    "evidence_id" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "chunk_index" INTEGER NOT NULL,
    "metadata" JSONB,
    "vector" vector,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "document_chunks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prowler_scans" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "regions" TEXT[],
    "scanType" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "findings_count" INTEGER NOT NULL DEFAULT 0,
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMP(3),
    "duration" INTEGER,
    "error" TEXT,
    "logs" TEXT,

    CONSTRAINT "prowler_scans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prowler_findings" (
    "id" TEXT NOT NULL,
    "scan_id" TEXT NOT NULL,
    "auth_method" TEXT,
    "timestamp" TIMESTAMP(3),
    "account_uid" TEXT,
    "account_id" TEXT,
    "check_id" TEXT NOT NULL,
    "check_title" TEXT NOT NULL,
    "check_type" TEXT,
    "service_name" TEXT,
    "service_id" TEXT,
    "resource_name" TEXT,
    "resource_type" TEXT,
    "region" TEXT,
    "status" TEXT NOT NULL,
    "status_extended" TEXT,
    "severity" TEXT NOT NULL,
    "description" TEXT,
    "risk" TEXT,
    "remediation" TEXT,
    "doc_url" TEXT,
    "compliance" JSONB,
    "related_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "prowler_findings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questionnaire_questions" (
    "id" TEXT NOT NULL,
    "framework_id" TEXT NOT NULL,
    "control_id" TEXT,
    "text" TEXT NOT NULL,
    "description" TEXT,
    "type" TEXT NOT NULL DEFAULT 'binary',
    "options" JSONB,
    "order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "questionnaire_questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questionnaire_responses" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "question_id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "evidence_id" TEXT,
    "ai_feedback" TEXT,
    "is_accepted" BOOLEAN,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "questionnaire_responses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_memories" (
    "id" TEXT NOT NULL,
    "project_id" TEXT,
    "customer_id" TEXT NOT NULL,
    "category" TEXT,
    "content" TEXT NOT NULL,
    "summary" TEXT,
    "source" TEXT,
    "evidence_id" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "embedding" vector,
    "memory_type" TEXT NOT NULL,
    "user_id" TEXT,

    CONSTRAINT "agent_memories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compliance_tasks" (
    "id" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "project_id" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "priority" TEXT NOT NULL DEFAULT 'medium',
    "due_date" TIMESTAMP(3),
    "completed_at" TIMESTAMP(3),
    "source_document_id" TEXT,
    "is_manual" BOOLEAN NOT NULL DEFAULT false,
    "evidence_url" TEXT,
    "evidenceNotes" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "compliance_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tech_stack_discrepancies" (
    "id" TEXT NOT NULL,
    "project_id" TEXT NOT NULL,
    "onboarding_stack" JSONB,
    "extracted_stack" JSONB,
    "status" TEXT NOT NULL DEFAULT 'OPEN',
    "resolved_stack" JSONB,
    "resolved_by_id" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "tech_stack_discrepancies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_limits" (
    "id" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "entity_id" TEXT,
    "limit" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ai_limits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "website_scans" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "domain" TEXT NOT NULL,
    "site_type" TEXT NOT NULL,
    "tier" TEXT NOT NULL DEFAULT 'Website',
    "platform_confidence" INTEGER NOT NULL DEFAULT 0,
    "sub_category" TEXT NOT NULL DEFAULT 'Website',
    "compliance_score" INTEGER NOT NULL,
    "score_breakdown" JSONB NOT NULL,
    "missing_policies" TEXT[],
    "hsts" BOOLEAN NOT NULL,
    "csp" BOOLEAN NOT NULL,
    "x_frame_options" BOOLEAN NOT NULL,
    "x_content_type_options" BOOLEAN NOT NULL,
    "referrer_policy" BOOLEAN NOT NULL,
    "secrets_count" INTEGER NOT NULL,
    "malicious_count" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "website_scans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_ControlTags" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ControlTags_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_ControlToThreatTemplate" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ControlToThreatTemplate_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_ControlToVulnerabilityTemplate" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ControlToVulnerabilityTemplate_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_DocumentTypeTags" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_DocumentTypeTags_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_EvidenceTags" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_EvidenceTags_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_EvidenceToProjectControl" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_EvidenceToProjectControl_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateTable
CREATE TABLE "_ChunkTags" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_ChunkTags_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "frameworks_name_key" ON "frameworks"("name");

-- CreateIndex
CREATE INDEX "controls_framework_id_idx" ON "controls"("framework_id");

-- CreateIndex
CREATE UNIQUE INDEX "controls_framework_id_code_key" ON "controls"("framework_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "tags_name_key" ON "tags"("name");

-- CreateIndex
CREATE INDEX "project_controls_project_id_idx" ON "project_controls"("project_id");

-- CreateIndex
CREATE INDEX "project_controls_control_id_idx" ON "project_controls"("control_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_controls_project_id_control_id_key" ON "project_controls"("project_id", "control_id");

-- CreateIndex
CREATE INDEX "evidence_items_project_control_id_idx" ON "evidence_items"("project_control_id");

-- CreateIndex
CREATE INDEX "evidence_items_uploaded_by_id_idx" ON "evidence_items"("uploaded_by_id");

-- CreateIndex
CREATE UNIQUE INDEX "policy_reviews_user_id_evidence_id_key" ON "policy_reviews"("user_id", "evidence_id");

-- CreateIndex
CREATE INDEX "projects_customer_id_idx" ON "projects"("customer_id");

-- CreateIndex
CREATE INDEX "projects_auditor_id_idx" ON "projects"("auditor_id");

-- CreateIndex
CREATE INDEX "projects_framework_id_idx" ON "projects"("framework_id");

-- CreateIndex
CREATE INDEX "projects_reviewer_auditor_id_idx" ON "projects"("reviewer_auditor_id");

-- CreateIndex
CREATE UNIQUE INDEX "projects_id_customer_id_key" ON "projects"("id", "customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_shares_user_id_project_id_key" ON "project_shares"("user_id", "project_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_created_by_id_idx" ON "users"("created_by_id");

-- CreateIndex
CREATE INDEX "users_manager_id_idx" ON "users"("manager_id");

-- CreateIndex
CREATE INDEX "users_linked_customer_id_idx" ON "users"("linked_customer_id");

-- CreateIndex
CREATE INDEX "notifications_user_id_idx" ON "notifications"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "auditors_user_id_key" ON "auditors"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "agents_fleet_node_key_key" ON "agents"("fleet_node_key");

-- CreateIndex
CREATE INDEX "agents_project_id_idx" ON "agents"("project_id");

-- CreateIndex
CREATE INDEX "agents_customer_id_idx" ON "agents"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "agent_deployments_linked_agent_id_key" ON "agent_deployments"("linked_agent_id");

-- CreateIndex
CREATE INDEX "agent_deployments_customer_id_expires_at_idx" ON "agent_deployments"("customer_id", "expires_at");

-- CreateIndex
CREATE INDEX "agent_deployments_platform_linked_agent_id_idx" ON "agent_deployments"("platform", "linked_agent_id");

-- CreateIndex
CREATE UNIQUE INDEX "document_types_name_key" ON "document_types"("name");

-- CreateIndex
CREATE INDEX "document_type_tasks_document_type_id_idx" ON "document_type_tasks"("document_type_id");

-- CreateIndex
CREATE UNIQUE INDEX "document_type_tasks_document_type_id_description_key" ON "document_type_tasks"("document_type_id", "description");

-- CreateIndex
CREATE INDEX "evidence_tag_audits_evidence_id_idx" ON "evidence_tag_audits"("evidence_id");

-- CreateIndex
CREATE INDEX "evidence_tag_audits_tag_id_idx" ON "evidence_tag_audits"("tag_id");

-- CreateIndex
CREATE INDEX "evidence_customer_id_idx" ON "evidence"("customer_id");

-- CreateIndex
CREATE INDEX "evidence_is_demo_idx" ON "evidence"("is_demo");

-- CreateIndex
CREATE INDEX "evidence_agent_id_idx" ON "evidence"("agent_id");

-- CreateIndex
CREATE INDEX "evidence_uploaded_by_id_idx" ON "evidence"("uploaded_by_id");

-- CreateIndex
CREATE INDEX "evidence_detected_document_type_id_idx" ON "evidence"("detected_document_type_id");

-- CreateIndex
CREATE UNIQUE INDEX "evidence_customer_id_file_name_key" ON "evidence"("customer_id", "file_name");

-- CreateIndex
CREATE UNIQUE INDEX "evidence_id_customer_id_key" ON "evidence"("id", "customer_id");

-- CreateIndex
CREATE INDEX "project_evidence_links_project_id_idx" ON "project_evidence_links"("project_id");

-- CreateIndex
CREATE INDEX "project_evidence_links_evidence_id_idx" ON "project_evidence_links"("evidence_id");

-- CreateIndex
CREATE INDEX "project_evidence_links_customer_id_idx" ON "project_evidence_links"("customer_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_evidence_links_project_id_evidence_id_key" ON "project_evidence_links"("project_id", "evidence_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_courses_user_id_course_id_key" ON "user_courses"("user_id", "course_id");

-- CreateIndex
CREATE INDEX "audit_requests_auditor_id_idx" ON "audit_requests"("auditor_id");

-- CreateIndex
CREATE INDEX "audit_requests_customer_id_idx" ON "audit_requests"("customer_id");

-- CreateIndex
CREATE INDEX "audit_requests_project_id_idx" ON "audit_requests"("project_id");

-- CreateIndex
CREATE INDEX "audit_requests_control_id_idx" ON "audit_requests"("control_id");

-- CreateIndex
CREATE INDEX "audit_events_auditor_id_idx" ON "audit_events"("auditor_id");

-- CreateIndex
CREATE INDEX "audit_events_customer_id_idx" ON "audit_events"("customer_id");

-- CreateIndex
CREATE INDEX "audit_events_project_id_idx" ON "audit_events"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "conversation_participants_conversation_id_user_id_key" ON "conversation_participants"("conversation_id", "user_id");

-- CreateIndex
CREATE INDEX "messages_conversation_id_idx" ON "messages"("conversation_id");

-- CreateIndex
CREATE INDEX "messages_sender_id_idx" ON "messages"("sender_id");

-- CreateIndex
CREATE UNIQUE INDEX "project_time_logs_project_id_user_id_date_key" ON "project_time_logs"("project_id", "user_id", "date");

-- CreateIndex
CREATE INDEX "project_issues_project_id_idx" ON "project_issues"("project_id");

-- CreateIndex
CREATE INDEX "project_issues_customer_id_idx" ON "project_issues"("customer_id");

-- CreateIndex
CREATE INDEX "evidence_annotations_evidence_id_idx" ON "evidence_annotations"("evidence_id");

-- CreateIndex
CREATE INDEX "evidence_annotations_author_id_idx" ON "evidence_annotations"("author_id");

-- CreateIndex
CREATE INDEX "casb_integrations_created_by_id_idx" ON "casb_integrations"("created_by_id");

-- CreateIndex
CREATE INDEX "findings_integration_id_idx" ON "findings"("integration_id");

-- CreateIndex
CREATE INDEX "findings_agent_id_idx" ON "findings"("agent_id");

-- CreateIndex
CREATE INDEX "findings_assigned_to_id_idx" ON "findings"("assigned_to_id");

-- CreateIndex
CREATE INDEX "findings_resolved_by_id_idx" ON "findings"("resolved_by_id");

-- CreateIndex
CREATE INDEX "finding_comments_finding_id_idx" ON "finding_comments"("finding_id");

-- CreateIndex
CREATE INDEX "finding_comments_author_id_idx" ON "finding_comments"("author_id");

-- CreateIndex
CREATE INDEX "integration_sync_logs_integration_id_idx" ON "integration_sync_logs"("integration_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_integrations_user_id_provider_key" ON "user_integrations"("user_id", "provider");

-- CreateIndex
CREATE UNIQUE INDEX "vulnerability_templates_template_id_key" ON "vulnerability_templates"("template_id");

-- CreateIndex
CREATE UNIQUE INDEX "threat_templates_template_id_key" ON "threat_templates"("template_id");

-- CreateIndex
CREATE INDEX "question_risk_triggers_question_id_idx" ON "question_risk_triggers"("question_id");

-- CreateIndex
CREATE INDEX "question_risk_triggers_vulnerability_id_idx" ON "question_risk_triggers"("vulnerability_id");

-- CreateIndex
CREATE INDEX "question_risk_triggers_threat_id_idx" ON "question_risk_triggers"("threat_id");

-- CreateIndex
CREATE UNIQUE INDEX "asset_profiles_name_key" ON "asset_profiles"("name");

-- CreateIndex
CREATE INDEX "document_chunks_evidence_id_idx" ON "document_chunks"("evidence_id");

-- CreateIndex
CREATE INDEX "prowler_findings_check_id_idx" ON "prowler_findings"("check_id");

-- CreateIndex
CREATE INDEX "prowler_findings_status_idx" ON "prowler_findings"("status");

-- CreateIndex
CREATE INDEX "prowler_findings_severity_idx" ON "prowler_findings"("severity");

-- CreateIndex
CREATE INDEX "questionnaire_questions_framework_id_idx" ON "questionnaire_questions"("framework_id");

-- CreateIndex
CREATE INDEX "questionnaire_questions_control_id_idx" ON "questionnaire_questions"("control_id");

-- CreateIndex
CREATE INDEX "questionnaire_responses_project_id_idx" ON "questionnaire_responses"("project_id");

-- CreateIndex
CREATE INDEX "questionnaire_responses_question_id_idx" ON "questionnaire_responses"("question_id");

-- CreateIndex
CREATE INDEX "questionnaire_responses_user_id_idx" ON "questionnaire_responses"("user_id");

-- CreateIndex
CREATE INDEX "questionnaire_responses_evidence_id_idx" ON "questionnaire_responses"("evidence_id");

-- CreateIndex
CREATE UNIQUE INDEX "questionnaire_responses_project_id_question_id_key" ON "questionnaire_responses"("project_id", "question_id");

-- CreateIndex
CREATE INDEX "agent_memories_customer_id_project_id_idx" ON "agent_memories"("customer_id", "project_id");

-- CreateIndex
CREATE INDEX "compliance_tasks_customer_id_project_id_idx" ON "compliance_tasks"("customer_id", "project_id");

-- CreateIndex
CREATE UNIQUE INDEX "compliance_tasks_project_id_category_source_document_id_key" ON "compliance_tasks"("project_id", "category", "source_document_id");

-- CreateIndex
CREATE INDEX "tech_stack_discrepancies_project_id_idx" ON "tech_stack_discrepancies"("project_id");

-- CreateIndex
CREATE UNIQUE INDEX "ai_limits_type_entity_id_key" ON "ai_limits"("type", "entity_id");

-- CreateIndex
CREATE UNIQUE INDEX "website_scans_url_key" ON "website_scans"("url");

-- CreateIndex
CREATE INDEX "_ControlTags_B_index" ON "_ControlTags"("B");

-- CreateIndex
CREATE INDEX "_ControlToThreatTemplate_B_index" ON "_ControlToThreatTemplate"("B");

-- CreateIndex
CREATE INDEX "_ControlToVulnerabilityTemplate_B_index" ON "_ControlToVulnerabilityTemplate"("B");

-- CreateIndex
CREATE INDEX "_DocumentTypeTags_B_index" ON "_DocumentTypeTags"("B");

-- CreateIndex
CREATE INDEX "_EvidenceTags_B_index" ON "_EvidenceTags"("B");

-- CreateIndex
CREATE INDEX "_EvidenceToProjectControl_B_index" ON "_EvidenceToProjectControl"("B");

-- CreateIndex
CREATE INDEX "_ChunkTags_B_index" ON "_ChunkTags"("B");

-- AddForeignKey
ALTER TABLE "controls" ADD CONSTRAINT "controls_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "frameworks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_controls" ADD CONSTRAINT "project_controls_control_id_fkey" FOREIGN KEY ("control_id") REFERENCES "controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_controls" ADD CONSTRAINT "project_controls_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_items" ADD CONSTRAINT "evidence_items_project_control_id_fkey" FOREIGN KEY ("project_control_id") REFERENCES "project_controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_items" ADD CONSTRAINT "evidence_items_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "policy_reviews" ADD CONSTRAINT "policy_reviews_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "policy_reviews" ADD CONSTRAINT "policy_reviews_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_auditor_id_fkey" FOREIGN KEY ("auditor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "frameworks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "projects" ADD CONSTRAINT "projects_reviewer_auditor_id_fkey" FOREIGN KEY ("reviewer_auditor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_shares" ADD CONSTRAINT "project_shares_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_shares" ADD CONSTRAINT "project_shares_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_linked_customer_id_fkey" FOREIGN KEY ("linked_customer_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_manager_id_fkey" FOREIGN KEY ("manager_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditors" ADD CONSTRAINT "auditors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agents" ADD CONSTRAINT "agents_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agents" ADD CONSTRAINT "agents_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_deployments" ADD CONSTRAINT "agent_deployments_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_deployments" ADD CONSTRAINT "agent_deployments_downloaded_by_fkey" FOREIGN KEY ("downloaded_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_deployments" ADD CONSTRAINT "agent_deployments_linked_agent_id_fkey" FOREIGN KEY ("linked_agent_id") REFERENCES "agents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_type_tasks" ADD CONSTRAINT "document_type_tasks_document_type_id_fkey" FOREIGN KEY ("document_type_id") REFERENCES "document_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_tag_audits" ADD CONSTRAINT "evidence_tag_audits_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_tag_audits" ADD CONSTRAINT "evidence_tag_audits_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "agents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_detected_document_type_id_fkey" FOREIGN KEY ("detected_document_type_id") REFERENCES "document_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence" ADD CONSTRAINT "evidence_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_evidence_links" ADD CONSTRAINT "project_evidence_links_project_id_customer_id_fkey" FOREIGN KEY ("project_id", "customer_id") REFERENCES "projects"("id", "customer_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_evidence_links" ADD CONSTRAINT "project_evidence_links_evidence_id_customer_id_fkey" FOREIGN KEY ("evidence_id", "customer_id") REFERENCES "evidence"("id", "customer_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_evidence_links" ADD CONSTRAINT "project_evidence_links_added_by_id_fkey" FOREIGN KEY ("added_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_courses" ADD CONSTRAINT "user_courses_course_id_fkey" FOREIGN KEY ("course_id") REFERENCES "courses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_courses" ADD CONSTRAINT "user_courses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_requests" ADD CONSTRAINT "audit_requests_auditor_id_fkey" FOREIGN KEY ("auditor_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_requests" ADD CONSTRAINT "audit_requests_control_id_fkey" FOREIGN KEY ("control_id") REFERENCES "project_controls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_requests" ADD CONSTRAINT "audit_requests_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_requests" ADD CONSTRAINT "audit_requests_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_auditor_id_fkey" FOREIGN KEY ("auditor_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "conversation_participants" ADD CONSTRAINT "conversation_participants_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "messages" ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_time_logs" ADD CONSTRAINT "project_time_logs_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_time_logs" ADD CONSTRAINT "project_time_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_issues" ADD CONSTRAINT "project_issues_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_issues" ADD CONSTRAINT "project_issues_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_annotations" ADD CONSTRAINT "evidence_annotations_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "evidence_annotations" ADD CONSTRAINT "evidence_annotations_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "casb_integrations" ADD CONSTRAINT "casb_integrations_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "findings" ADD CONSTRAINT "findings_agent_id_fkey" FOREIGN KEY ("agent_id") REFERENCES "agents"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "findings" ADD CONSTRAINT "findings_assigned_to_id_fkey" FOREIGN KEY ("assigned_to_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "findings" ADD CONSTRAINT "findings_integration_id_fkey" FOREIGN KEY ("integration_id") REFERENCES "casb_integrations"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "findings" ADD CONSTRAINT "findings_resolved_by_id_fkey" FOREIGN KEY ("resolved_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finding_comments" ADD CONSTRAINT "finding_comments_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finding_comments" ADD CONSTRAINT "finding_comments_finding_id_fkey" FOREIGN KEY ("finding_id") REFERENCES "findings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "integration_sync_logs" ADD CONSTRAINT "integration_sync_logs_integration_id_fkey" FOREIGN KEY ("integration_id") REFERENCES "casb_integrations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_integrations" ADD CONSTRAINT "user_integrations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_risk_triggers" ADD CONSTRAINT "question_risk_triggers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questionnaire_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_risk_triggers" ADD CONSTRAINT "question_risk_triggers_threat_id_fkey" FOREIGN KEY ("threat_id") REFERENCES "threat_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "question_risk_triggers" ADD CONSTRAINT "question_risk_triggers_vulnerability_id_fkey" FOREIGN KEY ("vulnerability_id") REFERENCES "vulnerability_templates"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_profile_vulnerabilities" ADD CONSTRAINT "asset_profile_vulnerabilities_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "asset_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_profile_vulnerabilities" ADD CONSTRAINT "asset_profile_vulnerabilities_vulnerability_id_fkey" FOREIGN KEY ("vulnerability_id") REFERENCES "vulnerability_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_profile_threats" ADD CONSTRAINT "asset_profile_threats_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "asset_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_profile_threats" ADD CONSTRAINT "asset_profile_threats_threat_id_fkey" FOREIGN KEY ("threat_id") REFERENCES "threat_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "document_chunks" ADD CONSTRAINT "document_chunks_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prowler_findings" ADD CONSTRAINT "prowler_findings_scan_id_fkey" FOREIGN KEY ("scan_id") REFERENCES "prowler_scans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_questions" ADD CONSTRAINT "questionnaire_questions_control_id_fkey" FOREIGN KEY ("control_id") REFERENCES "controls"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_questions" ADD CONSTRAINT "questionnaire_questions_framework_id_fkey" FOREIGN KEY ("framework_id") REFERENCES "frameworks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_responses" ADD CONSTRAINT "questionnaire_responses_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_responses" ADD CONSTRAINT "questionnaire_responses_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_responses" ADD CONSTRAINT "questionnaire_responses_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questionnaire_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questionnaire_responses" ADD CONSTRAINT "questionnaire_responses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_memories" ADD CONSTRAINT "agent_memories_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_memories" ADD CONSTRAINT "agent_memories_evidence_id_fkey" FOREIGN KEY ("evidence_id") REFERENCES "evidence"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_memories" ADD CONSTRAINT "agent_memories_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_tasks" ADD CONSTRAINT "compliance_tasks_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_tasks" ADD CONSTRAINT "compliance_tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_tasks" ADD CONSTRAINT "compliance_tasks_source_document_id_fkey" FOREIGN KEY ("source_document_id") REFERENCES "evidence"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tech_stack_discrepancies" ADD CONSTRAINT "tech_stack_discrepancies_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlTags" ADD CONSTRAINT "_ControlTags_A_fkey" FOREIGN KEY ("A") REFERENCES "controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlTags" ADD CONSTRAINT "_ControlTags_B_fkey" FOREIGN KEY ("B") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlToThreatTemplate" ADD CONSTRAINT "_ControlToThreatTemplate_A_fkey" FOREIGN KEY ("A") REFERENCES "controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlToThreatTemplate" ADD CONSTRAINT "_ControlToThreatTemplate_B_fkey" FOREIGN KEY ("B") REFERENCES "threat_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlToVulnerabilityTemplate" ADD CONSTRAINT "_ControlToVulnerabilityTemplate_A_fkey" FOREIGN KEY ("A") REFERENCES "controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ControlToVulnerabilityTemplate" ADD CONSTRAINT "_ControlToVulnerabilityTemplate_B_fkey" FOREIGN KEY ("B") REFERENCES "vulnerability_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_DocumentTypeTags" ADD CONSTRAINT "_DocumentTypeTags_A_fkey" FOREIGN KEY ("A") REFERENCES "document_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_DocumentTypeTags" ADD CONSTRAINT "_DocumentTypeTags_B_fkey" FOREIGN KEY ("B") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_EvidenceTags" ADD CONSTRAINT "_EvidenceTags_A_fkey" FOREIGN KEY ("A") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_EvidenceTags" ADD CONSTRAINT "_EvidenceTags_B_fkey" FOREIGN KEY ("B") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_EvidenceToProjectControl" ADD CONSTRAINT "_EvidenceToProjectControl_A_fkey" FOREIGN KEY ("A") REFERENCES "evidence"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_EvidenceToProjectControl" ADD CONSTRAINT "_EvidenceToProjectControl_B_fkey" FOREIGN KEY ("B") REFERENCES "project_controls"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ChunkTags" ADD CONSTRAINT "_ChunkTags_A_fkey" FOREIGN KEY ("A") REFERENCES "document_chunks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ChunkTags" ADD CONSTRAINT "_ChunkTags_B_fkey" FOREIGN KEY ("B") REFERENCES "tags"("id") ON DELETE CASCADE ON UPDATE CASCADE;
