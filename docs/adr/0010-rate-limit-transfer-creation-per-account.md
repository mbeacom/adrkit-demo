---
schemaVersion: 0.2.0
id: "0010"
title: "Rate-limit transfer creation per account"
status: proposed
date: 2026-10-10
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
  queuedAt: "2026-10-10T00:00:00Z"
  slaDays: 14
  quorum: 1
---

# ADR-0010: Rate-limit transfer creation per account

## Context

A misbehaving client can create transfers in a tight loop. Idempotency keys
(ADR-0007) stop duplicate retries, not a flood of distinct requests.

## Decision

Proposed: limit `POST /transfers` to 10 requests per second per source
account, answering `429` with `Retry-After` beyond that.

## Options considered

### Option A: per-account token bucket (proposed)

Fair across accounts; needs shared state across instances.

### Option B: per-client-IP limit at the load balancer

No code, but one noisy tenant behind a NAT throttles everyone.

### Option C: Do nothing

Rely on database back-pressure.

## Consequences

- **How we would know this was wrong:** legitimate batch payouts hit 429.
