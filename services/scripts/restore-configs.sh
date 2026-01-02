#!/bin/bash
# Restore script for *arr application configs
# Restores Docker volumes from backup

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-directory>"
  echo "Example: $0 /mnt/storage/backups/arr-configs-20260102_120000"
  exit 1
fi

BACKUP_PATH="$1"

if [ ! -d "$BACKUP_PATH" ]; then
  echo "Error: Backup directory not found: ${BACKUP_PATH}"
  exit 1
fi

echo "Restoring from: ${BACKUP_PATH}"
echo "WARNING: This will overwrite current configs!"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

# Stop services
echo "Stopping services..."
cd /opt/homelab
docker compose stop prowlarr radarr sonarr jellyfin

# Restore each volume
if [ -f "${BACKUP_PATH}/prowlarr_config.tar.gz" ]; then
  echo "Restoring Prowlarr config..."
  docker run --rm \
    -v prowlarr_config:/target \
    -v "${BACKUP_PATH}":/backup:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && tar xzf /backup/prowlarr_config.tar.gz -C /target"
fi

if [ -f "${BACKUP_PATH}/radarr_config.tar.gz" ]; then
  echo "Restoring Radarr config..."
  docker run --rm \
    -v radarr_config:/target \
    -v "${BACKUP_PATH}":/backup:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && tar xzf /backup/radarr_config.tar.gz -C /target"
fi

if [ -f "${BACKUP_PATH}/sonarr_config.tar.gz" ]; then
  echo "Restoring Sonarr config..."
  docker run --rm \
    -v sonarr_config:/target \
    -v "${BACKUP_PATH}":/backup:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && tar xzf /backup/sonarr_config.tar.gz -C /target"
fi

if [ -f "${BACKUP_PATH}/jellyfin_config.tar.gz" ]; then
  echo "Restoring Jellyfin config..."
  docker run --rm \
    -v jellyfin_config:/target \
    -v "${BACKUP_PATH}":/backup:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && tar xzf /backup/jellyfin_config.tar.gz -C /target"
fi

# Start services
echo "Starting services..."
docker compose up -d prowlarr radarr sonarr jellyfin

echo "Restore complete!"
