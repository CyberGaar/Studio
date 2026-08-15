// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const contractPath = resolve(root, "../service-access.json");
const outputPath = resolve(root, "../../schema/sql/service-roles.sql");
const contract = JSON.parse(await readFile(contractPath, "utf8"));
const identifier = (value) => {
  if (!/^[a-z_][a-z0-9_]*$/.test(value)) throw new Error(`Unsafe SQL identifier: ${value}`);
  return `"${value}"`;
};
const list = (values) => values.map(identifier).join(", ");
const roles = [contract.migrationRole, ...contract.services.map(({ role }) => role)];
const lines = [
  "-- SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)",
  "-- SPDX-License-Identifier: AGPL-3.0-or-later",
  "",
  "-- Generated from database/contracts/service-access.json. Do not edit manually.",
  "-- Login roles are environment-owned and receive membership in exactly one group role.",
  "",
];

for (const role of roles) {
  identifier(role);
  lines.push(
    "DO $role$",
    "BEGIN",
    `  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '${role}') THEN`,
    `    CREATE ROLE ${identifier(role)} NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;`,
    "  END IF;",
    "END",
    "$role$;",
    "",
  );
}

lines.push(
  "REVOKE CREATE ON SCHEMA public FROM PUBLIC;",
  "REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;",
  "REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;",
  `GRANT USAGE, CREATE ON SCHEMA public TO ${identifier(contract.migrationRole)};`,
  "",
);

for (const service of contract.services) {
  const role = identifier(service.role);
  lines.push(`GRANT USAGE ON SCHEMA public TO ${role};`);
  lines.push(`REVOKE CREATE ON SCHEMA public FROM ${role};`);
  lines.push(`REVOKE ${identifier(contract.migrationRole)} FROM ${role};`);
  if (service.allTables) {
    lines.push(`GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO ${role};`);
    lines.push(`GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO ${role};`);
    lines.push(`ALTER DEFAULT PRIVILEGES FOR ROLE ${identifier(contract.migrationRole)} IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${role};`);
    lines.push(`ALTER DEFAULT PRIVILEGES FOR ROLE ${identifier(contract.migrationRole)} IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO ${role};`);
  } else {
    if (service.read.length) lines.push(`GRANT SELECT ON TABLE ${list(service.read)} TO ${role};`);
    if (service.write.length) {
      lines.push(`GRANT INSERT, UPDATE, DELETE ON TABLE ${list(service.write)} TO ${role};`);
    }
    for (const [table, columns] of Object.entries(service.columnUpdates || {})) {
      lines.push(`GRANT UPDATE (${list(columns)}) ON TABLE ${identifier(table)} TO ${role};`);
    }
  }
  lines.push("");
}

const generated = `${lines.join("\n").trimEnd()}\n`;
if (process.argv.includes("--check")) {
  const committed = await readFile(outputPath, "utf8").catch(() => "");
  if (committed.replace(/\r\n/g, "\n") !== generated) {
    throw new Error("Generated service role SQL is missing or stale.");
  }
  console.log("Service role SQL is reproducible.");
} else {
  await mkdir(dirname(outputPath), { recursive: true });
  await writeFile(outputPath, generated, "utf8");
  console.log(`Generated ${outputPath}`);
}
