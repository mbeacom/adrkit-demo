---
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
adrkit shared component for GitHub Agentic Workflows (spike for ADR-0061).
Import only; it declares no `on:`.

What it gives the agent (ADR-0061 clause 3, default capability set):
- The `adr` CLI (@adrkit/cli 0.20.0, exact) on the host PATH.
- /tmp/gh-aw/agent/check.json: `adr check --json` over the files changed
  between the pull request's base and head, with exit codes in
  /tmp/gh-aw/agent/check-meta.json.
- A read-only checkout at full depth.

No MCP server and no agent plugin: both are opt-in under clause 3 and off by
default. The first staged run loaded both and the agent used neither.

Network: `allowed: []`. The CLI install runs as a host step before the agent
sandbox starts; the agent itself needs no egress beyond what gh-aw adds for the
engine.

Secrets: none of its own. The importing workflow's engine needs its usual
credential (COPILOT_GITHUB_TOKEN for the Copilot engine).

Writes: none. Any visible output belongs to the importing workflow's
safe-outputs.
-->
