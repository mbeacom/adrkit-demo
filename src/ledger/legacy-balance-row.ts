// @adr 0003
// Leftover from the CRUD era: a mutable balance row, kept only so old
// fixtures still load. The marker above still names the superseded record,
// which is why `adr explain` and the PR comment flag it as a stale marker.

import type { Amount } from '../money/amount.ts';

export interface BalanceRow {
  account: string;
  balance: Amount;
  updatedAt: string;
}
