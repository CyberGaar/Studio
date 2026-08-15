// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import "dotenv/config";
import { defineConfig } from "prisma/config";

// Offline schema commands need a provider URL. This non-routable fallback has no
// password and causes every command that actually connects to fail closed.
const databaseUrl = process.env.DATABASE_URL ?? "postgresql://invalid@127.0.0.1:1/invalid";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: { url: databaseUrl },
});
