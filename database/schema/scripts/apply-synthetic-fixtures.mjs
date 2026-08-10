// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import "dotenv/config";
import { randomBytes, randomUUID } from "node:crypto";
import { chmod, mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { execFileSync } from "node:child_process";
import bcrypt from "bcryptjs";
import pg from "pg";

const { Client } = pg;
const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error("DATABASE_URL is required.");

const credentialPath = resolve(process.env.DEMO_CREDENTIALS_FILE || ".runtime/demo-credentials.json");
const accounts = [
  { email: "admin@tenant-alpha.example.invalid", name: "Alpha Administrator", role: "admin" },
  { email: "manager@tenant-alpha.example.invalid", name: "Alpha Manager", role: "manager" },
  { email: "auditor@tenant-alpha.example.invalid", name: "Alpha Auditor", role: "auditor" },
  { email: "customer@tenant-alpha.example.invalid", name: "Alpha Customer", role: "customer" },
  { email: "manager@tenant-beta.example.invalid", name: "Beta Manager", role: "manager" },
  { email: "customer@tenant-beta.example.invalid", name: "Beta Customer", role: "customer" },
];

const credentials = [];
const accountIds = new Map();
const tenantFixtures = [
  {
    label: "Alpha",
    customerEmail: "customer@tenant-alpha.example.invalid",
    projectId: "10000000-0000-4000-8000-000000000001",
    evidenceId: "20000000-0000-4000-8000-000000000001",
    linkId: "30000000-0000-4000-8000-000000000001",
  },
  {
    label: "Beta",
    customerEmail: "customer@tenant-beta.example.invalid",
    projectId: "10000000-0000-4000-8000-000000000002",
    evidenceId: "20000000-0000-4000-8000-000000000002",
    linkId: "30000000-0000-4000-8000-000000000002",
  },
];
const client = new Client({ connectionString: databaseUrl });
await client.connect();
try {
  await client.query("BEGIN");
  for (const account of accounts) {
    const password = randomBytes(24).toString("base64url");
    const passwordHash = await bcrypt.hash(password, 12);
    const id = randomUUID();
    const result = await client.query(
      `INSERT INTO "users" ("id", "name", "email", "password", "role", "status", "created_at", "updated_at")
       VALUES ($1, $2, $3, $4, $5::"UserRole", 'Active'::"UserStatus", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
       ON CONFLICT ("email") DO UPDATE SET "name" = EXCLUDED."name", "role" = EXCLUDED."role", "password" = EXCLUDED."password", "updated_at" = CURRENT_TIMESTAMP
       RETURNING "id"`,
      [id, account.name, account.email, passwordHash, account.role],
    );
    accountIds.set(account.email, result.rows[0].id);
    credentials.push({ email: account.email, role: account.role, password });
    console.log(`Synthetic account ready: ${account.email} (${account.role})`);
  }

  for (const fixture of tenantFixtures) {
    const customerId = accountIds.get(fixture.customerEmail);
    await client.query(
      `INSERT INTO "projects" ("id", "name", "customer_name", "customer_id", "is_demo", "created_at", "updated_at")
       VALUES ($1, $2, $3, $4, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
       ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "customer_name" = EXCLUDED."customer_name", "customer_id" = EXCLUDED."customer_id", "is_demo" = TRUE, "updated_at" = CURRENT_TIMESTAMP`,
      [fixture.projectId, `${fixture.label} ISO 27001 Demonstration`, `${fixture.label} Synthetic Tenant`, customerId],
    );
    await client.query(
      `INSERT INTO "evidence" ("id", "customer_id", "file_name", "uploaded_by_id", "is_demo", "created_at", "updated_at")
       VALUES ($1, $2, 'iso-27001-sample.pdf', $2, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
       ON CONFLICT ("id") DO UPDATE SET "customer_id" = EXCLUDED."customer_id", "uploaded_by_id" = EXCLUDED."uploaded_by_id", "is_demo" = TRUE, "updated_at" = CURRENT_TIMESTAMP`,
      [fixture.evidenceId, customerId],
    );
    await client.query(
      `INSERT INTO "project_evidence_links" ("id", "project_id", "evidence_id", "customer_id", "added_by_id", "created_at")
       VALUES ($1, $2, $3, $4, $4, CURRENT_TIMESTAMP)
       ON CONFLICT ("project_id", "evidence_id") DO UPDATE SET "customer_id" = EXCLUDED."customer_id", "added_by_id" = EXCLUDED."added_by_id"`,
      [fixture.linkId, fixture.projectId, fixture.evidenceId, customerId],
    );
    console.log(`Synthetic tenant fixture ready: ${fixture.label} (project, evidence, link)`);
  }

  await client.query("SAVEPOINT cross_tenant_check");
  try {
    await client.query(
      `INSERT INTO "project_evidence_links" ("id", "project_id", "evidence_id", "customer_id", "added_by_id", "created_at")
       VALUES ($1, $2, $3, $4, $4, CURRENT_TIMESTAMP)`,
      [randomUUID(), tenantFixtures[0].projectId, tenantFixtures[1].evidenceId, accountIds.get(tenantFixtures[0].customerEmail)],
    );
    throw new Error("Cross-tenant evidence link was accepted; tenant isolation is not enforced.");
  } catch (error) {
    await client.query("ROLLBACK TO SAVEPOINT cross_tenant_check");
    if (error.code !== "23503") throw error;
    console.log("Tenant isolation check passed: cross-tenant evidence link rejected.");
  }
  await client.query("RELEASE SAVEPOINT cross_tenant_check");
  await client.query("COMMIT");
} catch (error) {
  await client.query("ROLLBACK");
  throw error;
} finally {
  await client.end();
}

await mkdir(dirname(credentialPath), { recursive: true });
await writeFile(credentialPath, `${JSON.stringify({ generatedAt: new Date().toISOString(), accounts: credentials }, null, 2)}\n`, {
  encoding: "utf8",
  mode: 0o600,
});
await chmod(credentialPath, 0o600);
if (process.platform === "win32") {
  const username = process.env.USERNAME;
  if (!username) throw new Error("USERNAME is required to restrict the credential file ACL on Windows.");
  execFileSync("icacls", [credentialPath, "/inheritance:r", "/grant:r", `${username}:(R,W)`], {
    stdio: "ignore",
  });
}
console.log(`Credentials saved to restricted local file: ${credentialPath}`);
