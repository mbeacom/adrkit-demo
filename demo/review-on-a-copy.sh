#!/usr/bin/env bash
# Act 5: record review state and ratify ADR-0009, on a throwaway copy.
# Never run these writing commands against the pushed main branch: copy the
# corpus to a temporary directory and work there.
set -euo pipefail
ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
ADR="$ROOT/node_modules/.bin/adr"
WORK="$(mktemp -d)/ledger"
mkdir -p "$WORK"
cp -R "$ROOT/docs" "$WORK/docs"
cd "$WORK"
echo "working on a copy in $WORK"
set -x
"$ADR" queue --format terminal
"$ADR" approve 0009 --by @mbeacom
"$ADR" object 0009 --by @octocat --summary "Name the broker before we accept"
"$ADR" resolve 0009 --objection 2 --by @octocat
"$ADR" accept 0009 --by @mbeacom || true
"$ADR" resolve 0009 --objection 1 --by @hubot
"$ADR" accept 0009 --by @mbeacom
"$ADR" lint
