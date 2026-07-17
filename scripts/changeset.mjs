#!/usr/bin/env node

import {
  existsSync,
  readFileSync,
  readdirSync,
  renameSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import {
  dirname,
  isAbsolute,
  join,
  relative,
  resolve,
  sep,
} from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CHANGESET_DIR = join(ROOT, ".changeset");
const CONFIG_PATH = join(CHANGESET_DIR, "config.json");
const RELEASE_MARKER = "<!-- changeset-release-marker -->";
const BUMPS = ["patch", "minor", "major"];

function fail(message) {
  throw new Error(message);
}

function repositoryPath(value, label) {
  if (typeof value !== "string" || value.length === 0 || isAbsolute(value)) {
    fail(`${label} must be a non-empty repository-relative path`);
  }
  const target = resolve(ROOT, value);
  const fromRoot = relative(ROOT, target);
  if (fromRoot === ".." || isAbsolute(fromRoot) || fromRoot.startsWith(`..${sep}`)) {
    fail(`${label} must stay inside the repository`);
  }
  return target;
}

function readConfig() {
  let config;
  try {
    config = JSON.parse(readFileSync(CONFIG_PATH, "utf8"));
  } catch (error) {
    fail(`Cannot read .changeset/config.json: ${error.message}`);
  }

  if (typeof config.project !== "string" || config.project.length === 0) {
    fail("config.project must be a non-empty string");
  }
  repositoryPath(config.changelog, "config.changelog");
  if (config.releaseLink !== undefined && typeof config.releaseLink !== "string") {
    fail("config.releaseLink must be a string when provided");
  }
  if (config.releaseLink !== undefined && !config.releaseLink.includes("{version}")) {
    fail("config.releaseLink must contain the {version} placeholder");
  }
  if (!Array.isArray(config.categories) || config.categories.length === 0) {
    fail("config.categories must be a non-empty array");
  }

  const ids = new Set();
  for (const category of config.categories) {
    if (
      !category ||
      typeof category.id !== "string" ||
      !/^[a-z][a-z0-9-]*$/.test(category.id) ||
      typeof category.heading !== "string" ||
      category.heading.length === 0
    ) {
      fail("each changelog category needs a valid id and heading");
    }
    if (ids.has(category.id)) fail(`duplicate category id: ${category.id}`);
    ids.add(category.id);
  }

  return { ...config, categoryIds: ids };
}

function validateBilingualBody(name, body) {
  const lines = body.split("\n");
  const title = lines[0];
  const firstBold = title.indexOf("**");
  const separator = title.indexOf("** / **", firstBold + 2);
  if (
    !title.startsWith("- ") ||
    firstBold <= 2 ||
    separator < 0 ||
    !title.endsWith("**")
  ) {
    fail(`${name}: title must use "- emoji **中文标题** / **English title**"`);
  }

  const icon = title.slice(2, firstBold).trim();
  const chineseTitle = title.slice(firstBold + 2, separator);
  const englishTitle = title.slice(separator + "** / **".length, -2);
  if (!/\p{Extended_Pictographic}/u.test(icon)) {
    fail(`${name}: title must start with an emoji`);
  }
  if (!/\p{Script=Han}/u.test(chineseTitle)) {
    fail(`${name}: title must include a Simplified Chinese title first`);
  }
  if (!/[A-Za-z]/.test(englishTitle)) {
    fail(`${name}: title must include an English title second`);
  }

  const paragraphs = [];
  let current = [];
  for (const line of lines.slice(1)) {
    if (line.trim() === "") {
      if (current.length > 0) paragraphs.push(current.join("\n"));
      current = [];
      continue;
    }
    if (!line.startsWith("  ")) {
      fail(`${name}: paragraphs below the list item must use two-space indentation`);
    }
    current.push(line.slice(2));
  }
  if (current.length > 0) paragraphs.push(current.join("\n"));
  if (paragraphs.length < 2) {
    fail(`${name}: add a Chinese paragraph followed by an English paragraph`);
  }
  if (!/\p{Script=Han}/u.test(paragraphs[0])) {
    fail(`${name}: first paragraph must be Simplified Chinese`);
  }
  if (!/[A-Za-z]/.test(paragraphs[paragraphs.length - 1])) {
    fail(`${name}: final paragraph must be English`);
  }
}

function parseFragment(name, source, config) {
  const normalized = source.replace(/\r\n/g, "\n");
  const lines = normalized.split("\n");
  if (lines[0] !== "---") fail(`${name}: missing opening frontmatter delimiter`);
  const closing = lines.indexOf("---", 1);
  if (closing < 0) fail(`${name}: missing closing frontmatter delimiter`);

  const metadata = {};
  for (const line of lines.slice(1, closing)) {
    if (line.trim() === "") continue;
    const match = /^([a-z][a-z0-9-]*):\s*(\S(?:.*\S)?)\s*$/.exec(line);
    if (!match) fail(`${name}: invalid frontmatter line: ${line}`);
    if (metadata[match[1]] !== undefined) {
      fail(`${name}: duplicate frontmatter key: ${match[1]}`);
    }
    metadata[match[1]] = match[2];
  }

  const allowed = new Set(["bump", "category"]);
  for (const key of Object.keys(metadata)) {
    if (!allowed.has(key)) fail(`${name}: unsupported frontmatter key: ${key}`);
  }
  if (!BUMPS.includes(metadata.bump)) {
    fail(`${name}: bump must be one of ${BUMPS.join(", ")}`);
  }
  if (!config.categoryIds.has(metadata.category)) {
    fail(`${name}: unknown category: ${metadata.category}`);
  }

  const body = lines.slice(closing + 1).join("\n").trim();
  if (!body) fail(`${name}: release-note body must not be empty`);
  if (!body.startsWith("- ")) fail(`${name}: release-note body must start with a list item`);
  if (body.includes(RELEASE_MARKER)) fail(`${name}: release marker is not allowed in fragment body`);
  const placeholders = ["中文标题", "English title", "中文说明。", "English summary."];
  if (placeholders.some((placeholder) => body.includes(placeholder))) {
    fail(`${name}: replace all generated template placeholders`);
  }
  validateBilingualBody(name, body);

  return { name, bump: metadata.bump, category: metadata.category, body };
}

function readFragments(config) {
  const names = readdirSync(CHANGESET_DIR, { withFileTypes: true })
    .filter((entry) => entry.name.endsWith(".md") && entry.name !== "README.md")
    .map((entry) => {
      if (!entry.isFile()) fail(`${entry.name}: changesets must be regular files`);
      return entry.name;
    })
    .sort();

  return names.map((name) => {
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*\.md$/.test(name)) {
      fail(`${name}: filename must be kebab-case`);
    }
    return parseFragment(name, readFileSync(join(CHANGESET_DIR, name), "utf8"), config);
  });
}

