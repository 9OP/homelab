#!/bin/bash
# Backup script for *arr application configs
# Creates a single tar.gz archive of all Docker volumes
# Automatically detects volumes from docker-compose.yml

set -e

BACKUP_DIR="/mnt/storage/backups"
COMPOSE_FILE="${COMPOSE_FILE:-/opt/homelab/docker-compose.yml}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/homelab-configs-${DATE}.tar.gz"
TEMP_DIR="/tmp/homelab-backup-${DATE}"

echo "[$(date)] Starting backup..."

# Extract volume names from docker-compose.yml (volumes ending with _config)
echo "[$(date)] Detecting volumes from docker-compose.yml..."
VOLUMES=$(grep -E '^\s+\w+_config:' "${COMPOSE_FILE}" | sed 's/://g' | tr -d ' ' | sort)

if [ -z "$VOLUMES" ]; then
  echo "Error: No config volumes found in ${COMPOSE_FILE}"
  exit 1
fi

echo "[$(date)] Found volumes:"
echo "$VOLUMES" | sed 's/^/  - /'

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Create temp directory structure and backup each volume
VOLUME_DIRS=()
for VOLUME in $VOLUMES; do
  echo "[$(date)] Backing up ${VOLUME}..."
  mkdir -p "${TEMP_DIR}/${VOLUME}"

  docker run --rm \
    -v "homelab_${VOLUME}:/source:ro" \
    -v "${TEMP_DIR}/${VOLUME}":/backup \
    alpine sh -c "cp -a /source/. /backup/"

  VOLUME_DIRS+=("${VOLUME}")
done

# Create single archive from all backups
echo "[$(date)] Creating backup archive..."
# Use tar with --ignore-failed-read to continue even if some files are unreadable
# Exclude socket files which can't be archived
tar --ignore-failed-read \
  --exclude='*.sock' \
  --exclude='*-socket' \
  --exclude='ipc-socket' \
  -czf "${BACKUP_FILE}" \
  -C "${TEMP_DIR}" \
  "${VOLUME_DIRS[@]}" 2>&1 | grep -vE "(socket ignored|Permission denied)" || true

# Verify archive was created successfully
if [ ! -f "${BACKUP_FILE}" ] || [ ! -s "${BACKUP_FILE}" ]; then
  echo "Error: Backup archive was not created or is empty"
  rm -rf "${TEMP_DIR}"
  exit 1
fi

# Create checksum
echo "[$(date)] Creating checksum..."
cd "${BACKUP_DIR}"
sha256sum "$(basename ${BACKUP_FILE})" > "homelab-configs-${DATE}.sha256"

# Cleanup temp directory
rm -rf "${TEMP_DIR}"

# Keep only last 7 backups
echo "[$(date)] Cleaning old backups..."
cd "${BACKUP_DIR}"
ls -t homelab-configs-*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f
ls -t homelab-configs-*.sha256 2>/dev/null | tail -n +8 | xargs -r rm -f

echo "[$(date)] Backup complete: ${BACKUP_FILE}"
echo "[$(date)] Backup size:"
du -sh "${BACKUP_FILE}"
