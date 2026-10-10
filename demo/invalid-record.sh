#!/usr/bin/env bash
# Act 4, PR 4: the one thing the Action does fail on.
# The governing-decisions Action fails the job when a record changed by the
# PR has an error finding. This PR adds an `accepted` record that claims to
# supersede ADR-0042, which does not exist.
source "$(dirname "$0")/lib.sh"
BRANCH=demo/invalid-record
start_branch "$BRANCH"

TODAY="$(date -u +%Y-%m-%d)"
FILE="$("$ADR" new "Cache account balances in Redis" --json | node -e 'process.stdin.on("data", d => process.stdout.write(JSON.parse(d).path))')"
ID="$(basename "$FILE" | cut -c1-4)"

cat > "$FILE" <<MD
---
schemaVersion: 0.2.0
id: "$ID"
title: "Cache account balances in Redis"
status: accepted
supersedes: ["0042"]
date: $TODAY
deciders: ["@mbeacom"]
tags: [ledger, performance]
scope: component
reversibility: two-way-door
blastRadius: component
affects:
  - type: path
    pattern: "src/handlers/balances.ts"
provenance:
  authoredBy: human
---

# ADR-$ID: Cache account balances in Redis

## Decision

Cache each account's folded balance in Redis for 30 seconds.

This record is deliberately invalid: it supersedes ADR-0042, which does not
exist, so \`adr lint\` reports an error and the governing-decisions check fails.
MD

"$ADR" lint && { echo "expected adr lint to fail" >&2; exit 1; } || true
commit_all "docs(adr): cache account balances in Redis"
publish "$BRANCH" "Record ADR-$ID: cache account balances in Redis (invalid on purpose)" "$(cat <<MD
I am adding ADR-$ID as \`accepted\`, and it claims to supersede ADR-0042, which does not exist.

This is demo PR 4 of 4 for [adrkit](https://github.com/mbeacom/adrkit), and it is the one that **fails**. The governing-decisions Action fails the job only when a record changed by the PR has an error finding, and a dangling \`supersedes\` reference is one. The CI workflow's \`adr lint\` step fails for the same reason.

Reproduce with \`demo/invalid-record.sh\`.
MD
)"
