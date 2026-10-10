---
schemaVersion: 0.2.0
id: "0008"
title: "Publish nightly CSV balance exports"
status: deprecated
date: 2025-04-14
deciders: ["@mbeacom"]
tags: [reporting]
scope: component
reversibility: two-way-door
blastRadius: component
relatesTo: []
affects:
  - type: path
    pattern: "src/reports/**"
provenance:
  authoredBy: human
---

# ADR-0008: Publish nightly CSV balance exports

## Context

Finance asked for a nightly file of closing balances to load into a
spreadsheet.

## Decision

We published a nightly CSV of closing balances per account.

## Status note

Deprecated. Finance now reads balances from the reconciliation view, and the
export has no remaining consumer. The code in `src/reports/` stays until the
last scheduled job is removed. Nothing replaced this decision, so it is
`deprecated` rather than `superseded`, and it records no end date.

## Consequences

- **How we would know this was wrong:** someone asks for the file again.
