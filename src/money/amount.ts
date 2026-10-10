// Amounts are integer counts of a currency's minor unit (cents).
// docs/adr/0002 governs this directory through its `affects` pattern.

export type Currency = 'USD' | 'EUR';

export interface Amount {
  readonly minor: number;
  readonly currency: Currency;
}

const CURRENCIES: ReadonlySet<string> = new Set(['USD', 'EUR']);

export function isCurrency(value: unknown): value is Currency {
  return typeof value === 'string' && CURRENCIES.has(value);
}

export function amount(minor: number, currency: Currency): Amount {
  if (!Number.isSafeInteger(minor)) {
    throw new RangeError(`amount must be an integer number of minor units, got ${minor}`);
  }
  return { minor, currency };
}

function sameCurrency(a: Amount, b: Amount): void {
  if (a.currency !== b.currency) {
    throw new TypeError(`currency mismatch: ${a.currency} vs ${b.currency}`);
  }
}

export function add(a: Amount, b: Amount): Amount {
  sameCurrency(a, b);
  return amount(a.minor + b.minor, a.currency);
}

export function negate(a: Amount): Amount {
  return amount(-a.minor, a.currency);
}

/** Parse a decimal string such as "12.34" without ever creating a float. */
export function parseDecimal(text: string, currency: Currency): Amount {
  const match = /^(-)?(\d+)(?:\.(\d{1,2}))?$/.exec(text.trim());
  if (!match) throw new SyntaxError(`not a decimal amount: ${JSON.stringify(text)}`);
  const [, sign, whole, fraction = ''] = match;
  const minor = Number(whole) * 100 + Number(fraction.padEnd(2, '0'));
  return amount(sign ? -minor : minor, currency);
}

/** Format minor units as a decimal string, e.g. 1234 -> "12.34". */
export function formatDecimal(a: Amount): string {
  const sign = a.minor < 0 ? '-' : '';
  const abs = Math.abs(a.minor);
  const whole = Math.trunc(abs / 100);
  const cents = String(abs % 100).padStart(2, '0');
  return `${sign}${whole}.${cents}`;
}
