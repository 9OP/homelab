# Backup & Restore

Configs for all services (Jellyfin, Prowlarr, Radarr, Sonarr, Bazarr, qBittorrent) are backed up from named Docker volumes into a single compressed archive. Logs, caches, and media artwork are excluded.

**Location:** `/mnt/storage/backups/`
**Format:** `homelab-configs-YYYYMMDD_HHMMSS.tar.gz`
**Retention:** Last 7 backups kept automatically

## Backup

```sh
sudo /opt/Homelab/services/scripts/backup-configs.sh
```

## Restore

```sh
# List available backups
/opt/Homelab/services/scripts/restore-configs.sh

# Restore a specific backup (stops services, restores volumes, restarts)
sudo /opt/Homelab/services/scripts/restore-configs.sh /mnt/storage/backups/homelab-configs-YYYYMMDD_HHMMSS.tar.gz
```

## Other

```sh
# Verify checksum
cd /mnt/storage/backups && sha256sum -c homelab-configs-YYYYMMDD_HHMMSS.sha256

# Inspect contents
tar -tzf /mnt/storage/backups/homelab-configs-YYYYMMDD_HHMMSS.tar.gz

# Download to local machine
scp martin@vestige:/mnt/storage/backups/homelab-configs-YYYYMMDD_HHMMSS.tar.gz ~/Downloads/
```
