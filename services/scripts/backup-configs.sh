#!/bin/bash
# Backup all service configs from named Docker volumes into a single tar.gz
# Excludes heavy assets: logs, caches, thumbnails, transcodes, artwork
# Volumes are prefixed with "homelab_" (set by `name: homelab` in docker-compose.yml)

set -e

BACKUP_DIR="/mnt/storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/homelab-configs-${DATE}.tar.gz"
TEMP_DIR="/tmp/homelab-backup-${DATE}"

VOLUMES=(
  "jellyfin_data"
  "prowlarr_config"
  "radarr_config"
  "sonarr_config"
  "bazarr_config"
  "qbittorrent_config"
)

echo "[$(date)] Starting backup..."
mkdir -p "${BACKUP_DIR}" "${TEMP_DIR}"

for vol in "${VOLUMES[@]}"; do
  echo "[$(date)] Backing up ${vol}..."
  mkdir -p "${TEMP_DIR}/${vol}"
  docker run --rm \
    -v "homelab_${vol}:/source:ro" \
    -v "${TEMP_DIR}/${vol}:/dest" \
    alpine sh -c "cp -a /source/. /dest/" 2>/dev/null \
    || echo "  Warning: homelab_${vol} not found, skipping"
done

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
  -C "${TEMP_DIR}" \
  "${VOLUMES[@]}" 2>&1 | grep -vE "(socket|Permission denied)" || true

rm -rf "${TEMP_DIR}"

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
