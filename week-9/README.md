# Week 9 — Data Observability and Backup

## Overview
This lab demonstrates PostgreSQL monitoring, automated backups, and database recovery using Kubernetes, Prometheus, and OpenTofu.

## Database Monitoring
The PostgreSQL exporter exposes metrics on port 9187.

Useful Prometheus queries:

- `pg_up`
- `pg_database_size_bytes{datname!~"template.*"} / 1024 / 1024`
- `sum by (relname) (pg_stat_user_tables_n_live_tup)`

The exporter reported `pg_up = 1`, indicating a healthy database connection.

## Automated Backups
The backup script runs every five minutes using cron.

Backup location: `/home/thai/backups/`

The script keeps the newest 12 backups.

To create a backup manually:

    ./week-9/backup.sh

To view backups:

    ls -lh ~/backups/

## Restore Procedure
1. Select a verified backup created before the incident.
2. Restore the database using `week-9/restore.sh`.
3. Verify the restored tables and records.
4. Check PostgreSQL and Prometheus metrics.

Example commands:

    ./week-9/restore.sh /home/thai/backups/BACKUP_FILENAME.dump
    ./week-9/sql.sh 'SELECT COUNT(*) FROM tickets;'

During an actual incident, avoid selecting a backup made after the data was deleted.

## Recovery Drill Results
- Date: November 4, 2026
- Simulated incident: Dropped the public database schema
- Tickets before incident: 3
- Tickets after recovery: 3
- Measured recovery time: 24 seconds
- Backup age at incident: 288 seconds
- Recovery result: Successful

## Health Check
Run:

    ./week-9/check.sh

The script checks PostgreSQL readiness, exporter metrics, backup freshness, backup contents, and cron configuration.

All five checks passed.

## Limitations
Backups are currently stored on the same Ubuntu VM. A complete VM failure could destroy both the database and backups. Backups should also be stored off the VM.

A five-minute cron schedule only works while the VM is running. Regular restore testing is important.
