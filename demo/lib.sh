#!/usr/bin/env bash
# Shared helpers for the demo scripts. Each script recreates its branch from
# origin/main, commits one change, and (unless DEMO_PUSH=0) pushes the branch
# and opens or updates its pull request.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
ADR="$ROOT/node_modules/.bin/adr"

require_clean_tree() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "working tree is not clean; commit or stash first" >&2
    exit 1
  fi
}

start_branch() {
  local branch="$1"
  require_clean_tree
  [[ -x "$ADR" ]] || npm ci
  if git remote get-url origin >/dev/null 2>&1; then
    git fetch --quiet origin main
    git switch --quiet -C "$branch" origin/main
  else
    git switch --quiet -C "$branch" main
  fi
}

commit_all() {
  git add -A
  # DEMO_COMMIT_TRAILER, when set, is appended as a commit trailer.
  git commit --quiet -s -m "$1" ${DEMO_COMMIT_TRAILER:+--trailer "$DEMO_COMMIT_TRAILER"}
}

publish() {
  local branch="$1" title="$2" body="$3"
  # DEMO_PR_FOOTER, when set, is appended to the pull request body.
  if [[ -n "${DEMO_PR_FOOTER:-}" ]]; then
    body="$body"$'\n\n'"$DEMO_PR_FOOTER"
  fi
  if [[ "${DEMO_PUSH:-1}" == "0" ]]; then
    echo "DEMO_PUSH=0: left $branch local, not pushed"
    return
  fi
  git push --quiet --force-with-lease -u origin "$branch"
  if gh pr view "$branch" --json number >/dev/null 2>&1; then
    gh pr view "$branch" --json url --jq .url
  else
    gh pr create --head "$branch" --base main --title "$title" --body "$body"
  fi
}
