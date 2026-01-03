#!/bin/bash
# Backup script for *arr application configs
# Creates a single tar.gz archive of all Docker volumes

set -e

BACKUP_DIR="/mnt/storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/homelab-configs-${DATE}.tar.gz"
TEMP_DIR="/tmp/homelab-backup-${DATE}"

echo "[$(date)] Starting backup..."

# Create backup directory and temp structure
mkdir -p "${BACKUP_DIR}"
mkdir -p "${TEMP_DIR}/prowlarr_config"
mkdir -p "${TEMP_DIR}/radarr_config"
mkdir -p "${TEMP_DIR}/sonarr_config"
mkdir -p "${TEMP_DIR}/qbittorrent_config"
# mkdir -p "${TEMP_DIR}/jellyfin_config"

# Backup each volume directly to temp directory (uncompressed)
echo "[$(date)] Backing up Prowlarr config..."
docker run --rm \
  -v homelab_prowlarr_config:/source:ro \
  -v "${TEMP_DIR}/prowlarr_config":/backup \
  alpine sh -c "cp -a /source/. /backup/"

echo "[$(date)] Backing up Radarr config..."
docker run --rm \
  -v homelab_radarr_config:/source:ro \
  -v "${TEMP_DIR}/radarr_config":/backup \
  alpine sh -c "cp -a /source/. /backup/"

echo "[$(date)] Backing up Sonarr config..."
docker run --rm \
  -v homelab_sonarr_config:/source:ro \
  -v "${TEMP_DIR}/sonarr_config":/backup \
  alpine sh -c "cp -a /source/. /backup/"

echo "[$(date)] Backing up qBittorrent config..."
docker run --rm \
  -v homelab_qbittorrent_config:/source:ro \
  -v "${TEMP_DIR}/qbittorrent_config":/backup \
  alpine sh -c "cp -a /source/. /backup/"

# echo "[$(date)] Backing up Jellyfin config..."
# docker run --rm \
#   -v homelab_jellyfin_config:/source:ro \
#   -v "${TEMP_DIR}/jellyfin_config":/backup \
#   alpine sh -c "cp -a /source/. /backup/"

# Create single archive from all backups
echo "[$(date)] Creating backup archive..."
tar czf "${BACKUP_FILE}" -C "${TEMP_DIR}" \
  prowlarr_config \
  radarr_config \
  sonarr_config \
  qbittorrent_config
  # jellyfin_config

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
