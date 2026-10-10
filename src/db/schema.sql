-- Postgres schema for the ledger (docs/adr/0004, docs/adr/0006).
-- This demo runs in memory; the schema shows where the real tables would live.

CREATE TABLE ledger_postings (
  seq          BIGSERIAL PRIMARY KEY,
  transfer_id  TEXT        NOT NULL,
  account      TEXT        NOT NULL,
  amount_minor BIGINT      NOT NULL,  -- integer minor units (docs/adr/0002)
  currency     CHAR(3)     NOT NULL,
  posted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE idempotency_keys (
  key         TEXT PRIMARY KEY,
  status      INTEGER NOT NULL,
  body        JSONB   NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
