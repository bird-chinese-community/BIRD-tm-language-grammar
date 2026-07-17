#!/usr/bin/env node

import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  writeFileSync,
} from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const TRACKS = {
  tm: {
    asset: "bird2.tmLanguage.json",
    kind: "TextMate Grammar",
    path: "grammars/bird2.tmLanguage.json",
  },
  vim: {
    asset: "bird2.syntax.vim",
    kind: "Vim Syntax",
    path: "grammars/bird2.syntax.vim",
  },
};

function fail(message) {
  throw new Error(message);
}

function runGit(args, options = {}) {
  return execFileSync("git", args, {
    cwd: ROOT,
    stdio: options.capture === false ? "inherit" : "pipe",
    ...options,
  });
}

function parseTag(tag) {
  const match = /^(tm|vim)-v(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?)$/.exec(tag);
  if (!match) {
    fail(`tag must use tm-v<version> or vim-v<version>: ${tag}`);
  }
  return { tag, track: match[1], version: match[2], ...TRACKS[match[1]] };
}

function treeEntry(ref, path) {
  const line = runGit(["ls-tree", ref, "--", path]).toString("utf8").trim();
  const match = /^(\d+)\s+(\w+)\s+([0-9a-f]+)\t(.+)$/.exec(line);
  if (!match || match[4] !== path) fail(`${ref} does not contain ${path}`);
  return { mode: match[1], type: match[2], object: match[3], path: match[4] };
}

function tagBlob(tag, path) {
  return runGit(["show", `${tag}:${path}`]);
}

function vimAsset(tag, path) {
  const entry = treeEntry(tag, path);
  if (entry.mode === "100644" && entry.type === "blob") {
    return tagBlob(tag, path);
  }
  if (entry.mode !== "120000" || entry.type !== "blob") {
    fail(`${tag}:${path} must be a regular file or symlink`);
  }

  const submoduleEntry = treeEntry(tag, "external/bird2.vim");
  if (submoduleEntry.mode !== "160000" || submoduleEntry.type !== "commit") {
    fail(`${tag}:external/bird2.vim is not a Git submodule`);
  }
  const submoduleRoot = join(ROOT, "external", "bird2.vim");
  if (!existsSync(join(submoduleRoot, ".git"))) {
    fail("external/bird2.vim is not initialized; run git submodule update --init");
  }
  try {
    execFileSync("git", ["cat-file", "-e", `${submoduleEntry.object}^{commit}`], {
      cwd: submoduleRoot,
      stdio: "pipe",
    });
  } catch {
    execFileSync("git", ["fetch", "origin", submoduleEntry.object], {
      cwd: submoduleRoot,
      stdio: "inherit",
    });
  }
  return execFileSync(
    "git",
    ["show", `${submoduleEntry.object}:syntax/bird2.vim`],
    { cwd: submoduleRoot, stdio: "pipe" },
  );
}

function assetVersion(metadata, bytes) {
  const source = bytes.toString("utf8");
  if (metadata.track === "tm") {
    const parsed = JSON.parse(source);
    if (typeof parsed.version !== "string") {
      fail(`${metadata.path} does not contain a string version`);
    }
    return parsed.version;
  }
  const match = /^" Version:\s+([^\s]+)\s*$/m.exec(source);
  if (!match) fail(`${metadata.path} does not contain a Version line`);
  return match[1];
}

function exportAsset(tag, outputArgument = "dist") {
  const metadata = parseTag(tag);
  runGit(["rev-parse", "--verify", `refs/tags/${tag}^{commit}`]);
  const bytes = metadata.track === "vim"
    ? vimAsset(tag, metadata.path)
    : tagBlob(tag, metadata.path);
  const actualVersion = assetVersion(metadata, bytes);
  if (actualVersion !== metadata.version) {
    fail(`tag ${tag} does not match asset version ${actualVersion}`);
  }

  const output = resolve(ROOT, outputArgument);
  mkdirSync(output, { recursive: true });
  const assetPath = join(output, metadata.asset);
  writeFileSync(assetPath, bytes);
  const sha256 = createHash("sha256").update(bytes).digest("hex");
  const prerelease = /(?:^|[.-])(?:alpha|beta|rc)(?:[.-]|$)/i.test(metadata.version);
  return {
    ...metadata,
    assetPath,
    latest: metadata.track === "vim" && !prerelease,
    prerelease,
    sha256,
  };
}

function writeOutputs(metadata) {
  const output = process.env.GITHUB_OUTPUT;
  if (!output) fail("GITHUB_OUTPUT is required for gha-outputs");
  const lines = [
    `tag=${metadata.tag}`,
    `track=${metadata.track}`,
    `version=${metadata.version}`,
    `title=${metadata.kind} ${metadata.version}`,
    `asset=${metadata.assetPath}`,
    `asset_name=${metadata.asset}`,
    `prerelease=${metadata.prerelease}`,
    `latest=${metadata.latest}`,
    `sha256=${metadata.sha256}`,
  ];
  writeFileSync(output, `${lines.join("\n")}\n`, { flag: "a" });
}

function main() {
  const [command, tag, output] = process.argv.slice(2);
  if (!command || !tag) {
    fail("usage: export-release-asset.mjs <export|gha-outputs> <tag> [output]");
  }
  const metadata = exportAsset(tag, output);
  if (command === "gha-outputs") writeOutputs(metadata);
  else if (command !== "export") fail(`unknown command: ${command}`);
  process.stdout.write(`${JSON.stringify(metadata, null, 2)}\n`);
}

try {
  main();
} catch (error) {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
}
