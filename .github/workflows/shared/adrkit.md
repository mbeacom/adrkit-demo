---
mcp-servers:
  adrkit:
    container: "ghcr.io/mbeacom/adrkit@sha256:16a713a4789356d1e37ffd2c6894ed82cd657ec3c3d8aed1371a9eda86e82b68"
    entrypointArgs: ["mcp"]
    args: ["--read-only", "--network", "none", "-w", "/workspace"]
    mounts: ["${{ github.workspace }}:/workspace:ro"]
    allowed:
      - get_decision
      - get_decision_context
      - list_superseded
      - search_decisions

plugins:
  - mbeacom/adrkit/packages/adapters/agent-plugin@v0.20.0

network:
  allowed: []

checkout:
  fetch-depth: 0

steps:
  - name: Set up Node for the adrkit CLI
    uses: actions/setup-node@v7
    with:
      node-version: 24
  - name: Install @adrkit/cli 0.20.0
    run: npm install -g @adrkit/cli@0.20.0
  - name: Write the deterministic decision check for the agent
    env:
      BASE_SHA: ${{ github.event.pull_request.base.sha }}
      HEAD_SHA: ${{ github.event.pull_request.head.sha }}
    run: |
      set -uo pipefail
      out=/tmp/gh-aw/agent
      mkdir -p "$out"
      adr lint > "$out/lint.txt" 2>&1
      lint_rc=$?
      git diff --name-only -z "$BASE_SHA...$HEAD_SHA" > "$out/changed-files.z"
      diff_rc=$?
      mapfile -d '' -t files < "$out/changed-files.z"
      check_rc=-1
      if [ "$diff_rc" -eq 0 ] && [ "${#files[@]}" -eq 0 ]; then
        printf '{"governing":[],"activeProposals":[],"history":[],"findings":[]}\n' > "$out/check.json"
        check_rc=0
      elif [ "$diff_rc" -eq 0 ]; then
        adr check --json -- "${files[@]}" > "$out/check.json"
        check_rc=$?
      fi
      printf '{"lintExitCode":%d,"diffExitCode":%d,"checkExitCode":%d,"changedFiles":%d}\n' \
        "$lint_rc" "$diff_rc" "$check_rc" "${#files[@]}" > "$out/check-meta.json"
      echo "adr lint exit $lint_rc; git diff exit $diff_rc; adr check exit $check_rc; ${#files[@]} changed file(s)"
---

<!--
adrkit shared component for GitHub Agentic Workflows (spike for ADR-0060).
Import only; it declares no `on:`.

What it gives the agent (ADR-0060 clause 3):
- `adrkit` MCP server: the published OCI image, pinned by the v0.20.0 OCI
  index digest (label org.opencontainers.image.version = 0.20.0), run
  read-only with no network and the workspace mounted :ro. Only the four
  read-only tools are allowed; the server exposes no others.
- The adrkit agent plugin (skills and the decision-checker agent) at tag
  v0.20.0, which the compiler pins to a commit SHA.
- The `adr` CLI (@adrkit/cli 0.20.0, exact) on the host PATH, and
  /tmp/gh-aw/agent/check.json: `adr check --json` over the files changed
  between the pull request's base and head, with exit codes in
  /tmp/gh-aw/agent/check-meta.json.

Network: `allowed: []`. The CLI install runs as a host step before the agent
sandbox starts; the agent itself needs no egress beyond what gh-aw adds for the
engine.

Secrets: none of its own. The importing workflow's engine needs its usual
credential (COPILOT_GITHUB_TOKEN for the Copilot engine).

Writes: none. Any visible output belongs to the importing workflow's
safe-outputs.
-->
