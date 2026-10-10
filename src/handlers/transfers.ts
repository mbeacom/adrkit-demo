// @adr 0007
// POST /transfers. Every mutating handler declares the idempotency decision.

import { isCurrency, parseDecimal } from '../money/amount.ts';
import type { Ledger } from '../ledger/events.ts';
import { readIdempotencyKey, type IdempotencyStore, type StoredResponse } from '../http/idempotency.ts';

export interface TransferRequest {
  headers: Record<string, string | string[] | undefined>;
  body: unknown;
}

export function createTransfer(req: TransferRequest, ledger: Ledger, keys: IdempotencyStore): StoredResponse {
  const key = readIdempotencyKey(req.headers);
  if (!key) return { status: 400, body: { error: 'Idempotency-Key header is required' } };

  const previous = keys.get(key);
  if (previous) return previous;

  const { from, to, amount, currency } = (req.body ?? {}) as Record<string, unknown>;
  if (typeof from !== 'string' || typeof to !== 'string' || typeof amount !== 'string' || !isCurrency(currency)) {
    return { status: 422, body: { error: 'expected { from, to, amount: "12.34", currency: "USD" | "EUR" }' } };
  }

  if (from === to) return { status: 422, body: { error: "from and to must differ" } };

  let value;
  try {
    value = parseDecimal(amount, currency);
  } catch {
    return { status: 422, body: { error: 'amount must be a decimal string with at most two places' } };
  }
  if (value.minor <= 0) return { status: 422, body: { error: 'amount must be positive' } };

  ledger.transfer(key, from, to, value);
  return keys.remember(key, { status: 201, body: { transferId: key, from, to, amount, currency } });
}
