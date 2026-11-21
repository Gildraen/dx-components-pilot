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
const validateWorkflow = fs.readFileSync('.github/workflows/validate.yml', 'utf8');
const releaseWorkflow = fs.readFileSync('.github/workflows/release-please.yml', 'utf8');
assert.doesNotMatch(validateWorkflow, /workflow_dispatch/);
assert.match(releaseWorkflow, /workflows: \[Pilot validate\]/);
assert.match(releaseWorkflow, /types: \[completed\]/);
assert.match(releaseWorkflow, /branches: \[main\]/);
assert.match(releaseWorkflow, /if: github\.event\.workflow_run\.conclusion == 'success' && github\.event\.workflow_run\.event == 'push'/);
assert.match(releaseWorkflow, /permissions:\n      contents: write\n      issues: write\n      pull-requests: write/);
assert.match(releaseWorkflow, /reusable-release-please\.yml@b04cfb98139aa06de661c70a128452184f2004dd # 0\.2\.0/);
assert.match(releaseWorkflow, /config-file: release-please-config\.json/);
assert.match(releaseWorkflow, /manifest-file: \.release-please-manifest\.json/);
assert.match(releaseWorkflow, /target-branch: main/);
assert.match(releaseWorkflow, /expected-sha: \$\{\{ github\.event\.workflow_run\.head_sha \}\}/);
assert.match(releaseWorkflow, /release-please-token: \$\{\{ secrets\.RELEASE_PLEASE_TOKEN \|\| secrets\.GITHUB_TOKEN \}\}/);
assert.doesNotMatch(releaseWorkflow, /googleapis\/release-please-action/);
assert.doesNotMatch(validateWorkflow, /reusable-release-please|release-please-action/);
EOF

echo "pilot release baseline and no-v workflow contract pass"