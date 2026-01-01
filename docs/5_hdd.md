# External HDD Setup

Mount external HDD as main storage.

**Filesystem:** exFAT (Linux, macOS, Windows compatible)
**Mount:** `/mnt/storage`

## 1. Identify Disk

```sh
lsblk
# Find your HDD (e.g., /dev/sda)
```

## 2. Install exFAT Support

```sh
sudo apt-get update
sudo apt-get install -y exfat-fuse exfatprogs
```

## 3. Format and Partition

```sh
DISK=/dev/sda

# Wipe and partition
sudo wipefs -a $DISK
sudo parted -s $DISK mklabel gpt
sudo parted -s $DISK mkpart primary 0% 100%
sudo partprobe $DISK
sleep 2

# Format
sudo mkfs.exfat -n STORAGE ${DISK}1
```

## 4. Mount Permanently

```sh
# Get UUID
UUID=$(sudo blkid -s UUID -o value ${DISK}1)

# Create mount point
sudo mkdir -p /mnt/storage

# Add to fstab
echo "UUID=$UUID /mnt/storage exfat defaults,nofail,uid=1000,gid=1000 0 0" | sudo tee -a /etc/fstab

# Mount
sudo mount -a
```

## 5. Set Permissions

```sh
sudo chown -R $USER:$USER /mnt/storage
chmod 755 /mnt/storage
```

## 6. Verify

```sh
df -h /mnt/storage
```

## 7. Set directories

```sh
mkdir -p /mnt/storage/config/qbittorrent
mkdir -p /mnt/storage/downloads
sudo chown -R $USER:$USER /mnt/storage/config /mnt/storage/downloads
```
