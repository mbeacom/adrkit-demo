# Narration script (about 7 minutes)

Each beat names the asset or shot it plays over: `T` tapes and `G` screenshots
are in this directory, and `C`/`A` shots are in [SHOTLIST.md](SHOTLIST.md).
Times are targets.

## Act 1: decisions live in git (0:00–1:30)

| Time | Asset | Narration |
|---|---|---|
| 0:00 | G5 | This is a small payments-ledger API. The code is not the interesting part. The decisions that shape it are, and they live in `docs/adr/` as typed records next to the code. |
| 0:15 | T1 | `adr lint` validates all nine against adrkit's schema. A malformed record is an error, not a style nit. |
| 0:30 | T2 | `adr graph` shows the corpus at a glance: five accepted, one proposed, one rejected, one superseded, one deprecated, and how they relate. |
| 0:45 | T3 | Focus on one record and you get its neighborhood: event sourcing replaced the CRUD ledger, relates to Postgres, and a proposal builds on it. |
| 0:55 | T4 | `adr explain` answers the question a reviewer actually has: which decisions govern this file? Money is governed by its path pattern. The transfers handler declares the idempotency decision itself with a one-line `@adr` comment. And this legacy file still points at a superseded record, so adrkit warns that the marker is stale. That warning is advisory; it never fails anything. |
| 1:15 | T5 | Records carry dates, and supersession closes a record's window. So `--as-of` answers what governed the ledger last September: the CRUD decision, not the event-sourcing one that came later. Only standing is re-dated; the file and patterns are today's. |

## Act 2: planning with Spec Kit (1:30–2:30)

| Time | Asset | Narration |
|---|---|---|
| 1:30 | C4 | Spec Kit takes a feature from spec to plan. The adrkit extension adds what it lacks: before planning, pull in the decisions that govern the paths; after planning, check the plan against them. |
| 1:50 | C4 | The plan touches the ledger. The check names event sourcing as governing, and the outbox proposal as still under review, so the plan is choosing something the review board has not settled. |
| 2:15 | C4 | The after-plan hook only offers the check. It is optional, and no hook can write a record. |

## Act 3: the agent in the loop (2:30–3:45)

| Time | Asset | Narration |
|---|---|---|
| 2:30 | C1 | The adrkit plugin brings the same loop into Copilot CLI. `/adr-check` on the branch that adds float helpers: adrkit supplies the governing records, and the model judges the change against them. The judgment is the model's; the list of decisions is not a guess. |
| 2:55 | C2 | The `adr-review` workflow runs that as a pipeline: collect the change, run `adr check` and `adr lint` for free, then one checker call per governing decision. It is advisory. Gate on its result status, not its exit code. |
| 3:15 | C3 | In VS Code, the read-only MCP server gives any agent the corpus, including the graveyard. Ask about DynamoDB and it finds the record where we already said no, and why. |

## Act 4: enforcement on the pull request (3:45–5:00)

| Time | Asset | Narration |
|---|---|---|
| 3:45 | G1 | On every pull request, the governing-decisions Action comments which decisions govern the change: money by its path, idempotency by the marker in the handler. It is pinned to an immutable release, uses only the default token, and approves nothing. |
| 4:05 | G2, T6 | Now the honest part. This PR adds float math, which contradicts the money decision, and the checks pass. adrkit does not read code for meaning. What it does is put the money decision on the PR, in front of the reviewer and Copilot's reviewer, with the stale marker flagged alongside. Locally, `adr check` says the same thing and exits 0. |
| 4:35 | G3 | What does fail is a broken record. This PR adds an accepted ADR that supersedes one that does not exist. The Action fails the job, because a record changed by the PR has an error. |

## Act 5: architecture review (5:00–6:15)

| Time | Asset | Narration |
|---|---|---|
| 5:00 | G6, G4 | Proposing a decision is a pull request too. The queue Action keeps one managed issue in sync with the open proposals: tier, SLA, deadline, approvals, objections. The new proposal shows up next to the outbox one. |
| 5:20 | T7 | In the terminal, the same queue tells you why the outbox proposal is blocked: one approval of two, and an open objection. |
| 5:35 | T8 | Review state is recorded in the record. Approve, and accept is still refused: the objection is open. Only the objector can resolve it. Then accept sets status, who ratified it, and when, and changes no other line. Nothing is committed; the diff goes through a pull request like any other change. |

## Act 6: the Copilot app (6:15–7:15)

| Time | Asset | Narration |
|---|---|---|
| 6:15 | A1 | In the Copilot app, an edit to the money module gets a note naming the decision that governs it. The hook adds context; it cannot block the edit. |
| 6:30 | A2, A3 | The decision-review canvas shows the session's change, including uncommitted edits, and the decisions that govern it, for free. Running the review costs one checker call per governing decision, and the button says so before you click. |
| 6:50 | A4 | The decision board maps the whole corpus from `adr graph` and `adr queue`. Select the outbox proposal and approve it as yourself. GitHub Copilot asks you to confirm in its own dialog, which the model cannot answer for you. The board never says a proposal is ready, and ratifying stays a human step in the terminal. |
| 7:10 | G5 | Canvases exist only in the Copilot app. Everything else here works from the terminal and CI. The repository and the scripts that built every PR are linked below. |
