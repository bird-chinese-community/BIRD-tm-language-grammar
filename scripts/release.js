#!/usr/bin/env node
/* eslint-disable no-console */

// CommonJS, Node stdlib only
const fs = require('fs');
const path = require('path');
const https = require('https');

function getRepoContextOptional() {
  const repoEnv = process.env.GITHUB_REPOSITORY || '';
  const [owner, repo] = repoEnv.split('/');
  const token = process.env.GITHUB_TOKEN || '';
  if (!owner || !repo) return null;
  return { owner, repo, token };
}

function readJson(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  return JSON.parse(content);
}

function readVimVersion(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split(/\r?\n/);
  for (const line of lines) {
    const m = line.match(/^["\s]*Version:\s*([^\s]+)/);
    if (m) return m[1];
  }
  throw new Error('Cannot find Version: line in ' + filePath);
}

function httpRequest({ method, hostname, path: urlPath, headers, body }) {
  return new Promise((resolve, reject) => {
    const req = https.request({ method, hostname, path: urlPath, headers }, (res) => {
      const chunks = [];
      res.on('data', (d) => chunks.push(d));
      res.on('end', () => {
        const buf = Buffer.concat(chunks);
        const text = buf.toString('utf8');
        const isJson = (res.headers['content-type'] || '').includes('application/json');
        const data = isJson && text ? JSON.parse(text) : text;
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve({ status: res.statusCode, headers: res.headers, data });
        } else {
          const err = new Error(`HTTP ${res.statusCode}: ${text}`);
          err.response = { status: res.statusCode, headers: res.headers, data };
          reject(err);
        }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function listReleases(owner, repo, token) {
  const res = await httpRequest({
    method: 'GET',
    hostname: 'api.github.com',
    path: `/repos/${owner}/${repo}/releases?per_page=100`,
    headers: {
      'User-Agent': 'release-script',
      'Authorization': token ? `Bearer ${token}` : undefined,
      'Accept': 'application/vnd.github+json',
    },
  });
  return res.data || [];
}

function buildReleaseBody({ kind, version, owner, repo, previousTag, tag }) {
  const repoUrl = owner && repo ? `https://github.com/${owner}/${repo}` : '';
  const compareLine = previousTag && repoUrl ? `Compare: ${repoUrl}/compare/${previousTag}...${tag}` : 'Initial release for this track.';
  const installLinks = repoUrl
    ? [
        `- Editors & IDE Support: [Install](${repoUrl}#editors-ide-support)`,
        `- VSCode: [Install](${repoUrl}#vscode)`,
        `- Vim: [Install](${repoUrl}#vim)`,
        `- JetBrains (TextMate Bundles): [Install](${repoUrl}#jetbrains-textmate-bundles)`,
      ].join('\n')
    : '- See README for installation instructions.';
  return (
    `Release ${kind} - \`${version}\`\n\n` +
    `${compareLine}\n\n` +
    `## Installation\n${installLinks}`
  );
}

async function findPreviousTagByPrefixOptional(ctx, prefix, excludeTag) {
  if (!ctx || !ctx.owner || !ctx.repo) return null;
  try {
    const releases = await listReleases(ctx.owner, ctx.repo, ctx.token);
    const filtered = releases
      .filter(r => r.tag_name && r.tag_name.startsWith(prefix) && r.tag_name !== excludeTag)
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
    return filtered.length ? filtered[0].tag_name : null;
  } catch {
    return null;
  }
}

function writeGhaOutput(name, value) {
  const ghaFile = process.env.GITHUB_OUTPUT;
  if (!ghaFile) return;
  const hasNewline = typeof value === 'string' && value.includes('\n');
  const line = hasNewline
    ? `${name}<<EOF\n${value}\nEOF\n`
    : `${name}=${value}\n`;
  fs.appendFileSync(ghaFile, line);
}

async function main() {
  const args = process.argv.slice(2);
  const toGhaOutputs = args.includes('--gha-outputs');

  const tmPath = path.join(__dirname, '..', 'grammars', 'bird2.tmLanguage.json');
  const vimPath = path.join(__dirname, '..', 'grammars', 'bird2.syntax.vim');

  const tmVersion = readJson(tmPath).version;
  const vimVersion = readVimVersion(vimPath);

  const tmTag = `tm-v${tmVersion}`;
  const vimTag = `vim-v${vimVersion}`;

  const ctx = getRepoContextOptional();

  const tmPrevious = await findPreviousTagByPrefixOptional(ctx, 'tm-v', tmTag);
  const vimPrevious = await findPreviousTagByPrefixOptional(ctx, 'vim-v', vimTag);

  const owner = ctx ? ctx.owner : null;
  const repo = ctx ? ctx.repo : null;

  const tmBody = buildReleaseBody({ kind: 'TextMate Grammar', version: tmVersion, owner, repo, previousTag: tmPrevious, tag: tmTag });
  const vimBody = buildReleaseBody({ kind: 'Vim Syntax', version: vimVersion, owner, repo, previousTag: vimPrevious, tag: vimTag });

  const tmName = `TextMate Grammar ${tmVersion}`;
  const vimName = `Vim Syntax ${vimVersion}`;

  const outputs = {
    tm_version: tmVersion,
    tm_tag: tmTag,
    tm_name: tmName,
    tm_body: tmBody,
    tm_file: tmPath,
    vim_version: vimVersion,
    vim_tag: vimTag,
    vim_name: vimName,
    vim_body: vimBody,
    vim_file: vimPath,
  };

  if (toGhaOutputs) {
    for (const [k, v] of Object.entries(outputs)) writeGhaOutput(k, v);
  }

  console.log('Computed release metadata:');
  console.log(JSON.stringify({
    tm: { version: tmVersion, tag: tmTag, name: tmName },
    vim: { version: vimVersion, tag: vimTag, name: vimName },
  }, null, 2));
}

main().catch((err) => {
  console.error(err.stack || err.message || String(err));
  process.exit(1);
});
