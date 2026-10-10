---
schemaVersion: 0.2.0
id: "0004"
title: "Use Postgres as the system of record"
status: accepted
date: 2025-02-03
deciders: ["@mbeacom"]
tags: [storage]
scope: domain
reversibility: one-way-door
blastRadius: cross-team
relatesTo: []
affects:
  - type: path
    pattern: "src/db/**"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0004: Use Postgres as the system of record

## Context

The ledger needs multi-row transactions (a transfer debits one account and
credits another atomically), unique constraints for idempotency keys, and
ad hoc queries for reconciliation.

## Decision

We will use Postgres as the system of record for accounts, ledger events, and
idempotency keys. The schema lives in `src/db/`.

## Options considered

### Option A: Postgres (chosen)

Serializable transactions, unique constraints, and SQL for reconciliation.

### Option B: DynamoDB

Considered and rejected in ADR-0005, which declares the conflict with this record.

### Option C: Do nothing (in-memory store)

Fine for this demo process, useless for a real ledger.

## Trade-offs

We operate a stateful database and own its backups and failover.

## Consequences

- Easier: correctness guarantees come from the database.
- Harder: horizontal write scaling.
- **How we would know this was wrong:** sustained write contention on the
  events table that partitioning does not fix.
