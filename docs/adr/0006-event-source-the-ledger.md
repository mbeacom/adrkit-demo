---
schemaVersion: 0.2.0
id: "0006"
title: "Event-source the ledger"
status: accepted
supersedes: ["0003"]
date: 2026-03-02
deciders: ["@mbeacom"]
tags: [ledger, storage, audit]
scope: component
reversibility: one-way-door
blastRadius: team
relatesTo: ["0004"]
affects:
  - type: path
    pattern: "src/ledger/**"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0006: Event-source the ledger

## Context

ADR-0003 kept one mutable balance row per account. Support could not explain
how a balance reached its value, and reconciliation needed history we had
overwritten.

## Decision

We will store the ledger as an append-only sequence of posting events. A
balance is a fold over an account's events. Events are never updated or
deleted; a correction is a new, compensating event.

## Options considered

### Option A: append-only events (chosen)

Complete history, simple audit, replayable projections.

### Option B: keep CRUD rows and add an audit table

Two sources of truth that can disagree.

### Option C: Do nothing

Keep losing history.

## Trade-offs

Reads need a projection or a fold; the event table grows without bound.

## Consequences

- Easier: audit, replay, and "how did we get here?".
- Harder: balance reads at scale need a snapshot projection.
- **How we would know this was wrong:** projection rebuilds exceed our
  recovery-time objective.
- Supersedes ADR-0003.
