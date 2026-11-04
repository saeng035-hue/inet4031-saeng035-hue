#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  exit 1
}

if kubectl exec deploy/db -- sh -c 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' >/dev/null 2>&1; then
  pass "PostgreSQL is ready"
else
  fail "PostgreSQL is not ready"
fi

if kubectl get deployment db-exporter >/dev/null 2>&1 &&
   kubectl rollout status deployment/db-exporter --timeout=30s >/dev/null 2>&1 &&
   kubectl exec deploy/db-exporter -- wget -q -O - http://localhost:9187/metrics 2>/dev/null | grep -q 'pg_up'; then
  pass "PostgreSQL exporter exposes metrics"
else
  fail "PostgreSQL exporter metrics unavailable"
fi

LATEST="$(find "$HOME/backups" -maxdepth 1 -name 'db-*.dump' -type f -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)"

if [[ -n "$LATEST" ]]; then
  AGE=$(( $(date +%s) - $(stat -c %Y "$LATEST") ))
  if (( AGE <= 900 )); then
    pass "Recent backup exists (${AGE}s old)"
  else
    fail "Latest backup is too old (${AGE}s)"
  fi
else
  fail "No backup found"
fi

POD="$(kubectl get pods -l app=db --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')"

if kubectl exec -i "$POD" -- pg_restore -l < "$LATEST" | grep -q 'TABLE DATA'; then
  pass "Backup contains table data"
else
  fail "Backup contents could not be verified"
fi

if crontab -l 2>/dev/null | grep -Fq '/week-9/backup.sh'; then
  pass "Backup cron job is installed"
else
  fail "Backup cron job is missing"
fi

echo "All Week 9 checks passed."
