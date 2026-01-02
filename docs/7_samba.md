# Samba File Sharing

SMB/CIFS network file sharing for `/mnt/storage`. Works with exFAT filesystems.

## Server Setup

```sh
# Install
sudo apt update
sudo apt install samba

# Configure
sudo nano /etc/samba/smb.conf

# Add at the end:
[storage]
   path = /mnt/storage
   browseable = yes
   read only = no
   guest ok = yes
   create mask = 0775
   directory mask = 0775
   force user = martin

# Apply
testparm
sudo systemctl restart smbd
sudo systemctl enable smbd
```

## Client Access

**Windows:** `\\192.168.1.x\storage`

**macOS:** `smb://192.168.1.x/storage` (Finder → Go → Connect to Server)

**Linux:**

```sh
sudo apt install cifs-utils
sudo mount -t cifs //192.168.1.x/storage /mnt/media -o guest,uid=1000,gid=1000

# Permanent in /etc/fstab:
//192.168.1.x/storage /mnt/media cifs guest,uid=1000,gid=1000,file_mode=0755,dir_mode=0755 0 0
```

**Kodi:** Protocol: Windows network (SMB), Server: `192.168.1.x`, Share: `storage`

## Troubleshooting

```sh
# Check status
sudo systemctl status smbd

# List shares
smbclient -L 192.168.1.x -N

# View connections
sudo smbstatus

# Check logs
sudo tail -f /var/log/samba/log.smbd

# Test config
testparm

# Restart
sudo systemctl restart smbd
```
