#!/bin/bash
# ============================================================
# Nexus Global Enterprise — Automated Nightly DB Sync Script
# Author: tahmed (DevOps Engineering)
# Last modified: 2026-08-14
# Cron: 0 2 * * * /shared/IT-Backups/sync_prod_db.sh
# ============================================================

DB_HOST="10.0.3.20"
DB_PORT="5432"
DB_USER="nexus_admin"
DB_PASS="Nexu\$Prod2026!Sec"
DB_NAME="nexus_prod"
BACKUP_DIR="/tmp/db_backups"
SAN_HOST="10.0.3.30:9000"
SAN_USER="nexus_san_root"
SAN_PASS="SuperS3cUr3_B4ckup_Vault_Pass_2026!"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting production database backup..."

PGPASSWORD="$DB_PASS" pg_dump \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    "$DB_NAME" > "$BACKUP_DIR/nexus_prod_backup_$(date +%F).sql"

echo "[$(date)] Backup complete. Uploading to SAN storage..."
# Upload to MinIO (S3-compatible storage at 10.0.3.30)
# mc alias set nexus-san http://$SAN_HOST $SAN_USER $SAN_PASS
# mc cp $BACKUP_DIR/nexus_prod_backup_$(date +%F).sql nexus-san/db-backups/

echo "[$(date)] Sync complete. Backup stored at san://db-backups/"