function readChangelog(config) {
  const changelogPath = repositoryPath(config.changelog, "config.changelog");
  const changelog = readFileSync(changelogPath, "utf8");
  const markers = changelog.split(RELEASE_MARKER).length - 1;
  if (markers !== 1) {
    fail(`${config.changelog} must contain exactly one ${RELEASE_MARKER}`);
  }
  return { changelog, changelogPath };
}

function versionHeadingPattern(version, command) {
  if (!/^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/.test(version)) {
    fail(`${command} requires a semantic version`);
  }
  const escaped = version.replace(/\./g, "\\.");
  return new RegExp(
    `^## (?:\\[${escaped}\\]|${escaped}) - \\d{4}-\\d{2}-\\d{2}\\s*$`,
  );
}

function findVersionStart(lines, version, command) {
  const heading = versionHeadingPattern(version, command);
  return lines.findIndex((line) => heading.test(line));
}

function stripTrailingLinkDefinitions(lines) {
  let end = lines.length;
  while (end > 0 && lines[end - 1].trim() === "") end -= 1;

  while (end > 0) {
    const line = lines[end - 1].trim();
    const delimiter = line.indexOf("]:");
    const isLinkDefinition =
      line.startsWith("[") &&
      delimiter > 1 &&
      line.slice(delimiter + 2).trim().length > 0;
    if (!isLinkDefinition) break;
    end -= 1;
    while (end > 0 && lines[end - 1].trim() === "") end -= 1;
  }

  return lines.slice(0, end);
}

