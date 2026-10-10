---
schemaVersion: 0.2.0
id: "0001"
title: "Record decisions in git with adrkit"
status: accepted
date: 2025-01-06
deciders: ["@mbeacom"]
tags: [process, tooling]
scope: org
reversibility: two-way-door
blastRadius: team
relatesTo: []
affects:
  - type: path
    pattern: "docs/adr/**"
provenance:
  authoredBy: human
  ratifiedBy: "@mbeacom"
---

# ADR-0001: Record decisions in git with adrkit

## Context

The ledger API is small today, but the choices that shape it (how money is
represented, how the ledger stores history, which datastore owns it) are the
kind that get re-argued six months later by someone who was not in the room.
Coding agents now write plans against this repository too, and they have no
memory of what we already tried.

## Decision

We will record architecture decisions as typed Markdown records in
`docs/adr/`, validated by `adr lint` from `@adrkit/cli`. Each record declares
what it governs through `affects`, so CI, the CLI, and agents can answer
"which decisions govern this change?" from the repository alone.

## Options considered

### Option A: adrkit records in git (chosen)

Typed frontmatter, a linter, a resolver for `affects`, a PR comment, and a
read-only MCP server, all reading the same files.

### Option B: plain MADR templates

Readable, but nothing can answer which decision governs a file, and nothing
fails when a record is malformed.

### Option C: Do nothing

Decisions stay in chat threads and PR descriptions, where nobody finds them.

## Trade-offs

Every record needs valid frontmatter, and `affects` patterns need upkeep as
code moves.

## Consequences

- Easier: reviewers and agents see the governing decisions on every PR.
- Harder: a malformed record fails CI.
- **How we would know this was wrong:** records stop being updated, or the PR
  comment is routinely ignored.
- Revisit if: the corpus outgrows a single directory.
