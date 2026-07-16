import { readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, isAbsolute, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import {
  collectGrammarPatterns,
  collectLiteralWords,
  compilePatterns,
  isSemanticPattern,
  matchesFullPhrase,
} from "./grammar-patterns.js";

const SCRIPT_DIR = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(SCRIPT_DIR, "..");
const GRAMMAR_PATH = join(REPO_ROOT, "grammars", "bird2.tmLanguage.json");

const macroNames = new Set([
  "CF_KEYWORDS",
  "CF_KEYWORDS_EXCLUSIVE",
  "CF_ENUM",
  "CF_ENUM_PX",
  "CF_CLI",
  "CF_CLI_CMD",
  "CF_CLI_OPT",
]);

const attributePrefixes = [
  "babel_",
  "bgp_",
  "iface_",
  "krt_",
  "mpls_",
  "ospf_",
  "proto_",
  "radv_",
  "rip_",
];

const unprefixedAttributeNames = new Set([
  "aspa_providers",
  "channel_in_keep",
  "ea_proto_channel_list",
  "flowspec_valid",
  "from",
  "hostentry",
  "ifindex",
  "ifname",
  "igp_metric",
  "kbr_source",
  "local_metric",
  "nexthop",
  "onlink",
  "preference",
  "roa_aggregated",
  "rtable",
  "source",
  "weight",
]);

const internalAttributeClassNames = new Set(["krt_", "krt_features", "krt_lock"]);

const normalizeSourcePath = (value) =>
  isAbsolute(value) ? value : resolve(REPO_ROOT, value);

const listFiles = (root) => {
  const files = [];

  for (const entry of readdirSync(root)) {
    const path = join(root, entry);
    const stat = statSync(path);

    if (stat.isDirectory()) {
      if (entry !== ".git") files.push(...listFiles(path));
    } else if (/\.(?:Y|c|h)$/.test(entry)) {
      files.push(path);
    }
  }

  return files;
};

const stripComments = (source) =>
  source.replace(/\/\*[\s\S]*?\*\//g, " ").replace(/\/\/.*$/gm, " ");

const splitArguments = (source) => {
  const args = [];
  let bracketDepth = 0;
  let parenthesisDepth = 0;
  let start = 0;

  for (let index = 0; index < source.length; index += 1) {
    const pair = source.slice(index, index + 2);

    if (pair === "[[") {
      bracketDepth += 1;
      index += 1;
      continue;
    }

    if (pair === "]]" && bracketDepth > 0) {
      bracketDepth -= 1;
      index += 1;
      continue;
    }

    if (bracketDepth > 0) continue;

    if (source[index] === "(") parenthesisDepth += 1;
    if (source[index] === ")") parenthesisDepth -= 1;

    if (source[index] === "," && parenthesisDepth === 0) {
      args.push(source.slice(start, index).trim());
      start = index + 1;
    }
  }

  args.push(source.slice(start).trim());
  return args;
};

const extractMacroCalls = (source) => {
  const calls = [];
  const macroPattern = /\b(CF_[A-Z_]+)\s*\(/g;

  for (const match of source.matchAll(macroPattern)) {
    const name = match[1];
    if (!macroNames.has(name)) continue;

    const bodyStart = match.index + match[0].length;
    let bracketDepth = 0;
    let parenthesisDepth = 1;
    let bodyEnd = bodyStart;

    for (; bodyEnd < source.length; bodyEnd += 1) {
      const pair = source.slice(bodyEnd, bodyEnd + 2);

      if (pair === "[[") {
        bracketDepth += 1;
        bodyEnd += 1;
        continue;
      }

      if (pair === "]]" && bracketDepth > 0) {
        bracketDepth -= 1;
        bodyEnd += 1;
        continue;
      }

      if (bracketDepth > 0) continue;

      if (source[bodyEnd] === "(") parenthesisDepth += 1;
      if (source[bodyEnd] === ")") parenthesisDepth -= 1;
      if (parenthesisDepth === 0) break;
    }

    calls.push({
      name,
      args: splitArguments(source.slice(bodyStart, bodyEnd)),
    });
  }

  return calls;
};

const cleanIdentifier = (value) => {
  const match = value.trim().match(/^[A-Z][A-Z0-9_]*$/);
  return match?.[0] ?? null;
};

const isFilterAttributeName = (name) =>
  !internalAttributeClassNames.has(name) &&
  (unprefixedAttributeNames.has(name) ||
    attributePrefixes.some((prefix) => name.startsWith(prefix)));

const extractAttributeNames = (source, attributes) => {
  const classPattern = /\bstruct\s+ea_class\b[\s\S]*?=\s*\{([\s\S]*?)\n\s*\};/g;

  for (const classMatch of source.matchAll(classPattern)) {
    const body = classMatch[1];
    for (const nameMatch of body.matchAll(/\.name\s*=\s*"([a-z][a-z0-9_]*)"/g)) {
      const name = nameMatch[1];
      if (isFilterAttributeName(name)) attributes.add(name);
    }
  }
};

const extractSourceGrammar = (root) => {
  const keywords = new Set();
  const enumConstants = new Set();
  const cliPhrases = new Set();
  const attributeNames = new Set();

  for (const path of listFiles(root)) {
    const source = stripComments(readFileSync(path, "utf8"));

    if (/\.[ch]$/.test(path)) extractAttributeNames(source, attributeNames);
    if (!path.endsWith(".Y")) continue;

    for (const { name, args } of extractMacroCalls(source)) {
      if (name === "CF_KEYWORDS" || name === "CF_KEYWORDS_EXCLUSIVE") {
        for (const arg of args) {
          const identifier = cleanIdentifier(arg);
          if (identifier) keywords.add(identifier.toLowerCase());
        }
        continue;
      }

      if (name === "CF_ENUM" || name === "CF_ENUM_PX") {
        const prefix = cleanIdentifier(args[1]);
        const valueOffset = name === "CF_ENUM" ? 2 : 3;
        if (!prefix) continue;

        for (const arg of args.slice(valueOffset)) {
          const identifier = cleanIdentifier(arg);
          if (identifier) enumConstants.add(`${prefix}${identifier}`);
        }
        continue;
      }

      const phrase = args[0]
        ?.trim()
        .toLowerCase()
        .replace(/\s+/g, " ");
      if (phrase && /^[a-z0-9_]+(?: [a-z0-9_]+)*$/.test(phrase)) {
        cliPhrases.add(phrase);
      }
    }
  }

  return { keywords, enumConstants, cliPhrases, attributeNames };
};

const grammar = JSON.parse(readFileSync(GRAMMAR_PATH, "utf8"));
const grammarPatterns = collectGrammarPatterns(grammar.repository);
const compiledPatterns = compilePatterns(grammarPatterns);
const semanticPatterns = compiledPatterns.filter(isSemanticPattern);
const literalWords = collectLiteralWords(grammarPatterns);

const mentionsKeyword = (keyword) =>
  literalWords.has(keyword) || literalWords.has(keyword.replaceAll("_", "-"));

const formatList = (values) =>
  values.length > 0 ? values.map((value) => `  - ${value}`).join("\n") : "  (none)";

const sourceArgs = process.argv.slice(2);
const sources = sourceArgs.length > 0 ? sourceArgs : ["../BIRD2", "../BIRD3"];
let hasMissingCoverage = false;

for (const sourceArg of sources) {
  const sourceRoot = normalizeSourcePath(sourceArg);
  const { keywords, enumConstants, cliPhrases, attributeNames } =
    extractSourceGrammar(sourceRoot);
  const missingKeywords = [...keywords].filter((value) => !mentionsKeyword(value)).sort();
  const missingEnums = [...enumConstants].filter((value) => !literalWords.has(value)).sort();
  const missingCliPhrases = [...cliPhrases]
    .filter((value) => !matchesFullPhrase(semanticPatterns, value))
    .sort();
  const missingAttributeNames = [...attributeNames]
    .filter((value) => !literalWords.has(value))
    .sort();

  hasMissingCoverage ||=
    missingKeywords.length > 0 ||
    missingEnums.length > 0 ||
    missingCliPhrases.length > 0 ||
    missingAttributeNames.length > 0;

  console.log(sourceRoot);
  console.log(
    `  source: ${keywords.size} keywords, ${enumConstants.size} enum constants, ${cliPhrases.size} CLI phrases, ${attributeNames.size} filter attributes`,
  );
  console.log(
    `  grammar regexes compiled: ${compiledPatterns.length}/${grammarPatterns.length}`,
  );
  console.log("  missing keywords:");
  console.log(formatList(missingKeywords));
  console.log("  missing enum constants:");
  console.log(formatList(missingEnums));
  console.log("  missing CLI phrases:");
  console.log(formatList(missingCliPhrases));
  console.log("  missing filter attributes:");
  console.log(formatList(missingAttributeNames));
}

process.exitCode = hasMissingCoverage ? 1 : 0;