function notesFor(changelog, version) {
  const lines = changelog.replace(/\r\n/g, "\n").split("\n");
  const start = findVersionStart(lines, version, "notes");
  if (start < 0) fail(`CHANGELOG does not contain version ${version}`);
  const next = lines.findIndex(
    (line, index) => index > start && line.trimEnd().startsWith("## "),
  );
  const noteLines = stripTrailingLinkDefinitions(
    lines.slice(start + 1, next < 0 ? undefined : next),
  );
  const notes = noteLines.join("\n").trim();
  if (!notes) fail(`CHANGELOG version ${version} has no release notes`);
  return notes;
}

function recommendedBump(fragments) {
  return fragments.reduce(
    (highest, fragment) =>
      BUMPS.indexOf(fragment.bump) > BUMPS.indexOf(highest) ? fragment.bump : highest,
    "patch",
  );
}

function sectionFor(version, date, config, fragments) {
  const sections = [`## [${version}] - ${date}`];
  for (const category of config.categories) {
    const matching = fragments.filter((fragment) => fragment.category === category.id);
    if (matching.length === 0) continue;
    sections.push(`### ${category.heading}`);
    sections.push(matching.map((fragment) => fragment.body).join("\n\n"));
  }
  return sections.join("\n\n");
}

function runRegressionChecks() {
  const fixture = [
    "## [1.0.14] - 2026-07-18",
    "",
    "New notes.",
    "",
    "## [1.0.13] - 2026-07-17  ",
    "",
    "Old notes.",
    "",
    "[1.0.14]: https://example.invalid/1.0.14",
    "[1.0.13]: https://example.invalid/1.0.13",
    "",
  ].join("\n");
  if (notesFor(fixture, "1.0.13") !== "Old notes.") {
    fail("internal regression: notes must exclude trailing link definitions");
  }
  const lines = fixture.split("\n");
  if (findVersionStart(lines, "1.0.1", "check") >= 0) {
    fail("internal regression: version matching must not use prefixes");
  }
  if (findVersionStart(lines, "1.0.13", "check") < 0) {
    fail("internal regression: bracketed headings must be detected");
  }
  const section = sectionFor(
    "1.0.1",
    "2026-07-18",
    { categories: [{ id: "fixed", heading: "🐛 Fixed / 修复" }] },
    [{ category: "fixed", body: "- 🐛 **修复** / **Fix**" }],
  );
  if (!section.startsWith("## [1.0.1] - 2026-07-18")) {
    fail("internal regression: generated headings must use brackets");
  }
}

function today() {
  const now = new Date();
  const year = String(now.getUTCFullYear());
  const month = String(now.getUTCMonth() + 1).padStart(2, "0");
  const day = String(now.getUTCDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function help() {
  process.stdout.write(`Usage: node scripts/changeset.mjs <command>\n\nCommands:\n  new <slug> <patch|minor|major> <category>\n  check\n  status\n  notes <version>\n  release <version> [--date YYYY-MM-DD] [--dry-run]\n`);
}

function createFragment(args, config) {
  if (args.length !== 3) fail("new requires <slug> <bump> <category>");
  const [slug, bump, category] = args;
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug)) fail("slug must be kebab-case");
  if (!BUMPS.includes(bump)) fail(`bump must be one of ${BUMPS.join(", ")}`);
  if (!config.categoryIds.has(category)) fail(`unknown category: ${category}`);

  const target = join(CHANGESET_DIR, `${slug}.md`);
  if (existsSync(target)) fail(`changeset already exists: ${slug}.md`);
  const categoryConfig = config.categories.find((item) => item.id === category);
  const icon = categoryConfig.heading.split(" ", 1)[0];
  const template = `---\nbump: ${bump}\ncategory: ${category}\n---\n\n- ${icon} **中文标题** / **English title**\n\n  中文说明。\n\n  English summary.\n`;
  writeFileSync(target, template, { encoding: "utf8", flag: "wx" });
  process.stdout.write(`Created .changeset/${slug}.md\n`);
}

