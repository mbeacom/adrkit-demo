// GET /accounts/:id/balance. Read-only, so no idempotency key.

import { formatDecimal, isCurrency } from '../money/amount.ts';
import type { Ledger } from '../ledger/events.ts';
import type { StoredResponse } from '../http/idempotency.ts';

export function getBalance(account: string, currency: string | null, ledger: Ledger): StoredResponse {
  const code = currency ?? 'USD';
  if (!isCurrency(code)) return { status: 422, body: { error: 'unsupported currency' } };
  return { status: 200, body: { account, currency: code, balance: formatDecimal(ledger.balance(account, code)) } };
}
