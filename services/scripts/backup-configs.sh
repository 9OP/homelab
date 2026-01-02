#!/bin/bash
# Backup script for *arr application configs
# Backs up Docker volumes to /mnt/storage/backups

set -e

BACKUP_DIR="/mnt/storage/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/arr-configs-${DATE}"

echo "Starting backup at ${DATE}..."

# Create backup directory
mkdir -p "${BACKUP_PATH}"

# Backup each volume
echo "Backing up Prowlarr config..."
docker run --rm \
  -v prowlarr_config:/source:ro \
  -v "${BACKUP_PATH}":/backup \
  alpine tar czf /backup/prowlarr_config.tar.gz -C /source .

echo "Backing up Radarr config..."
docker run --rm \
  -v radarr_config:/source:ro \
  -v "${BACKUP_PATH}":/backup \
  alpine tar czf /backup/radarr_config.tar.gz -C /source .

echo "Backing up Sonarr config..."
docker run --rm \
  -v sonarr_config:/source:ro \
  -v "${BACKUP_PATH}":/backup \
  alpine tar czf /backup/sonarr_config.tar.gz -C /source .

echo "Backing up Jellyfin config..."
docker run --rm \
  -v jellyfin_config:/source:ro \
  -v "${BACKUP_PATH}":/backup \
  alpine tar czf /backup/jellyfin_config.tar.gz -C /source .

# Create checksums
echo "Creating checksums..."
cd "${BACKUP_PATH}"
sha256sum *.tar.gz > checksums.txt

# Keep only last 7 backups
echo "Cleaning old backups..."
cd "${BACKUP_DIR}"
ls -t | grep "arr-configs-" | tail -n +8 | xargs -r rm -rf

echo "Backup complete: ${BACKUP_PATH}"
echo "Backup size:"
du -sh "${BACKUP_PATH}"
