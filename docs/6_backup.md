# Backup & Restore

Backup all service configs (Prowlarr, Radarr, Sonarr, Jellyfin) to a single compressed archive.

**Location:** `/mnt/storage/backups/`
**Format:** `homelab-configs-YYYYMMDD_HHMMSS.tar.gz`
**Retention:** Last 7 backups kept automatically

## Create Backup

```sh
cd /opt/homelab/scripts
./backup-configs.sh
```

## Restore Backup

```sh
cd /opt/homelab/scripts

# List available backups
./restore-configs.sh

# Restore specific backup
./restore-configs.sh /mnt/storage/backups/homelab-configs-20260102_150000.tar.gz
```

## Operational Commands

```sh
# List backups
ls -lh /mnt/storage/backups/

# Verify checksum
cd /mnt/storage/backups
sha256sum -c homelab-configs-20260102_150000.sha256

# View backup contents
tar -tzf homelab-configs-20260102_150000.tar.gz

# Download backup to local machine
scp -O martin@vestigelocal:/mnt/storage/backups/homelab-configs-20260102_150000.tar.gz ~/Downloads/

# Manual cleanup (keep last 3)
cd /mnt/storage/backups
ls -t homelab-configs-*.tar.gz | tail -n +4 | xargs rm -f
ls -t homelab-configs-*.sha256 | tail -n +4 | xargs rm -f
```

## Notes

- Backups include configs/metadata only (not media files)
- Services are stopped during restore
- Media in `/mnt/storage/media/` is unaffected by restore
