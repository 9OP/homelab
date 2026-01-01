# Packages

## 1. Install Basic Packages

```sh
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install -y \
    fzf \
    ripgrep \
    fd-find \
    bat \
    htop \
    ncdu \
    tree \
    jq \
    make \
    git \
    ufw \
    curl \
    build-essential \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg
```

**What each tool does:**

- `fzf` - Fuzzy finder for files, history, commands
- `ripgrep` (rg) - Much faster grep
- `fd-find` - Better find command
- `bat` - Better cat with syntax highlighting
- `htop` - Better process viewer
- `ncdu` - Disk usage analyzer
- `tree` - Directory tree viewer
- `jq` - JSON processor

**Usage:**

- `Ctrl+R` - Fuzzy search through command history
- `Ctrl+T` - Fuzzy find files
- `Alt+C` - Fuzzy cd into directories

## 2. Install Docker

### Setup Docker Repository

```sh
# Create keyrings directory
sudo install -m 0755 -d /etc/apt/keyrings

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Install Docker Packages

```sh
sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-compose-plugin
```

### Configure Docker

```sh
# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker

# Add your user to docker group (replace 'martin' with your username)
sudo usermod -aG docker $USER

# Apply group changes (logout/login or run)
newgrp docker
```

### Verify Installation

```sh
# Check Docker version
docker --version

# Test Docker
docker run hello-world

# Check Docker Compose
docker compose version
```
