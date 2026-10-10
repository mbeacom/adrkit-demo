---
schemaVersion: 0.2.0
id: "0002"
title: "Represent money as integer minor units"
status: accepted
date: 2025-01-13
deciders: ["@mbeacom"]
tags: [money, correctness]
scope: component
reversibility: one-way-door
blastRadius: team
relatesTo: []
affects:
  - type: path
    pattern: "src/money/**"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0002: Represent money as integer minor units

## Context

Binary floating point cannot represent most decimal fractions exactly:
`0.1 + 0.2 !== 0.3`. A ledger that sums thousands of postings with floats
drifts by fractions of a cent, and reconciliation then fails for reasons
nobody can see in the code.

## Decision

We will represent every amount as an integer count of the currency's minor
unit (cents for USD and EUR), carried with its currency code. Parsing and
formatting go through `src/money/`, which never converts to a JavaScript
`number` with a fractional part. Arithmetic is integer arithmetic; any split
distributes the remainder explicitly.

## Options considered

### Option A: integer minor units (chosen)

Exact, fast, and trivially serializable. Needs care at parse and format time.

### Option B: a decimal library

Exact, but adds a dependency and a second numeric type to every call site.

### Option C: Do nothing (JavaScript numbers)

Simple, and wrong by a cent often enough to matter.

## Trade-offs

Currencies with three minor-unit digits, or none, need a per-currency
exponent before we support them.

## Consequences

- Easier: sums and comparisons are exact.
- Harder: every boundary (HTTP, CSV, database) must convert explicitly.
- **How we would know this was wrong:** a reconciliation difference traced to
  rounding inside `src/money/`.
- Revisit if: we add a currency whose exponent is not 2.
