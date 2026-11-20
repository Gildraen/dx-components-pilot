#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

node <<'EOF'
const assert = require('node:assert/strict');
const fs = require('node:fs');
const config = JSON.parse(fs.readFileSync('release-please-config.json', 'utf8'));
const manifest = JSON.parse(fs.readFileSync('.release-please-manifest.json', 'utf8'));
assert.equal(config['include-v-in-tag'], false);
assert.equal(config['bootstrap-sha'], 'b93d3653849cc1b721146b83fa5527b895ff5de0');
assert.equal(config.packages['.']['version-file'], 'version.txt');
assert.equal(manifest['.'], '0.0.0');
assert.equal(fs.readFileSync('version.txt', 'utf8').trim(), manifest['.']);
assert.equal(JSON.parse(fs.readFileSync('renovate.json', 'utf8')).extends[0], 'github>Gildraen/renovate-config#0.2.0');
const workflow = fs.readFileSync('.github/workflows/validate.yml', 'utf8');
assert.match(workflow, /needs: \[validate, lint\]/);
assert.match(workflow, /config-file: release-please-config\.json/);
EOF

echo "pilot release baseline and no-v workflow contract pass"