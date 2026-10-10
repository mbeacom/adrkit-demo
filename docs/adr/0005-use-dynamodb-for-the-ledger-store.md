---
schemaVersion: 0.2.0
id: "0005"
title: "Use DynamoDB for the ledger store"
status: rejected
date: 2025-02-03
deciders: ["@mbeacom"]
tags: [storage]
scope: domain
reversibility: one-way-door
blastRadius: cross-team
relatesTo: []
conflictsWith: ["0004"]
affects:
  - type: path
    pattern: "src/db/**"
provenance:
  authoredBy: human
---

# ADR-0005: Use DynamoDB for the ledger store

## Context

DynamoDB was proposed for its managed scaling and pay-per-request pricing.

## Decision

Rejected. A transfer must debit and credit atomically and enforce unique
idempotency keys across accounts. DynamoDB transactions are limited in size
and cost, and reconciliation queries would need a second store. ADR-0004
chose Postgres; the two records conflict by construction.

## Options considered

### Option A: DynamoDB (rejected)

Managed scaling; weak fit for multi-row ledger invariants.

### Option B: Postgres

Chosen in ADR-0004.

## Consequences

- This record stays in the corpus so the next proposal to "just use DynamoDB"
  starts from why we said no.
- **How we would know this was wrong:** Postgres write throughput becomes the
  binding constraint and partitioning does not relieve it.
