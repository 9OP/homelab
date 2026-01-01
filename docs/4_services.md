# Services Setup

## Folder Structure

```
/opt/homelab/
├── docker-compose.yml
├── Caddyfile
├── .env
└── site/
    └── index.html
```

## Setup on Pi

```sh
# Create directory
sudo mkdir -p /opt/homelab
sudo chown -R $USER:$USER /opt/homelab
cd /opt/homelab

scp -O -r ./services/* martin@vestigelocal:/opt/homelab
```

## Start Services

```sh
cd /opt/homelab
docker compose up -d
docker compose logs -f
```
