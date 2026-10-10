import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Ledger } from '../src/ledger/events.ts';
import { IdempotencyStore } from '../src/http/idempotency.ts';
import { createTransfer } from '../src/handlers/transfers.ts';

const body = { from: 'alice', to: 'bob', amount: '25.00', currency: 'USD' };

test('a transfer without an Idempotency-Key is rejected', () => {
  const result = createTransfer({ headers: {}, body }, new Ledger(), new IdempotencyStore());
  assert.equal(result.status, 400);
});

test('a retried transfer is replayed, not applied twice', () => {
  const ledger = new Ledger();
  const keys = new IdempotencyStore();
  const req = { headers: { 'idempotency-key': 'tx-1' }, body };
  const first = createTransfer(req, ledger, keys);
  const retry = createTransfer(req, ledger, keys);
  assert.equal(first.status, 201);
  assert.deepEqual(retry, first);
  assert.equal(ledger.balance('alice', 'USD').minor, -2500);
  assert.equal(ledger.balance('bob', 'USD').minor, 2500);
  assert.equal(ledger.postings().length, 2);
});
