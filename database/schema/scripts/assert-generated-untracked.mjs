// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { execFileSync } from "node:child_process";

const output = execFileSync("git", ["status", "--porcelain=v1", "--", "database/schema/generated"], {
  cwd: new URL("../../..", import.meta.url),
  encoding: "utf8",
});

if (output.trim()) {
  throw new Error("Generated Prisma client output must remain untracked.");
}

console.log("Generated Prisma client output is ignored and untracked.");
