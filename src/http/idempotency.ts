// Mutating endpoints require an Idempotency-Key header (docs/adr/0007).
// The first response for a key is stored and replayed on retry.

export interface StoredResponse {
  readonly status: number;
  readonly body: unknown;
}

export class IdempotencyStore {
  readonly #responses = new Map<string, StoredResponse>();

  get(key: string): StoredResponse | undefined {
    return this.#responses.get(key);
  }

  remember(key: string, response: StoredResponse): StoredResponse {
    this.#responses.set(key, response);
    return response;
  }
}

export function readIdempotencyKey(
  headers: Record<string, string | string[] | undefined>,
  query: Record<string, string | undefined> = {},
): string | undefined {
  // Some clients cannot set custom headers; accept the key as a query parameter too.
  const raw = headers['idempotency-key'] ?? query['idempotency_key'];
  const key = Array.isArray(raw) ? raw[0] : raw;
  return key && key.trim().length > 0 ? key.trim() : undefined;
}
