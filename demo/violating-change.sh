#!/usr/bin/env bash
# Act 4, PR 2: a change that contradicts ADR-0002 by introducing float math.
#
# Be precise about what happens here. adrkit does not read code semantically,
# so it cannot detect float math, and this PR's checks pass. What it does is
# put the governing decision in front of the reviewer, and in front of
# Copilot's reviewer, on the PR itself. It also touches the legacy file whose
# @adr marker still names a superseded record, so the comment shows a
# stale-marker claim. Markers never change the exit code.
source "$(dirname "$0")/lib.sh"
BRANCH=demo/violating-change
start_branch "$BRANCH"

cat >> src/money/amount.ts <<'TS'

/** Convenience for the dashboard: an amount in major units (dollars). */
export function toMajorUnits(a: Amount): number {
  return a.minor / 100;
}

/** Accept a JavaScript number of dollars, e.g. 19.99. */
export function fromMajorUnits(value: number, currency: Currency): Amount {
  return amount(Math.round(value * 100), currency);
}
TS

perl -0pi -e 's/  balance: Amount;\n/  balance: Amount;\n  balanceDollars: number;\n/' src/ledger/legacy-balance-row.ts

npm test >/dev/null
commit_all "feat(money): add major-unit helpers for the dashboard"
publish "$BRANCH" "Add major-unit (dollar) helpers for the dashboard" "$(cat <<'MD'
I am adding `toMajorUnits()` and `fromMajorUnits()` so the dashboard can work in dollars, and a `balanceDollars` field on the legacy balance row.

**This PR deliberately contradicts ADR-0002** ("Represent money as integer minor units"): it converts amounts to and from JavaScript floats. It is demo PR 2 of 4 for [adrkit](https://github.com/mbeacom/adrkit).

What to look for, stated honestly:

- The tests pass and the governing-decisions check passes. adrkit does not read code semantically and cannot detect float math.
- What adrkit does is put ADR-0002 on this PR, in the governing-decisions comment, where the reviewer and Copilot's reviewer can see it.
- The legacy file still carries `@adr 0003`, a superseded record, so the comment lists it under marker claims needing attention (a `stale-marker` warning). Markers are advisory and never fail the job.

Reproduce with `demo/violating-change.sh`.
MD
)"
