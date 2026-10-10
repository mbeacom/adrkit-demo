---
schemaVersion: 0.2.0
id: "0007"
title: "Require idempotency keys on mutating endpoints"
status: accepted
date: 2025-06-09
deciders: ["@mbeacom"]
tags: [api, correctness]
scope: component
reversibility: two-way-door
blastRadius: team
relatesTo: ["0006"]
affects:
  - type: path
    pattern: "src/http/idempotency.ts"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0007: Require idempotency keys on mutating endpoints

## Context

Clients retry on timeouts. Without a key, a retried `POST /transfers` moves
the money twice.

## Decision

Every mutating endpoint requires an `Idempotency-Key` header. The first
response for a key is stored and replayed for any retry with the same key;
a request without a key is rejected with `400`.

`affects` names only the defining module, `src/http/idempotency.ts`. Each
handler that must honor the rule declares it with an `@adr 0007` comment
marker, so the decision reaches handlers one line at a time.

## Options considered

### Option A: required idempotency keys (chosen)

Safe retries; one extra header for clients.

### Option B: deduplicate on request body hash

Two legitimate identical transfers would be merged.

### Option C: Do nothing

Double charges on retry.

## Consequences

- Easier: clients can retry blindly.
- Harder: key storage and expiry.
- **How we would know this was wrong:** clients routinely send a fresh key per
  retry, which defeats the mechanism.
