#!/usr/bin/env bash
# Act 5, PR 3: propose a new decision for review.
# Adds one `proposed` record, then dispatches the queue workflow on this
# branch so the managed "ADR ARB Queue" issue shows the new item.
source "$(dirname "$0")/lib.sh"
BRANCH=demo/new-decision
start_branch "$BRANCH"

TODAY="$(date -u +%Y-%m-%d)"
FILE="$("$ADR" new "Rate-limit transfer creation per account" --status proposed --json | node -e 'process.stdin.on("data", d => process.stdout.write(JSON.parse(d).path))')"
ID="$(basename "$FILE" | cut -c1-4)"

cat > "$FILE" <<MD
---
schemaVersion: 0.2.0
id: "$ID"
title: "Rate-limit transfer creation per account"
status: proposed
date: $TODAY
deciders: ["@mbeacom", "@octocat"]
tags: [api, abuse]
scope: component
reversibility: two-way-door
blastRadius: team
relatesTo: ["0007"]
affects:
  - type: path
    pattern: "src/handlers/transfers.ts"
provenance:
  authoredBy: human
review:
  tier: async
  tierReason: "Two-way-door change to one endpoint; asynchronous review is enough."
  queuedAt: "${TODAY}T00:00:00Z"
  slaDays: 14
  quorum: 1
---

# ADR-$ID: Rate-limit transfer creation per account

## Context

A misbehaving client can create transfers in a tight loop. Idempotency keys
(ADR-0007) stop duplicate retries, not a flood of distinct requests.

## Decision

Proposed: limit \`POST /transfers\` to 10 requests per second per source
account, answering \`429\` with \`Retry-After\` beyond that.

## Options considered

### Option A: per-account token bucket (proposed)

Fair across accounts; needs shared state across instances.

### Option B: per-client-IP limit at the load balancer

No code, but one noisy tenant behind a NAT throttles everyone.

### Option C: Do nothing

Rely on database back-pressure.

## Consequences

- **How we would know this was wrong:** legitimate batch payouts hit 429.
MD

"$ADR" lint
commit_all "docs(adr): propose rate-limiting transfer creation per account"
publish "$BRANCH" "Propose ADR-$ID: rate-limit transfer creation per account" "$(cat <<MD
I am proposing ADR-$ID, a per-account rate limit on \`POST /transfers\`. It is \`proposed\` with an async review tier and a quorum of one, so it enters the ARB queue.

This is demo PR 3 of 4 for [adrkit](https://github.com/mbeacom/adrkit). Two things to look for:

- The governing-decisions comment validates the changed record and lists it.
- The \`ADR ARB queue\` workflow, dispatched on this branch, rewrites the managed **ADR ARB Queue** issue so it lists this proposal next to ADR-0009. The repository has one managed issue; it shows whichever ref ran last.

Reproduce with \`demo/new-decision.sh\`.
MD
)"

if [[ "${DEMO_PUSH:-1}" != "0" ]]; then
  gh workflow run adr-queue.yml --ref "$BRANCH"
  echo "dispatched adr-queue.yml on $BRANCH"
fi
