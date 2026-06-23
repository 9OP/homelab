#!/bin/bash
# Restore service configs from a backup archive into named Docker volumes
# Volumes are prefixed with "homelab_" (set by `name: homelab` in docker-compose.yml)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICES_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="/tmp/homelab-restore-$$"

VOLUMES=(
  "jellyfin_data"
  "prowlarr_config"
  "radarr_config"
  "sonarr_config"
  "bazarr_config"
  "qbittorrent_config"
)

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
echo "WARNING: This will overwrite current service configs!"
read -p "Continue? (yes/no): " confirm
[ "$confirm" = "yes" ] || { echo "Restore cancelled."; exit 0; }

echo "[$(date)] Stopping services..."
cd "${SERVICES_DIR}"
docker compose down

echo "[$(date)] Extracting backup..."
mkdir -p "${TEMP_DIR}"
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

for vol in "${VOLUMES[@]}"; do
  if [ -d "${TEMP_DIR}/${vol}" ]; then
    echo "[$(date)] Restoring ${vol}..."
    docker volume create "homelab_${vol}" 2>/dev/null || true
    docker run --rm \
      -v "${TEMP_DIR}/${vol}:/source:ro" \
      -v "homelab_${vol}:/target" \
      alpine sh -c "rm -rf /target/* /target/.[!.]* 2>/dev/null; cp -a /source/. /target/"
  else
    echo "[$(date)] Warning: ${vol} not found in backup, skipping..."
  fi
done

rm -rf "${TEMP_DIR}"

echo "[$(date)] Starting services..."
docker compose up -d

echo "[$(date)] Restore complete! Check status with: docker compose ps"
