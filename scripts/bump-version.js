#!/usr/bin/env node
/* eslint-disable no-console */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.join(__dirname, '..');
const TM_PATH = path.join(REPO_ROOT, 'grammars', 'bird2.tmLanguage.json');
const VIM_PATHS = [
  path.join(REPO_ROOT, 'external', 'bird2.vim', 'syntax', 'bird2.vim'),
  path.join(REPO_ROOT, 'external', 'bird2.nvim', 'syntax', 'bird2.vim'),
];

function usage() {
  console.log(`Usage: node scripts/bump-version.js [options]

Bump BIRD syntax patch version in tmLanguage + Vim/Neovim syntax files.

Options:
  --dry-run           Show planned changes without writing files
  --date YYYYMMDD     Override date suffix for next version
  --keep-date         Keep existing date suffix
  --tm-only           Only update grammars/bird2.tmLanguage.json
  --vim-only          Only update external/*/syntax/bird2.vim files
  -h, --help          Show this help
`);
}

function parseArgs(argv) {
  const opts = {
    dryRun: false,
    date: null,
    keepDate: false,
    tmOnly: false,
    vimOnly: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--dry-run') opts.dryRun = true;
    else if (arg === '--keep-date') opts.keepDate = true;
    else if (arg === '--tm-only') opts.tmOnly = true;
    else if (arg === '--vim-only') opts.vimOnly = true;
    else if (arg === '--date') {
      const value = argv[i + 1];
      if (!value) throw new Error('--date requires a value like 20260301');
      opts.date = value;
      i += 1;
    } else if (arg === '-h' || arg === '--help') {
      usage();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if (opts.tmOnly && opts.vimOnly) {
    throw new Error('--tm-only and --vim-only cannot be used together');
  }
  if (opts.date && !/^\d{8}$/.test(opts.date)) {
    throw new Error('--date must use YYYYMMDD format');
  }
  return opts;
}

function readUtf8(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function detectEol(content) {
  return content.includes('\r\n') ? '\r\n' : '\n';
}

function formatTodayLocal() {
  const now = new Date();
  const y = String(now.getFullYear());
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}${m}${d}`;
}

function parseVersion(version) {
  const m = /^(\d+)\.(\d+)\.(\d+)-(\d{8})$/.exec(version);
  if (!m) {
    throw new Error(`Unsupported version format: ${version}. Expected x.y.z-YYYYMMDD`);
  }
  return {
    major: Number(m[1]),
    minor: Number(m[2]),
    patch: Number(m[3]),
    date: m[4],
  };
}

function nextPatchVersion(currentVersion, opts) {
  const parsed = parseVersion(currentVersion);
  const nextDate = opts.keepDate ? parsed.date : (opts.date || formatTodayLocal());
  return `${parsed.major}.${parsed.minor}.${parsed.patch + 1}-${nextDate}`;
}

function readTmVersion(tmContent) {
  const m = /"version"\s*:\s*"([^"]+)"/.exec(tmContent);
  if (!m) throw new Error(`Cannot find "version" in ${TM_PATH}`);
  return m[1];
}

function replaceTmVersion(tmContent, newVersion) {
  const replaced = tmContent.replace(
    /("version"\s*:\s*")([^"]+)(")/,
    `$1${newVersion}$3`
  );
  if (replaced === tmContent) {
    throw new Error(`Failed to update "version" in ${TM_PATH}`);
  }
  JSON.parse(replaced);
  return replaced;
}

function replaceVimVersion(content, filePath, newVersion) {
  let out = content;

  out = out.replace(
    /^(\s*"\s*Version:\s*)([^\s]+)(\s*)$/m,
    `$1${newVersion}$3`
  );
  out = out.replace(
    /^(\s*"\s*Based on:\s*grammars\/bird2\.tmLanguage\.json\s*\()([^)]+)(\)\s*)$/m,
    `$1${newVersion}$3`
  );

  if (out === content) {
    throw new Error(`No version fields updated in ${filePath}`);
  }
  return out;
}

function maybeWrite(filePath, content, dryRun) {
  if (!dryRun) fs.writeFileSync(filePath, content, 'utf8');
}

function run() {
  const opts = parseArgs(process.argv.slice(2));

  const tmRaw = readUtf8(TM_PATH);
  const tmCurrentVersion = readTmVersion(tmRaw);
  const newVersion = nextPatchVersion(tmCurrentVersion, opts);

  const changes = [];
  const shouldTouchTm = !opts.vimOnly;
  const shouldTouchVim = !opts.tmOnly;

  if (shouldTouchTm) {
    const tmEol = detectEol(tmRaw);
    let tmUpdated = replaceTmVersion(tmRaw, newVersion);
    if (!tmUpdated.endsWith(tmEol)) tmUpdated += tmEol;
    if (tmUpdated !== tmRaw) {
      maybeWrite(TM_PATH, tmUpdated, opts.dryRun);
      changes.push(TM_PATH);
    }
  }

  if (shouldTouchVim) {
    for (const filePath of VIM_PATHS) {
      if (!fs.existsSync(filePath)) {
        throw new Error(
          `Missing file: ${filePath}\n` +
          'Run: git submodule update --init --recursive'
        );
      }
      const raw = readUtf8(filePath);
      const eol = detectEol(raw);
      let updated = replaceVimVersion(raw, filePath, newVersion);
      if (!updated.endsWith(eol)) updated += eol;
      if (updated !== raw) {
        maybeWrite(filePath, updated, opts.dryRun);
        changes.push(filePath);
      }
    }
  }

  const mode = opts.dryRun ? 'DRY RUN' : 'UPDATED';
  console.log(`[${mode}] ${tmCurrentVersion} -> ${newVersion}`);
  if (changes.length === 0) {
    console.log('No files changed.');
    return;
  }
  console.log('Changed files:');
  for (const filePath of changes) {
    console.log(`- ${path.relative(REPO_ROOT, filePath)}`);
  }
}

try {
  run();
} catch (error) {
  console.error(error && error.stack ? error.stack : error);
  process.exit(1);
}
