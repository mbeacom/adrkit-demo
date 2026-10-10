# Shot list

These are the shots I record by hand: the GitHub Copilot app, Copilot CLI, VS
Code, and Spec Kit. The terminal-only moments are already recorded as vhs
tapes in this directory (`T1`–`T8` below), and the GitHub pages are captured as
screenshots (`G1`–`G6`).

Shots that call a model spend AI credits, and each is marked with its cost.
The rest are free.

## Before any app or agent shot

1. **CLI on `PATH`.** The plugin's extension resolves `adr` from
   `$ADRKIT_CLI`, then `./node_modules/.bin/adr` only when
   `ADRKIT_ALLOW_REPO_CLI=1`, then `PATH`. An app session is a new worktree
   with no `node_modules/`, so the demo depends on a global CLI. Check it in a
   login shell: `adr --version` must print `0.18.0`
   (`npm i -g @adrkit/cli@0.18.0` if not).
2. **Plugin 0.10.0.** `copilot plugin list` shows `adrkit@adrkit (v0.10.0)`.
3. **A clean main.** `git switch main && git pull && git status` in
   `~/github/mbeacom/adrkit-demo` shows a clean tree.
4. **Launch the app with a reviewer identity.** Quit the app, then:

   ```sh
   open -n -a "GitHub Copilot" --env ADRKIT_REVIEWER=@mbeacom
   ```

   Without `ADRKIT_REVIEWER`, the decision board's review controls are
   disabled, with a note saying why.
5. **Approve the extension permission prompt** in the first session. Until
   someone answers it, the adrkit extension does not start and the session
   looks hung.
6. **An app session is a fresh worktree off `main`.** It starts with no
   changed files. The decision-review canvas counts uncommitted and untracked
   edits as the change (plugin 0.9.1 and later), so the shots below make their
   edits inside the session.

## Act 3: the agent in the loop

### C1. `/adr-check` in Copilot CLI (cost unmeasured: one prompt plus a `decision-checker` subagent)

- **Where:** a terminal, `cd ~/github/mbeacom/adrkit-demo && git switch demo/violating-change`, then `copilot`.
- **Prompt:** `/adr-check`
- **Expect:** the `decision-checker` reconciles the change against ADR-0002 and
  ADR-0006, and lists 0009 (proposed) and 0003 (history, stale marker). A
  verdict per governing decision; for ADR-0002 it should call out
  `toMajorUnits`/`fromMajorUnits` as a conflict. That judgment is the model's,
  not adrkit's: adrkit supplies which records govern.
- **Length:** 60–90 s. Switch back with `git switch main` afterwards.

### C2. The `adr-review` workflow (one `decision-checker` call per governing decision; about 0.16 credits was measured for two)

- **Where:** Copilot CLI on `demo/violating-change`.
- **Prompt:** `Run the adr-review workflow against origin/main.`
  Or from a shell: `copilot workflow run adr-review --args '{"base":"origin/main"}' --output-format json`.
- **Expect:** `result.status` is `findings` or `ok` with a verdict for 0002 and
  0006. Say in narration that the workflow is advisory: the process exits 0
  either way, and `result.status` is the gate.
- **Length:** 60–120 s.

### C3. MCP tools in VS Code Copilot Chat (one chat turn)

- **Where:** `code ~/github/mbeacom/adrkit-demo`. Open `.vscode/mcp.json` and
  click **Start** on the `adrkit` server (it runs `npx -y @adrkit/mcp@0.18.0`).
  In Copilot Chat, Agent mode, check that the tools picker lists
  `search_decisions`, `get_decision`, `get_decision_context`,
  `list_superseded`.
- **Prompt:** `Before I store ledger balances in DynamoDB, check adrkit: has this been decided before? Use the adrkit MCP tools.`
- **Expect:** the agent calls `search_decisions` (or `get_decision_context`
  for `src/db/schema.sql`) and finds ADR-0005, **rejected**, which conflicts
  with ADR-0004 (Postgres). The point: the server returns the graveyard, not
  just accepted records.
