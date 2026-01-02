# Firewall & Security

## 1. UFW (Uncomplicated Firewall)

### Install and Basic Setup

```sh
# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp comment 'SSH'

# Allow qBittorrent (BitTorrent traffic needs public access)
sudo ufw allow 6881/tcp comment 'qBittorrent'
sudo ufw allow 6881/udp comment 'qBittorrent'

# Allow samba from local network
sudo ufw allow from 192.168.1.0/24 to any port 445 comment 'Samba'
sudo ufw allow from 192.168.1.0/24 to any port 139 comment 'Samba'

# Allow Tailscale
sudo ufw allow from 100.64.0.0/10 to any port 80 proto tcp comment 'Tailscale'

# Get Cloudflare IP ranges
curl https://www.cloudflare.com/ips-v4 -o /tmp/cf_ips_v4.txt
curl https://www.cloudflare.com/ips-v6 -o /tmp/cf_ips_v6.txt

# Allow only from Cloudflare IPs
while read ip; do
    sudo ufw allow from $ip to any port 80 proto tcp comment 'Cloudflare'
    sudo ufw allow from $ip to any port 443 proto tcp comment 'Cloudflare'
done < /tmp/cf_ips_v4.txt

# Enable UFW
sudo ufw enable

# Check status
sudo ufw status verbose
```

## 2. fail2ban

### Install fail2ban

```sh
sudo apt-get update
sudo apt-get install -y fail2ban

# Start service
sudo systemctl start fail2ban

# Enable on boot
sudo systemctl enable fail2ban

# Check status
sudo systemctl status fail2ban
```

### fail2ban Management

```sh
# Check status of all jails
sudo fail2ban-client status

# Check specific jail (e.g., sshd)
sudo fail2ban-client status sshd

# Unban an IP
sudo fail2ban-client set sshd unbanip 192.168.1.100

# Ban an IP manually
sudo fail2ban-client set sshd banip 192.168.1.100

# Reload configuration
sudo fail2ban-client reload

# Check banned IPs
sudo fail2ban-client get sshd banned

# View fail2ban log
sudo tail -f /var/log/fail2ban.log
```

## 3. Security Verification

### Check Open Ports

```sh
# List listening ports
sudo ss -tulpn

# Or with netstat
sudo netstat -tulpn

# Check from external network
# Use: https://www.yougetsignal.com/tools/open-ports/
```

### Review Logs

```sh
# SSH authentication attempts
sudo tail -f /var/log/auth.log

# fail2ban activity
sudo tail -f /var/log/fail2ban.log

# UFW blocked connections
sudo tail -f /var/log/ufw.log
```
