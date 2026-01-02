#!/bin/bash
# Restore script for *arr application configs
# Restores Docker volumes from single backup file

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  echo "Example: $0 /mnt/storage/backups/homelab-configs-20260102_120000.tar.gz"
  echo ""
  echo "Available backups:"
  ls -lh /mnt/storage/backups/homelab-configs-*.tar.gz 2>/dev/null || echo "No backups found"
  exit 1
fi

BACKUP_FILE="$1"
TEMP_DIR="/tmp/homelab-restore-$$"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

echo "[$(date)] Restoring from: ${BACKUP_FILE}"
echo "WARNING: This will overwrite current configs!"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

# Extract backup to temp directory
echo "[$(date)] Extracting backup..."
mkdir -p "${TEMP_DIR}"
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

# Stop services
echo "[$(date)] Stopping services..."
cd /opt/homelab
docker compose stop prowlarr radarr sonarr jellyfin

# Restore each volume
if [ -d "${TEMP_DIR}/prowlarr_config" ]; then
  echo "[$(date)] Restoring Prowlarr config..."
  docker run --rm \
    -v homelab_prowlarr_config:/target \
    -v "${TEMP_DIR}/prowlarr_config":/source:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && cp -a /source/. /target/"
fi

if [ -d "${TEMP_DIR}/radarr_config" ]; then
  echo "[$(date)] Restoring Radarr config..."
  docker run --rm \
    -v homelab_radarr_config:/target \
    -v "${TEMP_DIR}/radarr_config":/source:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && cp -a /source/. /target/"
fi

if [ -d "${TEMP_DIR}/sonarr_config" ]; then
  echo "[$(date)] Restoring Sonarr config..."
  docker run --rm \
    -v homelab_sonarr_config:/target \
    -v "${TEMP_DIR}/sonarr_config":/source:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && cp -a /source/. /target/"
fi

if [ -d "${TEMP_DIR}/jellyfin_config" ]; then
  echo "[$(date)] Restoring Jellyfin config..."
  docker run --rm \
    -v homelab_jellyfin_config:/target \
    -v "${TEMP_DIR}/jellyfin_config":/source:ro \
    alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && cp -a /source/. /target/"
fi

# Cleanup temp directory
rm -rf "${TEMP_DIR}"

# Start services
echo "[$(date)] Starting services..."
docker compose up -d prowlarr radarr sonarr jellyfin

echo "[$(date)] Restore complete!"
echo "Services are starting up. Check status with: docker compose ps"
