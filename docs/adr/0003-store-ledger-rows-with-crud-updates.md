---
schemaVersion: 0.2.0
id: "0003"
title: "Store ledger rows with CRUD updates"
status: superseded
supersededBy: "0006"
date: 2025-01-20
deciders: ["@mbeacom"]
tags: [ledger, storage]
scope: component
reversibility: two-way-door
blastRadius: component
relatesTo: []
affects:
  - type: path
    pattern: "src/ledger/**"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0003: Store ledger rows with CRUD updates

## Context

The first version of the API needed balances quickly. One row per account,
updated in place on every transfer, is the shortest path to a working
endpoint.

## Decision

We will keep one balance row per account and update it in place inside the
transfer transaction.

## Options considered

### Option A: mutable balance rows (chosen)

Fast to build and fast to read.

### Option B: an append-only event log

Full history, but more work before the first endpoint ships.

## Trade-offs

We lose history: once a row is updated, nothing records how it got there.

## Consequences

- Easier: reading a balance is one lookup.
- Harder: auditing and reconciliation.
- **How we would know this was wrong:** a support case asks "how did this
  balance get here?" and we cannot answer it.

Superseded by ADR-0006, which event-sources the ledger.
