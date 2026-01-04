#!/bin/bash
# Restore script for *arr application configs
# Restores Docker volumes from single backup file
# Automatically detects volumes from docker-compose.yml

set -e

COMPOSE_FILE="${COMPOSE_FILE:-/opt/homelab/docker-compose.yml}"

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

# Extract volume names from docker-compose.yml (volumes ending with _config)
echo "[$(date)] Detecting volumes from docker-compose.yml..."
VOLUMES=$(grep -E '^\s+\w+_config:' "${COMPOSE_FILE}" | sed 's/://g' | tr -d ' ' | sort)

if [ -z "$VOLUMES" ]; then
  echo "Error: No config volumes found in ${COMPOSE_FILE}"
  exit 1
fi

echo "[$(date)] Found volumes:"
echo "$VOLUMES" | sed 's/^/  - /'

# Get service names from volumes (remove _config suffix)
SERVICES=$(echo "$VOLUMES" | sed 's/_config$//' | tr '\n' ' ')

# Extract backup to temp directory
echo "[$(date)] Extracting backup..."
mkdir -p "${TEMP_DIR}"
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

# Stop services
echo "[$(date)] Stopping services..."
cd /opt/homelab
docker compose stop $SERVICES

# Restore each volume
for VOLUME in $VOLUMES; do
  if [ -d "${TEMP_DIR}/${VOLUME}" ]; then
    echo "[$(date)] Restoring ${VOLUME}..."
    docker run --rm \
      -v "homelab_${VOLUME}:/target" \
      -v "${TEMP_DIR}/${VOLUME}":/source:ro \
      alpine sh -c "rm -rf /target/* /target/..?* /target/.[!.]* 2>/dev/null || true && cp -a /source/. /target/"
  else
    echo "[$(date)] Warning: ${VOLUME} not found in backup, skipping..."
  fi
done

# Cleanup temp directory
rm -rf "${TEMP_DIR}"

# Start services
echo "[$(date)] Starting services..."
docker compose up -d $SERVICES

echo "[$(date)] Restore complete!"
echo "Services are starting up. Check status with: docker compose ps"
