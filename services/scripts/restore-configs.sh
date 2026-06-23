#!/bin/bash
# Restore service configs from a backup archive into bind-mount data dirs

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICES_DIR="$(dirname "$SCRIPT_DIR")"

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  echo "Example: $0 /mnt/storage/backups/homelab-configs-20260102_120000.tar.gz"
  echo ""
  echo "Available backups:"
  ls -lh /mnt/storage/backups/homelab-configs-*.tar.gz 2>/dev/null || echo "No backups found"
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Error: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

echo "[$(date)] Restoring from: ${BACKUP_FILE}"
echo "WARNING: This will overwrite current configs in ${SERVICES_DIR}/data/"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

echo "[$(date)] Stopping services..."
cd "${SERVICES_DIR}"
docker compose down

echo "[$(date)] Extracting backup..."
tar xzf "${BACKUP_FILE}" -C "${SERVICES_DIR}"

echo "[$(date)] Fixing permissions..."
chown -R 1000:1000 "${SERVICES_DIR}/data/"

echo "[$(date)] Starting services..."
docker compose up -d

echo "[$(date)] Restore complete! Check status with: docker compose ps"
