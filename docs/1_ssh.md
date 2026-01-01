# SSH

## 1. Generate SSH Key (Client)

```bash
# Generate ED25519 key (recommended)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_vestige

# Set correct permissions:
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_vestige
chmod 644 ~/.ssh/id_ed25519_vestige.pub
```

Set a strong passphrase when prompted.

## 2. Copy Public Key (Server)

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_vestige.pub martin@vestige.local
```

## 3. Configure SSH (Server)

Edit `/etc/ssh/sshd_config` with `configs/sshd_config`

```bash
# Restart SSH service:
sudo systemctl restart ssh
# Verify SSH is running:
sudo systemctl status ssh
```

## 4. Configure SSH Client (Client)

Edit `~/.ssh/config` with `configs/config`

## 5. Connect (Client)

```bash
ssh vestigelocal
```

## 6. Install packages (Client)
