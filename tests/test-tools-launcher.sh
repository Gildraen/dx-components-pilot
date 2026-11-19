#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
task_bin="$(command -v task)"
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/bin"
cat > "$workdir/bin/docker" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@"
EOF
cat > "$workdir/bin/dx-mcp" <<'EOF'
#!/usr/bin/env bash
echo 'HOST_DX_MCP_SELECTED'
EOF
chmod +x "$workdir/bin/docker" "$workdir/bin/dx-mcp"

output="$(PATH="$workdir/bin:/usr/bin:/bin" TASK_REMOTE_TRUSTED_HOSTS=github.com \
  "$task_bin" --dir "$repo_root" mcp:github -- --read-only --toolsets issues)"

[[ "$output" == *'ghcr.io/github/github-mcp-server:v1.10.1'* ]] || {
  echo 'FAIL: tools submodule launcher was not selected' >&2
  exit 1
}
[[ "$output" == *'--read-only'* && "$output" == *'issues'* ]] || {
  echo 'FAIL: MCP server options were not forwarded' >&2
  exit 1
}
[[ "$output" != *'HOST_DX_MCP_SELECTED'* ]] || {
  echo 'FAIL: launcher was resolved from the inherited PATH' >&2
  exit 1
}

echo 'tools submodule launcher is selected independently of PATH'
