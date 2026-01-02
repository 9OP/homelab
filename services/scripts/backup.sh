#!/bin/sh
set -e

BACKUP_DIR="/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

echo "[$(date)] Starting backup..."

# Backup each volume
for volume in jellyfin_config prowlarr_config radarr_config; do
    echo "[$(date)] Backing up $volume..."
    tar czf "$BACKUP_DIR/${volume}_${TIMESTAMP}.tar.gz" -C "/volumes/$volume" .
done

# Remove old backups
echo "[$(date)] Cleaning up old backups (older than $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete

echo "[$(date)] Backup completed successfully"
