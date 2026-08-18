# Hypixel Panel

Self-hosted Minecraft server management panel with a custom Docker-based runtime daemon (Wings-compatible API, no Wings/Go required). Fork of Pterodactyl, whitelabeled.

## Architecture

```
Browser ── nginx (:80/:443, SSL)
             ├─ /api/servers, /api/system, /upload, /download → :8084 (Node adapter)
             └─ /  (panel UI)                                  → :8083 (Laravel panel)

Node adapter ── Docker (itzg/minecraft-server) on net "mcpanel_net"
                MC data at /var/lib/hypixel/servers/<uuid>
```

| Component | Path | Port | Service |
|---|---|---|---|
| Panel (Laravel + React) | `/opt/.hypixel-panel` | `127.0.0.1:8083` | `hypixel-panel` |
| Runtime adapter (Node) | `/opt/.hypixel-runtime/hypixel-adapter.js` | `127.0.0.1:8084` | `hypixel-runtime` |
| Queue worker | — | — | `hypixel-queue` |
| Database | MariaDB `panel` | `127.0.0.1:3306` | `mariadb` |
| MC containers | `itzg/minecraft-server` | allocation port | `docker` |

## Requirements

- Ubuntu 22.04 / 24.04 (fresh)
- Root access
- Domain with A record → server IP
- Ports 80/443 open

## Install

```bash
git clone https://github.com/<you>/hypixel-panel.git
cd hypixel-panel
sudo bash install.sh
```

The wizard asks for: domain, public IP, admin credentials, ports, and HTTPS. It installs PHP 8.3, Composer, Node 22, Docker, MariaDB, Redis, nginx; deploys panel + adapter; creates DB, admin user, local node (with matching daemon token); sets up systemd services + SSL.

## Post-install

- Panel: `https://<your-domain>`
- Logs: `journalctl -u hypixel-panel -f` / `journalctl -u hypixel-runtime -f`
- DB password + secrets: `/opt/.hypixel-panel/.env`
- Adapter config: `/etc/hypixel-adapter.env`

## Key behaviors (vs stock Pterodactyl)

- **Node card** shows public IP (not FQDN) via `HYPIXEL_PUBLIC_IP`.
- **Server status** derived from Docker healthcheck: `offline → starting → running`.
- **Console** streams live via Docker log follow; per-boot log scoping (stop/restart clears old logs); commands go to container stdin (no RCON).
- **Ports**: Java (TCP) + Bedrock/Geyser (UDP) both follow the allocation port; changing allocation + start/restart auto-rebinds.
- **Custom jars**: upload a jar named per `SERVER_JARFILE` (default `server.jar`) → runs as-is (`TYPE=CUSTOM`, no auto-download/overwrite). Empty → auto-provision from `TYPE`+`VERSION`.
- **Resources**: `memory_limit=0` / `cpu_limit=0` / `disk=0` in panel = unlimited (no cgroup cap).

## Repo layout

```
install.sh          one-command installer
panel/              Laravel panel source
runtime/            Node adapter + package.json
  hypixel-adapter.js
  package.json
  .gitignore
```

## License

Panel based on [Pterodactyl](https://github.com/pterodactyl/panel) (MIT).
