---
schemaVersion: 0.2.0
id: "0010"
title: "Cache account balances in Redis"
status: accepted
supersedes: ["0042"]
date: 2026-10-10
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

# ADR-0010: Cache account balances in Redis

## Decision

Cache each account's folded balance in Redis for 30 seconds.

This record is deliberately invalid: it supersedes ADR-0042, which does not
exist, so `adr lint` reports an error and the governing-decisions check fails.
