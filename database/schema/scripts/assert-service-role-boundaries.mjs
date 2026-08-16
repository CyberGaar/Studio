// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import "dotenv/config";
import { randomBytes } from "node:crypto";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import pg from "pg";

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error("DATABASE_URL is required.");
const contract = JSON.parse(await readFile(resolve("../contracts/service-access.json"), "utf8"));
const identifier = (value) => {
  if (!/^[a-z_][a-z0-9_]*$/.test(value)) throw new Error(`Unsafe SQL identifier: ${value}`);
  return `"${value}"`;
};
const literal = (value) => `'${value.replaceAll("'", "''")}'`;
const expectDenied = async (operation, label) => {
  try {
    await operation();
  } catch (error) {
    if (error.code === "42501") return;
    throw error;
  }
  throw new Error(`Expected permission denial: ${label}`);
};

const admin = new pg.Client({ connectionString: databaseUrl });
await admin.connect();
try {
  for (const service of contract.services) {
    const suffix = randomBytes(6).toString("hex");
    const loginRole = `cybergaar_test_${suffix}`;
    const password = randomBytes(24).toString("base64url");
    await admin.query(`CREATE ROLE ${identifier(loginRole)} LOGIN PASSWORD ${literal(password)} NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`);
    await admin.query(`GRANT ${identifier(service.role)} TO ${identifier(loginRole)}`);
    const serviceUrl = new URL(databaseUrl);
    serviceUrl.username = loginRole;
    serviceUrl.password = password;
    const client = new pg.Client({ connectionString: serviceUrl.toString() });
    try {
      await client.connect();
      const allowedTable = service.allTables ? "users" : service.read[0];
      await client.query(`SELECT 1 FROM ${identifier(allowedTable)} LIMIT 0`);
      await expectDenied(
        () => client.query(`CREATE TABLE ${identifier(`unauthorized_${suffix}`)} (id integer)`),
        `${service.service} schema creation`,
      );
      await expectDenied(
        () => client.query(`SET ROLE ${identifier(contract.migrationRole)}`),
        `${service.service} migration-role escalation`,
      );
      if (service.deniedProbe !== "schema:create") {
        await expectDenied(
          () => client.query(`SELECT 1 FROM ${identifier(service.deniedProbe)} LIMIT 0`),
          `${service.service} unrelated table access`,
        );
      }
      if (service.deniedColumnUpdate) {
        const { table, column } = service.deniedColumnUpdate;
        await expectDenied(
          () => client.query(`UPDATE ${identifier(table)} SET ${identifier(column)} = ${identifier(column)} WHERE FALSE`),
          `${service.service} unauthorized column update`,
        );
      }
      if (!service.allTables && service.write.length === 0) {
        await expectDenied(
          () => client.query(`DELETE FROM ${identifier(allowedTable)} WHERE FALSE`),
          `${service.service} read-only table write`,
        );
      }
      console.log(`Role boundary passed: ${service.service}`);
    } finally {
      await client.end().catch(() => {});
      await admin.query(`DROP OWNED BY ${identifier(loginRole)}`);
      await admin.query(`DROP ROLE ${identifier(loginRole)}`);
    }
  }

  const suffix = randomBytes(6).toString("hex");
  const loginRole = `cybergaar_test_${suffix}`;
  const password = randomBytes(24).toString("base64url");
  await admin.query(`CREATE ROLE ${identifier(loginRole)} LOGIN PASSWORD ${literal(password)} NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`);
  await admin.query(`GRANT ${identifier(contract.migrationRole)} TO ${identifier(loginRole)}`);
  const migrationUrl = new URL(databaseUrl);
  migrationUrl.username = loginRole;
  migrationUrl.password = password;
  const migrator = new pg.Client({ connectionString: migrationUrl.toString() });
  try {
    await migrator.connect();
    const table = `migration_probe_${suffix}`;
    await migrator.query(`CREATE TABLE ${identifier(table)} (id integer)`);
    await migrator.query(`DROP TABLE ${identifier(table)}`);
    console.log("Role boundary passed: backend migration owner");
  } finally {
    await migrator.end().catch(() => {});
    await admin.query(`DROP OWNED BY ${identifier(loginRole)}`);
    await admin.query(`DROP ROLE ${identifier(loginRole)}`);
  }
} finally {
  await admin.end();
}
