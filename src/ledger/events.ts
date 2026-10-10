// The ledger is an append-only list of postings (docs/adr/0006).
// A balance is a fold over an account's postings; nothing is updated in place.

import { add, amount, type Amount, type Currency } from '../money/amount.ts';

export interface Posting {
  readonly seq: number;
  readonly transferId: string;
  readonly account: string;
  readonly amount: Amount;
}

export class Ledger {
  readonly #postings: Posting[] = [];

  /** Append a balanced transfer: debit `from`, credit `to`. */
  transfer(transferId: string, from: string, to: string, value: Amount): readonly Posting[] {
    if (value.minor <= 0) throw new RangeError('transfer amount must be positive');
    const debit = this.#append(transferId, from, amount(-value.minor, value.currency));
    const credit = this.#append(transferId, to, value);
    return [debit, credit];
  }

  balance(account: string, currency: Currency): Amount {
    return this.#postings
      .filter((p) => p.account === account && p.amount.currency === currency)
      .reduce((sum, p) => add(sum, p.amount), amount(0, currency));
  }

  postings(): readonly Posting[] {
    return [...this.#postings];
  }

  #append(transferId: string, account: string, value: Amount): Posting {
    const posting = Object.freeze({ seq: this.#postings.length + 1, transferId, account, amount: value });
    this.#postings.push(posting);
    return posting;
  }
}
