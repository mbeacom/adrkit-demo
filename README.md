# adrkit-demo: a payments ledger with decision memory

This is a deliberately tiny payments-ledger HTTP API whose architecture
decisions live next to the code, as typed records that tools can read. I built
it to show what [adrkit](https://github.com/mbeacom/adrkit) does on a real
repository: in the terminal, in Spec Kit, inside GitHub Copilot, on pull
requests, and in the review queue.

The API is not production code. It is small enough to read in five minutes, so
the decisions that govern it are the interesting part.

Everything here uses published releases only:

| Surface | Version | Where it is wired |
|---|---|---|
| `@adrkit/cli` | 0.18.0 (npm) | `devDependencies`; run as `npm run adr -- <command>` |
| Governing-decisions Action | `mbeacom/adrkit@v0.18.0` | [`.github/workflows/adr.yml`](.github/workflows/adr.yml) |
| ARB queue Action | `mbeacom/adrkit/packages/ci/queue@v0.18.0` | [`.github/workflows/adr-queue.yml`](.github/workflows/adr-queue.yml) |
| `@adrkit/mcp` | 0.18.0 (npm) | [`.vscode/mcp.json`](.vscode/mcp.json), [`.copilot/mcp-config.json`](.copilot/mcp-config.json) |
| `@adrkit/spec-kit` | 0.1.4 | installed under [`.specify/extensions/adrkit/`](.specify/extensions/adrkit/) |
| `adrkit` agent plugin | 0.10.0 | not vendored; install it yourself (below) |

Both Actions are pinned to the immutable `v0.18.0` release tag, not the moving
`v0` tag.

## The decisions

[`docs/adr/`](docs/adr/) holds nine records, chosen so every adrkit feature has
something to show:

| ID | Status | Title | Governs |
|---|---|---|---|
| [0001](docs/adr/0001-record-decisions-in-git-with-adrkit.md) | accepted | Record decisions in git with adrkit | `docs/adr/**` |
| [0002](docs/adr/0002-represent-money-as-integer-minor-units.md) | accepted | Represent money as integer minor units | `src/money/**` |
| [0003](docs/adr/0003-store-ledger-rows-with-crud-updates.md) | superseded by 0006 | Store ledger rows with CRUD updates | `src/ledger/**` |
| [0004](docs/adr/0004-use-postgres-as-the-system-of-record.md) | accepted | Use Postgres as the system of record | `src/db/**` |
| [0005](docs/adr/0005-use-dynamodb-for-the-ledger-store.md) | rejected, conflicts with 0004 | Use DynamoDB for the ledger store | `src/db/**` |
| [0006](docs/adr/0006-event-source-the-ledger.md) | accepted, supersedes 0003 | Event-source the ledger | `src/ledger/**` |
| [0007](docs/adr/0007-require-idempotency-keys-on-mutating-endpoints.md) | accepted | Require idempotency keys on mutating endpoints | `src/http/idempotency.ts`, plus an `@adr 0007` marker in [`src/handlers/transfers.ts`](src/handlers/transfers.ts) |
| [0008](docs/adr/0008-publish-nightly-csv-balance-exports.md) | deprecated | Publish nightly CSV balance exports | `src/reports/**` |
| [0009](docs/adr/0009-adopt-outbox-pattern-for-ledger-events.md) | proposed (ARB review) | Adopt outbox pattern for ledger events | `src/ledger/**` |

Some details are there on purpose:

- **0003 → 0006 is a supersession chain with back-dated records** (2025-01-20
  and 2026-03-02), so `adr explain --as-of` has history to travel through.
- **[`src/ledger/legacy-balance-row.ts`](src/ledger/legacy-balance-row.ts) still
  carries `@adr 0003`**, a marker naming a superseded record. adrkit reports it
  as a `stale-marker` warning. It is advisory and never changes an exit code.
- **0009 is mid-review.** It has three deciders, a quorum of 2, one approval
  (`@octocat`), one unresolved objection (`@hubot`), and a 30-day SLA from
  2026-09-28. `adr queue` and the decision board show it as blocked, and
  `adr accept` refuses it until the objection is resolved.
- **0008 is deprecated**, so `--as-of` reports its standing as undetermined
  instead of guessing when it stopped governing.

## Try it locally

You need Node 22.18 or newer (the API runs TypeScript through Node's type
stripping).

```sh
npm ci
npm test
npm run adr -- lint
npm run adr -- graph                          # terminal view on a TTY, DOT in a pipe
npm run adr -- graph --focus 0006
npm run adr -- explain src/money/amount.ts
npm run adr -- explain src/ledger/legacy-balance-row.ts
npm run adr -- explain src/ledger/events.ts --as-of 2025-09-01
npm run adr -- queue
npm start                                     # API on http://localhost:3000
```

To record review and ratify ADR-0009 without touching your checkout, run
[`demo/review-on-a-copy.sh`](demo/review-on-a-copy.sh). It copies `docs/` to a
temporary directory and runs `adr approve`, `object`, `resolve`, and `accept`
there.

## The demo pull requests

Each scripted change recreates its branch from `origin/main`, commits, pushes,
and opens (or updates) its pull request. Set `DEMO_PUSH=0` to keep the branch
local.

| Script | Branch | What it shows |
|---|---|---|
| [`demo/compliant-change.sh`](demo/compliant-change.sh) | `demo/compliant-change` | A change inside `src/money/**` and a marked handler. The Action comments ADR-0002 (via `src/money/**`) and ADR-0007 (declared by the marker), and passes. |
| [`demo/violating-change.sh`](demo/violating-change.sh) | `demo/violating-change` | Introduces float math, contradicting ADR-0002. The checks **pass**: adrkit does not read code semantically. Its value is that ADR-0002 is on the PR, in front of the reviewer and Copilot's reviewer. The comment also flags the stale `@adr 0003` marker. |
| [`demo/new-decision.sh`](demo/new-decision.sh) | `demo/new-decision` | Adds a `proposed` record, then dispatches the queue workflow on the branch so the managed **ADR ARB Queue** issue lists it. |
| [`demo/invalid-record.sh`](demo/invalid-record.sh) | `demo/invalid-record` | Adds a record that supersedes a nonexistent ADR. This is the one that **fails**: the Action fails the job when a record changed by the PR has an error finding. |

## Inside GitHub Copilot

Install the adrkit agent plugin (it is not vendored here), plus the CLI it
shells out to, which this repository already has as a dev dependency:

```sh
copilot plugin marketplace add mbeacom/adrkit
copilot plugin install adrkit@adrkit
```

That adds `/adr-context`, `/adr-check`, `/adr-draft`, `/adr-queue`, and
`/adr-backfill`, the `decision-checker` agent, and the advisory `adr-review`
workflow. In the GitHub Copilot app, the same extension adds two canvases,
`decision-review` and `decision-board`. Canvases render only in the app, not in
a CLI terminal session. The plugin ships no MCP configuration on purpose; this
repository wires `@adrkit/mcp` per project instead, in `.vscode/mcp.json` and
`.copilot/mcp-config.json`.

The Spec Kit extension is installed under `.specify/`. With the Copilot
integration from Spec Kit 1.0.5, its commands appear as the skills
`speckit-adrkit-context`, `speckit-adrkit-check`, and `speckit-adrkit-draft`,
and `speckit-plan` offers the optional check after it writes a plan.

The recording plan for these segments is in
[`docs/demo/SHOTLIST.md`](docs/demo/SHOTLIST.md), and the narration is in
[`docs/demo/SCRIPT.md`](docs/demo/SCRIPT.md). Terminal recordings and GitHub screenshots are in
[`docs/demo/`](docs/demo/).

## What adrkit does not do

I want the claims here to match the tools:

- It never approves anything. The Actions comment and maintain an issue; humans
  decide, and `adr accept` needs an explicit `--by`.
- It does not detect code that contradicts a decision. It tells you which
  decisions govern a change, so a person or an agent can judge it.
- `@adr` markers add context and advisory findings. They never fail a check.
- The `adr-review` workflow is advisory, and spends AI credits per governing
  decision.

## Links

- adrkit: <https://github.com/mbeacom/adrkit> and <https://adrkit.dev>
- Use in CI: <https://adrkit.dev/ci/>
- MCP setup: <https://adrkit.dev/mcp/>

Licensed under Apache-2.0.
