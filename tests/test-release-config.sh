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
assert.match(workflow, /if: github\.event_name == 'push' && github\.ref == 'refs\/heads\/main'/);
assert.match(workflow, /permissions:\n      contents: write\n      issues: write\n      pull-requests: write/);
assert.match(workflow, /reusable-release-please\.yml@4b4026ff669b5fe8da2aa83e216591bb09e1e8a1 # 0\.2\.0/);
assert.match(workflow, /config-file: release-please-config\.json/);
assert.match(workflow, /manifest-file: \.release-please-manifest\.json/);
assert.match(workflow, /target-branch: main/);
assert.match(workflow, /release-please-token: \$\{\{ secrets\.RELEASE_PLEASE_TOKEN \|\| secrets\.GITHUB_TOKEN \}\}/);
assert.doesNotMatch(workflow, /googleapis\/release-please-action/);
EOF

echo "pilot release baseline and no-v workflow contract pass"