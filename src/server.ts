// A tiny payments-ledger HTTP API. Run with: node src/server.ts

import { createServer, type IncomingMessage, type ServerResponse } from 'node:http';
import { Ledger } from './ledger/events.ts';
import { IdempotencyStore } from './http/idempotency.ts';
import { createTransfer } from './handlers/transfers.ts';
import { getBalance } from './handlers/balances.ts';

export function createApp(ledger = new Ledger(), keys = new IdempotencyStore()) {
  return createServer(async (req: IncomingMessage, res: ServerResponse) => {
    const url = new URL(req.url ?? '/', 'http://localhost');
    const send = (status: number, body: unknown) => {
      res.writeHead(status, { 'content-type': 'application/json' });
      res.end(JSON.stringify(body));
    };

    if (req.method === 'POST' && url.pathname === '/transfers') {
      let body: unknown;
      try {
        const chunks: Buffer[] = [];
        for await (const chunk of req) chunks.push(chunk as Buffer);
        body = JSON.parse(Buffer.concat(chunks).toString('utf8') || '{}');
      } catch {
        return send(400, { error: 'body must be JSON' });
      }
      const result = createTransfer({ headers: req.headers, body }, ledger, keys);
      return send(result.status, result.body);
    }

    const balance = /^\/accounts\/([^/]+)\/balance$/.exec(url.pathname);
    if (req.method === 'GET' && balance) {
      const result = getBalance(decodeURIComponent(balance[1]!), url.searchParams.get('currency'), ledger);
      return send(result.status, result.body);
    }

    send(404, { error: 'not found' });
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 3000);
  createApp().listen(port, () => console.log(`ledger API on http://localhost:${port}`));
}
