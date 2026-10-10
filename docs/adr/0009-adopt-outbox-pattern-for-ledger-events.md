---
schemaVersion: 0.2.0
id: "0009"
title: "Adopt outbox pattern for ledger events"
status: proposed
date: 2026-09-28
deciders: ["@mbeacom", "@octocat", "@hubot"]
tags: [ledger, messaging]
scope: domain
reversibility: one-way-door
blastRadius: cross-team
relatesTo: ["0006"]
affects:
  - type: path
    pattern: "src/ledger/**"
provenance:
  authoredBy: human
review:
  tier: arb
  tierReason: "One-way-door change to how ledger events leave the service; cross-team consumers depend on it."
  queuedAt: "2026-09-28T00:00:00Z"
  slaDays: 30
  quorum: 2
  approvals: ["@octocat"]
  objections:
    - by: "@hubot"
      summary: "The relay adds a second reader of the events table; I want a replay test before we commit."
      resolved: false
---

# ADR-0009: Adopt outbox pattern for ledger events

## Context

Downstream services (notifications, analytics) need to learn about postings.
Publishing to a broker inside the transfer handler can lose a message when
the process dies between the database commit and the publish.

## Decision

Proposed: write an outbox row in the same transaction as the ledger events,
and have a relay publish outbox rows to the broker at least once.

## Options considered

### Option A: transactional outbox (proposed)

No lost events; consumers must tolerate duplicates.

### Option B: publish after commit

Simple; loses events on crash.

### Option C: change data capture

No application changes, but a new piece of infrastructure to run.

## Trade-offs

At-least-once delivery means every consumer must be idempotent.

## Consequences

- **How we would know this was wrong:** relay lag exceeds a minute at p99.
- Revisit if: we adopt CDC for another reason.
