#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(SCRIPT_DIR, "..");
const AUDIT_SCRIPT = join(SCRIPT_DIR, "audit-upstream-grammar.js");

const missingPath = join(SCRIPT_DIR, "__missing-bird-source__");
const cases = [
  {
    paths: [REPO_ROOT, missingPath],
    invalidPath: missingPath,
    message: "BIRD source path does not exist",
  },
  {
    paths: [join(REPO_ROOT, "grammars", "bird2.tmLanguage.json")],
    invalidPath: join(REPO_ROOT, "grammars", "bird2.tmLanguage.json"),
    message: "BIRD source path is not a directory",
  },
];

for (const check of cases) {
  const result = spawnSync(process.execPath, [AUDIT_SCRIPT, ...check.paths], {
    encoding: "utf8",
  });

  if (result.error) throw result.error;
  if (result.status !== 2) {
    throw new Error(
      `Expected audit exit code 2 for ${check.invalidPath}, got ${result.status}: ${result.stderr}`,
    );
  }
  if (
    !result.stderr.includes(check.message) ||
    !result.stderr.includes(check.invalidPath)
  ) {
    throw new Error(`Unexpected audit error for ${check.invalidPath}: ${result.stderr}`);
  }
  if (result.stdout !== "") {
    throw new Error(`Audit produced partial output before validation: ${result.stdout}`);
  }
}

console.log("Upstream audit CLI error checks passed.");
