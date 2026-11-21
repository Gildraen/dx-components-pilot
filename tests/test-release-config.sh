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
assert.match(validateWorkflow, /^permissions:\n  contents: read/m);
assert.match(releaseWorkflow, /workflows: \[Pilot validate\]/);
assert.match(releaseWorkflow, /types: \[completed\]/);
assert.match(releaseWorkflow, /branches: \[main\]/);
assert.match(releaseWorkflow, /if: github\.event\.workflow_run\.conclusion == 'success'/);
assert.match(releaseWorkflow, /jobs:\n  release:[\s\S]*?\n    permissions:\n      contents: read/);
assert.match(releaseWorkflow, /reusable-release-please\.yml@495bb9b377719414123af8c329b02aeff58ab440 # 0\.2\.0/);
assert.match(releaseWorkflow, /config-file: release-please-config\.json/);
assert.match(releaseWorkflow, /manifest-file: \.release-please-manifest\.json/);
assert.match(releaseWorkflow, /target-branch: main/);
assert.match(releaseWorkflow, /expected-sha: \$\{\{ github\.event\.workflow_run\.head_sha \}\}/);
assert.match(releaseWorkflow, /app-client-id: \$\{\{ vars\.RELEASE_PLEASE_APP_CLIENT_ID \}\}/);
assert.match(releaseWorkflow, /app-private-key: \$\{\{ secrets\.RELEASE_PLEASE_APP_PRIVATE_KEY \}\}/);
assert.doesNotMatch(releaseWorkflow, /RELEASE_PLEASE_TOKEN|GITHUB_TOKEN/);
assert.doesNotMatch(releaseWorkflow, /googleapis\/release-please-action/);
assert.doesNotMatch(validateWorkflow, /reusable-release-please|release-please-action/);
EOF

echo "pilot release baseline and no-v workflow contract pass"