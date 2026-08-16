// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(fileURLToPath(import.meta.url));
const contract = JSON.parse(await readFile(resolve(root, "../service-access.json"), "utf8"));
const schema = await readFile(resolve(root, "../../schema/prisma/schema.prisma"), "utf8");
// Git may materialize platform-specific line endings; contracts pin canonical LF bytes.
const schemaHash = createHash("sha256").update(schema.replace(/\r\n/g, "\n")).digest("hex");
if (schemaHash !== contract.schemaSha256) throw new Error("Canonical Prisma schema hash differs from the published contract.");
if (!/^\d+\.\d+\.\d+$/.test(contract.contractVersion)) throw new Error("Contract version is not SemVer.");

const baseline = await readFile(resolve(root, "../../schema/prisma/migrations/20260809_000000_canonical_baseline/migration.sql"), "utf8");
const tables = new Set([...baseline.matchAll(/^CREATE TABLE "([^"]+)"/gm)].map((match) => match[1]));
const roles = new Set([contract.migrationRole]);
const services = new Set();
for (const service of contract.services) {
  if (services.has(service.service)) throw new Error(`Duplicate service contract: ${service.service}`);
  if (roles.has(service.role)) throw new Error(`Duplicate or privileged application role: ${service.role}`);
  services.add(service.service);
  roles.add(service.role);
  if (service.role === contract.migrationRole) throw new Error(`${service.service} may not use the migration role.`);
  if (!service.deniedProbe) throw new Error(`${service.service} requires a denied access probe.`);
  const referenced = [...service.read, ...service.write, ...Object.keys(service.columnUpdates || {})];
  for (const table of referenced) {
    if (!tables.has(table)) throw new Error(`${service.service} references unknown table ${table}.`);
  }
  if (!service.allTables && service.deniedProbe !== "schema:create" && !tables.has(service.deniedProbe)) {
    throw new Error(`${service.service} denied probe references unknown table ${service.deniedProbe}.`);
  }
  if (service.write.some((table) => !service.read.includes(table))) {
    throw new Error(`${service.service} write permissions must also declare read access.`);
  }
  if (service.deniedColumnUpdate && !service.read.includes(service.deniedColumnUpdate.table)) {
    throw new Error(`${service.service} denied column probe must target a readable table.`);
  }
}
if (contract.services.filter(({ allTables }) => allTables).length !== 1 || !contract.services.find(({ service }) => service === "backend")?.allTables) {
  throw new Error("Backend must be the only all-table application role.");
}
console.log(`Data contract ${contract.contractVersion} validates against ${tables.size} canonical tables.`);
