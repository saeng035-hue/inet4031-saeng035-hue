#!/usr/bin/env bash
# Back up the database to ~/backups, check the file, and keep only the newest few.
# Safe to run by hand or from cron. Usage: ./week-9/backup.sh

set -eu

export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
umask 077

BACKUPS="$HOME/backups"
KEEP=12

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*"; }
trap 'log "FAILED. Nothing was kept, and the next run tries again."' ERR

# Take turns: only one backup at a time.
exec 9>"$HOME/.backup.lock"
if ! flock -n 9; then
  log "another backup is running, skipping"
  exit 0
fi

# Check whether the cluster and database are ready.
if ! kubectl get nodes >/dev/null 2>&1; then
  log "WAITING: the cluster is not answering yet (is k3s running?)"
  exit 0
fi

if ! kubectl exec deploy/db -- sh -c 'pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"' >/dev/null 2>&1; then
  log "WAITING: the database is not accepting connections yet"
  exit 0
fi

mkdir -p "$BACKUPS"
FILE="$BACKUPS/db-$(date +%Y%m%d-%H%M%S).dump"
PARTIAL="$FILE.partial"
trap 'rm -f "$PARTIAL"' EXIT

# Create a logical backup.
kubectl exec deploy/db -- sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" --format=custom' > "$PARTIAL"

# Verify the backup contains table data.
listing="$(kubectl exec -i deploy/db -- pg_restore --list < "$PARTIAL")"
tables="$(printf '%s\n' "$listing" | grep -c ' TABLE DATA ' || true)"

if [ "$tables" -eq 0 ]; then
  log "SKIPPED: the database has no tables, so the existing backups are kept as they are"
  exit 1
fi

mv "$PARTIAL" "$FILE"

# Keep the newest 12 backups.
ls -1t "$BACKUPS"/db-*.dump | tail -n +$((KEEP + 1)) | xargs -r rm --

log "backed up ${FILE##*/} ($(du -h "$FILE" | cut -f1), $tables table(s)), keeping the newest $KEEP"
