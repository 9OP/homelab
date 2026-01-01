# Services Setup

## Folder Structure

```
/opt/homelab/
├── docker-compose.yml
├── Caddyfile
├── site/
└── certs/
```

## Setup

```sh
# On server
sudo mkdir -p /opt/homelab
sudo chown -R $USER:$USER /opt/homelab
cd /opt/homelab

# On homelab repo
scp -O -r ./services/* martin@vestigelocal:/opt/homelab
```

## Start Services

```sh
# On server
cd /opt/homelab
docker compose up -d
docker compose logs -f
```
