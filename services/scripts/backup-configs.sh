#!/bin/bash
# Backup all service configs from bind-mount data dirs into a single tar.gz
# Excludes heavy assets: logs, caches, thumbnails, transcodes, artwork

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICES_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="/mnt/storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/homelab-configs-${DATE}.tar.gz"

echo "[$(date)] Starting backup..."

if [ ! -d "${SERVICES_DIR}/data" ]; then
  echo "Error: ${SERVICES_DIR}/data not found"
  exit 1
fi

mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Creating archive (excluding logs, caches, artwork)..."
tar --ignore-failed-read \
  --exclude='*.sock' \
  --exclude='*/log' \
  --exclude='*/logs' \
  --exclude='*/cache' \
  --exclude='*/Cache' \
  --exclude='*/metadata' \
  --exclude='*/MediaCover' \
  --exclude='*/Backups' \
  --exclude='*/Definitions' \
  --exclude='*/data/transcodes' \
  -czf "${BACKUP_FILE}" \
  -C "${SERVICES_DIR}" \
  data/ 2>&1 | grep -vE "(socket ignored|Permission denied)" || true

if [ ! -f "${BACKUP_FILE}" ] || [ ! -s "${BACKUP_FILE}" ]; then
  echo "Error: Backup archive was not created or is empty"
  exit 1
fi

echo "[$(date)] Creating checksum..."
cd "${BACKUP_DIR}"
sha256sum "$(basename "${BACKUP_FILE}")" > "homelab-configs-${DATE}.sha256"

echo "[$(date)] Rotating old backups (keeping last 7)..."
ls -t homelab-configs-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
ls -t homelab-configs-*.sha256 2>/dev/null | tail -n +8 | xargs -r rm -f

echo "[$(date)] Backup complete: ${BACKUP_FILE}"
echo "[$(date)] Size: $(du -sh "${BACKUP_FILE}" | cut -f1)"