function printStatus(config, fragments) {
  process.stdout.write(`${config.project}\n`);
  process.stdout.write(`Pending changesets: ${fragments.length}\n`);
  if (fragments.length === 0) return;
  process.stdout.write(`Recommended bump: ${recommendedBump(fragments)}\n`);
  for (const fragment of fragments) {
    const summary = fragment.body.split("\n", 1)[0].replace(/^-\s*/, "");
    process.stdout.write(`- ${fragment.name} [${fragment.bump}/${fragment.category}] ${summary}\n`);
  }
}

function release(args, config, fragments) {
  if (fragments.length === 0) fail("no pending changesets to release");
  const version = args.shift();
  versionHeadingPattern(version, "release");

  let date = today();
  let dryRun = false;
  while (args.length > 0) {
    const arg = args.shift();
    if (arg === "--dry-run") dryRun = true;
    else if (arg === "--date") {
      date = args.shift();
      if (!date) fail("--date requires YYYY-MM-DD");
    } else fail(`unknown release option: ${arg}`);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) fail("date must use YYYY-MM-DD");

  const { changelog, changelogPath } = readChangelog(config);
  const changelogLines = changelog.replace(/\r\n/g, "\n").split("\n");
  if (findVersionStart(changelogLines, version, "release") >= 0) {
    fail(`CHANGELOG already contains version ${version}`);
  }

  const section = sectionFor(version, date, config, fragments);
  if (dryRun) {
    process.stdout.write(`${section}\n`);
    return;
  }

  const [before, after] = changelog.split(RELEASE_MARKER);
  let next = `${before.trimEnd()}\n\n${RELEASE_MARKER}\n\n${section}\n\n${after.trimStart()}`;
  if (config.releaseLink) {
    const linkPrefix = `[${version}]:`;
    if (next.split(/\r?\n/).some((line) => line.startsWith(linkPrefix))) {
      fail(`CHANGELOG already defines ${version}`);
    }
    const releaseUrl = config.releaseLink.replace(/\{version\}/g, version);
    const link = `${linkPrefix} ${releaseUrl}`;
    next = `${next.trimEnd()}\n${link}\n`;
  } else {
    next = `${next.trimEnd()}\n`;
  }

  const temporary = `${changelogPath}.tmp-${process.pid}`;
  try {
    writeFileSync(temporary, next, "utf8");
    renameSync(temporary, changelogPath);
  } finally {
    if (existsSync(temporary)) unlinkSync(temporary);
  }
  for (const fragment of fragments) unlinkSync(join(CHANGESET_DIR, fragment.name));
  process.stdout.write(`Released ${version}; consumed ${fragments.length} changeset(s).\n`);
}

function main() {
  const [command = "help", ...args] = process.argv.slice(2);
  if (command === "help" || command === "--help" || command === "-h") {
    help();
    return;
  }

  const config = readConfig();
  if (command === "new") {
    createFragment(args, config);
    return;
  }

  const { changelog } = readChangelog(config);
  if (command === "notes") {
    if (args.length !== 1) fail("notes requires <version>");
    process.stdout.write(`${notesFor(changelog, args[0])}\n`);
    return;
  }
  const fragments = readFragments(config);
  if (command === "check") {
    runRegressionChecks();
    process.stdout.write(`Validated ${fragments.length} pending changeset(s).\n`);
  } else if (command === "status") {
    printStatus(config, fragments);
  } else if (command === "release") {
    release(args, config, fragments);
  } else {
    fail(`unknown command: ${command}`);
  }
}

try {
  main();
} catch (error) {
  process.stderr.write(`changeset: ${error.message}\n`);
  process.exitCode = 1;
}
