// Nightly CSV balance export (docs/adr/0008, now deprecated).

import { formatDecimal, type Currency } from '../money/amount.ts';
import type { Ledger } from '../ledger/events.ts';

export function balancesCsv(ledger: Ledger, accounts: readonly string[], currency: Currency): string {
  const rows = accounts.map((account) => `${account},${currency},${formatDecimal(ledger.balance(account, currency))}`);
  return ['account,currency,balance', ...rows].join('\n') + '\n';
}
