import { test } from 'node:test';
import assert from 'node:assert/strict';
import { add, amount, formatDecimal, parseDecimal } from '../src/money/amount.ts';

test('parses and formats decimals exactly', () => {
  assert.equal(parseDecimal('12.34', 'USD').minor, 1234);
  assert.equal(parseDecimal('0.1', 'USD').minor, 10);
  assert.equal(formatDecimal(amount(-5, 'EUR')), '-0.05');
});

test('0.10 + 0.20 is exactly 0.30', () => {
  const sum = add(parseDecimal('0.10', 'USD'), parseDecimal('0.20', 'USD'));
  assert.equal(sum.minor, 30);
  assert.equal(formatDecimal(sum), '0.30');
});

test('rejects fractional minor units and mixed currencies', () => {
  assert.throws(() => amount(1.5, 'USD'), RangeError);
  assert.throws(() => add(amount(1, 'USD'), amount(1, 'EUR')), TypeError);
});

test('allocate splits 10.00 three ways without losing a cent', async () => {
  const { allocate } = await import('../src/money/amount.ts');
  const shares = allocate(parseDecimal('10.00', 'USD'), 3).map((a) => a.minor);
  assert.deepEqual(shares, [334, 333, 333]);
  assert.equal(shares.reduce((x, y) => x + y, 0), 1000);
});
