#!/usr/bin/env bash
# Act 4, PR 1: a change that follows the decisions that govern it.
# Touches src/money/** (ADR-0002, via its affects pattern) and a handler that
# declares ADR-0007 with an @adr marker. The governing-decisions Action
# comments both records and passes.
source "$(dirname "$0")/lib.sh"
BRANCH=demo/compliant-change
start_branch "$BRANCH"

cat >> src/money/amount.ts <<'TS'

/**
 * Split an amount into `parts` shares that sum exactly to the original.
 * The remainder is spread one minor unit at a time, so no cent is lost.
 */
export function allocate(total: Amount, parts: number): Amount[] {
  if (!Number.isSafeInteger(parts) || parts <= 0) throw new RangeError('parts must be a positive integer');
  const base = Math.trunc(total.minor / parts);
  let remainder = total.minor - base * parts;
  return Array.from({ length: parts }, () => {
    const step = remainder > 0 ? 1 : remainder < 0 ? -1 : 0;
    remainder -= step;
    return amount(base + step, total.currency);
  });
}
TS

cat >> test/money.test.ts <<'TS'

test('allocate splits 10.00 three ways without losing a cent', async () => {
  const { allocate } = await import('../src/money/amount.ts');
  const shares = allocate(parseDecimal('10.00', 'USD'), 3).map((a) => a.minor);
  assert.deepEqual(shares, [334, 333, 333]);
  assert.equal(shares.reduce((x, y) => x + y, 0), 1000);
});
TS

# Reject a transfer to the same account, before anything is posted.
perl -0pi -e 's/(  let value;\n)/  if (from === to) return { status: 422, body: { error: "from and to must differ" } };\n\n$1/' src/handlers/transfers.ts

npm test >/dev/null
commit_all "feat(money): allocate an amount into shares without losing a cent"
publish "$BRANCH" "Allocate an amount into shares without losing a cent" "$(cat <<'MD'
I am adding `allocate()` to `src/money/amount.ts`. It splits an amount into equal shares and spreads the remainder one minor unit at a time, so the shares always sum to the original. It stays in integer minor units, as ADR-0002 requires.

I am also rejecting a transfer whose `from` and `to` are the same account. That handler already declares ADR-0007 with an `@adr 0007` marker.

This is demo PR 1 of 4 for [adrkit](https://github.com/mbeacom/adrkit). Watch for the governing-decisions comment: it lists ADR-0002 (matched by `src/money/**`) and ADR-0007 (declared by the marker in the handler).

Reproduce with `demo/compliant-change.sh`.
MD
)"