- **Length:** 45 s.

### C4. Spec Kit plan, then the adrkit check (several premium requests)

- **Where:** Copilot (VS Code Chat or Copilot CLI) in the repository on a new
  branch, for example `git switch -c demo/spec-outbox`. Spec Kit 1.0.5's
  Copilot integration registers skills, so the commands are named with
  hyphens: `/speckit-specify`, `/speckit-plan`, `/speckit-adrkit-check`. They
  correspond to adrkit's documented `/speckit.plan` and
  `/speckit.adrkit.check`.
- **Prompts, in order:**
  1. `/speckit-adrkit-context src/ledger/events.ts src/db/schema.sql`
  2. `/speckit-specify Publish every ledger posting to downstream consumers so notifications and analytics stay in sync.`
  3. `/speckit-plan`. When it offers the optional `after_plan` hook ("Check
     this plan against the decisions that govern it?"), say yes.
     Otherwise run `/speckit-adrkit-check src/ledger/events.ts`.
- **Expect:** the context step names ADR-0006 governing, ADR-0009 proposed,
  ADR-0003 superseded. The check lists the same records against the plan, and
  should point out that the plan is choosing between options ADR-0009 is still
  reviewing.
- **Length:** 2–4 min of real time; cut to about 60 s.
- **Clean up:** delete the branch and the `specs/` directory afterwards.

### C5. The `adr_check` tool in chat (one chat turn)

- **Where:** a Copilot app session (or Copilot CLI) in this repository.
- **Prompt:** `Use the adr_check tool on src/money/amount.ts and src/handlers/transfers.ts and tell me which decisions govern them and why.`
- **Expect:** a tool call to `adr_check`; ADR-0002 via `src/money/**`, ADR-0007
  declared by `src/handlers/transfers.ts:1`.
- **Length:** 30 s.

## Act 6: the Copilot app canvases

### A1. Session hooks name the governing decision after an edit (one chat turn)

- **Where:** a new app session on this repository (launched as above).
- **Prompt:** `In src/money/amount.ts, add a subtract(a, b) function next to add, using the same currency check.`
- **Expect:** after the edit, the agent's context gets a note naming
  ADR-0002 as governing the edited file. The hook passes record ids only, and
  it never blocks the edit. Show it by asking next: `What did the adrkit hook tell you after that edit?`
  Hook firing in the app is unmeasured upstream, so if nothing appears, note
  it and move on rather than retrying.
- **Length:** 45 s.

### A2. Open the decision-review canvas on uncommitted edits (free)

- **Precondition:** the session from A1, with the uncommitted edit to
  `src/money/amount.ts`.
- **Prompt:** `Open the decision-review canvas.`
- **Expect:** the panel lists `src/money/amount.ts` as changed, ADR-0002
  governing (evidence: `via path: src/money/**`), lint clean, and the open
  proposals list with ADR-0009. The button reads
  "Run review: 1 decision-checker call(s) (uses AI credits)".
- **Length:** 30 s.

### A3. `run_review` from the canvas (one `decision-checker` call)

- **Action:** click **Run review** (or prompt: `Run the review from the decision-review canvas.`).
- **Expect:** the panel follows the run and shows a verdict for ADR-0002.
  For the `subtract` edit it should be consistent. To show a conflict instead,
  first ask the agent to add `toMajorUnits` returning `a.minor / 100`.
- **Cost:** at most one `decision-checker` call per governing decision; here
  one.
- **Length:** 45–90 s.

### A4. The decision board: graph, focus, queue row, Approve (free, writes one line in the session worktree)

- **Prompt:** `Open the decision-board canvas.`
- **Expect, in order:**
  1. The graph: nine records, the 0003 → 0006 supersession reading left to
     right, 0005 conflicting with 0004, and status labels.
  2. Focus 0006 (select it and press Enter, or prompt
     `Focus the decision board on 0006.`). The board re-runs
     `adr graph --focus 0006` and shows 0003, 0004, 0007, 0009 around it.
  3. Select 0009. Its queue row shows approvals 1/2, one unresolved
     objection, within SLA, due 2026-10-28, routed to @mbeacom, @octocat,
     @hubot. The board does not say "ready"; it never does.
  4. Click **Approve as @mbeacom**, then **Confirm approval as @mbeacom**.
     The host dialog appears; its first line reads like
     `ADR-0009 · approve as @mbeacom`. Accept it.
  5. The board re-reads the queue: approvals 2/2, objection still open.
- **Then, in the session terminal:** `git diff docs/adr/0009-*` shows exactly
  one added approval. Do not commit or push it.
- **Length:** 90 s.

### A5. Ratify stays a human CLI step (free)

- **Where:** a terminal, not the app. Use `demo/review-on-a-copy.sh` or tape
  `T8`: `adr accept 0009` is refused while @hubot's objection is open, and
  succeeds after `adr resolve 0009 --objection 1 --by @hubot`.
- **Length:** use T8 (28 s).

## Note before touching the PRs

PRs #4 and #5 both add an ADR-0010. They are screenshot subjects and stay open; merging either would force the other to renumber.

## Recorded already

| ID | Asset | Moment |
|---|---|---|
| T1 | `01-lint.gif` / `.mp4` | `adr lint`: 9 records, 0 errors, 0 warnings |
| T2 | `02-graph.gif` / `.mp4` | `adr graph` terminal view |
| T3 | `03-graph-focus.gif` / `.mp4` | `adr graph --focus 0006` |
| T4 | `04-explain.gif` / `.mp4` | `adr explain` on money, handler (marker), and the legacy file (stale marker) |
| T5 | `05-explain-as-of.gif` / `.mp4` | `adr explain src/ledger/events.ts`, then `--as-of 2025-09-01` |
| T6 | `06-check-violating.gif` / `.mp4` | `adr check` on `demo/violating-change`: governing records listed, exit 0 |
| T7 | `07-queue.gif` / `.mp4` | `adr queue` terminal view: 0009 blocked |
| T8 | `08-review-accept.gif` / `.mp4` | approve, refused accept, resolve, queue, accept, diff, on a throwaway copy |
| G1 | `screenshots/pr-2-comment.png` | Compliant PR #2: comment lists 0002 (via path) and 0007 (declared by marker). Copilot's unrelated general review (3 findings) is below it; crop to the adrkit comment |
| G2 | `screenshots/pr-3-comment.png` | Violating PR #3: 0002 and 0006 governing, the stale-marker claim, collapsed proposal and history |
| G2b | `screenshots/pr-3-description.png` | PR #3's own description of what it contradicts and what adrkit can and cannot catch |
| G2c | `screenshots/pr-3-copilot-cites-adr-0002.png` | Copilot's automatic code review on PR #3, citing `docs/adr/0002-…md:32-36` against `a.minor / 100` |
| G3 | `screenshots/pr-5-checks.png` | Invalid-record PR #5: the governing-decisions run fails, "1 changed ADR record(s) failed validation" |
| G3b | `screenshots/pr-5-comment.png` | PR #5's comment: `dangling-supersedes` validation error |
| G4 | `screenshots/issue-queue.png` | Managed ADR ARB Queue issue with 0010 and 0009 |
| G5 | `screenshots/readme.png` | README rendering |
| G6 | `screenshots/pr-4-comment.png` | New-decision PR #4 and its comment |

Re-render a tape from the repository root with `vhs docs/demo/tapes/<name>.tape`.
`06` needs the branch first: `DEMO_PUSH=0 demo/violating-change.sh`, then
`git switch main`.

### G7. Copilot code review on the violating PR (already captured as G2c)

Copilot code review ran automatically on all four PRs, because automatic
review is enabled for the account; that spent premium requests outside the
demo scripts. On PR #3 it flagged `toMajorUnits` and cited ADR-0002 by file
and line. It cites the record file, so do not narrate that it read the adrkit
comment; say that the decision is in the repository and on the PR, and the
reviewer used it.
