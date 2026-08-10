// SPDX-FileCopyrightText: 2026 CyberGaar (Omer Rastgar)
// SPDX-License-Identifier: AGPL-3.0-or-later

import { execFileSync } from "node:child_process";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const packageRoot = fileURLToPath(new URL("../", import.meta.url));
const prismaEntryPoint = resolve(packageRoot, "node_modules/prisma/build/index.js");
const temporary = await mkdtemp(join(tmpdir(), "cybergaar-prisma-baseline-"));
const generatedPath = join(temporary, "migration.sql");
const committedPath = resolve(packageRoot, "prisma/migrations/20260809_000000_canonical_baseline/migration.sql");

try {
  execFileSync(
    process.execPath,
    [prismaEntryPoint, "migrate", "diff", "--from-empty", "--to-schema=prisma/schema.prisma", "--script", `--output=${generatedPath}`],
    { cwd: packageRoot, stdio: "inherit" },
  );
  const generated = await readFile(generatedPath, "utf8");
  const committed = await readFile(committedPath, "utf8");
  const withoutSpdx = committed.replace(
    /^-- SPDX-FileCopyrightText:[^\r\n]*\r?\n-- SPDX-License-Identifier:[^\r\n]*\r?\n\r?\n/,
    "",
  ).replace(
    /\r?\n-- RequiredExtension\r?\nCREATE EXTENSION IF NOT EXISTS "vector";\r?\n/,
    "",
  );
  if (generated.replace(/\r\n/g, "\n") !== withoutSpdx.replace(/\r\n/g, "\n")) {
    throw new Error("Canonical baseline differs from Prisma's deterministic schema output.");
  }
  console.log("Canonical Prisma baseline is reproducible.");
} finally {
  await rm(temporary, { recursive: true, force: true });
}
