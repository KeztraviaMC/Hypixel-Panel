#!/bin/bash
#
# Hypixel Panel — one-command installer
# Installs: Laravel panel (:8083) + Node daemon adapter (:8084) + nginx + MariaDB + Docker
# Usage:  sudo bash install.sh
#
set -euo pipefail

# ---------- colors ----------
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; NC='\033[0m'
say(){ echo -e "${G}[+]${NC} $*"; }
warn(){ echo -e "${Y}[!]${NC} $*"; }
err(){ echo -e "${R}[x]${NC} $*" >&2; }
ask(){ local p="$1" d="${2:-}" v; if [ -n "$d" ]; then read -rp "$(echo -e "${B}?${NC} $p [${d}]: ")" v; echo "${v:-$d}"; else read -rp "$(echo -e "${B}?${NC} $p: ")" v; echo "$v"; fi; }
asksecret(){ local p="$1" v; read -rsp "$(echo -e "${B}?${NC} $p: ")" v; echo >&2; echo "$v"; }

[ "$(id -u)" -eq 0 ] || { err "Run as root (sudo bash install.sh)"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PANEL_SRC="$REPO_DIR/panel"
RUNTIME_SRC="$REPO_DIR/runtime"
[ -d "$PANEL_SRC" ] || { err "panel/ not found next to install.sh"; exit 1; }
[ -d "$RUNTIME_SRC" ] || { err "runtime/ not found next to install.sh"; exit 1; }

clear
echo -e "${G}==============================================${NC}"
echo -e "${G}   Hypixel Panel Installer${NC}"
echo -e "${G}==============================================${NC}"
echo

# ---------- 1. gather config ----------
FQDN=$(ask "Panel domain (e.g. panel.example.com)")
[ -n "$FQDN" ] || { err "domain required"; exit 1; }
PUBLIC_IP=$(ask "Server public IP (players connect here)" "$(curl -s4 ifconfig.me 2>/dev/null || echo '')")
ADMIN_EMAIL=$(ask "Admin email")
ADMIN_USER=$(ask "Admin username" "admin")
ADMIN_FIRST=$(ask "Admin first name" "Server")
ADMIN_LAST=$(ask "Admin last name" "Admin")
ADMIN_PASS=$(asksecret "Admin password")
[ -n "$ADMIN_PASS" ] || { err "admin password required"; exit 1; }
PANEL_PORT=$(ask "Panel internal port" "8083")
ADAPTER_PORT=$(ask "Adapter internal port" "8084")
USE_SSL=$(ask "Enable HTTPS with Let's Encrypt? (y/n)" "y")
INSTALL_USER=$(ask "System user to run services" "${SUDO_USER:-hypixel}")
DATA_DIR=$(ask "Minecraft data dir" "/var/lib/hypixel/servers")

DB_NAME="panel"; DB_USER="hypixel"
DB_PASS=$(openssl rand -hex 24)
WINGS_TOKEN=$(openssl rand -hex 32)      # 64 chars — daemon key (must match node in panel)
DAEMON_TOKEN_ID=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c16)

echo
echo -e "${Y}--- Summary ---${NC}"
echo "  Domain        : $FQDN"
echo "  Public IP     : $PUBLIC_IP"
echo "  Admin         : $ADMIN_USER <$ADMIN_EMAIL>"
echo "  Panel port    : $PANEL_PORT   Adapter port: $ADAPTER_PORT"
echo "  HTTPS         : $USE_SSL"
echo "  Run as user   : $INSTALL_USER"
echo "  Data dir      : $DATA_DIR"
echo "  DB            : $DB_NAME (user $DB_USER, random pass)"
echo
[ "$(ask "Proceed? (y/n)" "y")" = "y" ] || { warn "aborted"; exit 0; }

# ---------- 2. system deps ----------
say "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq software-properties-common curl ca-certificates gnupg lsb-release nginx mariadb-server redis-server unzip git openssl >/dev/null

# PHP 8.3
if ! command -v php >/dev/null || ! php -v 2>/dev/null | grep -q "8.3"; then
  say "Installing PHP 8.3..."
  add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1 || true
  apt-get update -qq
  apt-get install -y -qq php8.3 php8.3-{cli,fpm,mysql,mbstring,bcmath,xml,curl,zip,gd,intl} >/dev/null
fi

# Composer
command -v composer >/dev/null || { say "Installing Composer..."; curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >/dev/null; }

# Node 22
if ! command -v node >/dev/null || [ "$(node -v | grep -oP '^v\K[0-9]+')" -lt 18 ]; then
  say "Installing Node.js 22..."
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null 2>&1
  apt-get install -y -qq nodejs >/dev/null
fi

# Docker
if ! command -v docker >/dev/null; then
  say "Installing Docker..."
  curl -fsSL https://get.docker.com | sh >/dev/null 2>&1
fi
systemctl enable --now docker >/dev/null 2>&1

# ensure user exists
id "$INSTALL_USER" >/dev/null 2>&1 || useradd -m -s /bin/bash "$INSTALL_USER"
usermod -aG docker "$INSTALL_USER" 2>/dev/null || true

# ---------- 3. database ----------
say "Configuring database..."
systemctl enable --now mariadb >/dev/null 2>&1
mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

# ---------- 4. deploy panel ----------
say "Deploying panel to /opt/.hypixel-panel..."
mkdir -p /opt/.hypixel-panel
cp -a "$PANEL_SRC/." /opt/.hypixel-panel/
cd /opt/.hypixel-panel
cp .env.example .env
sed -i "s#^APP_URL=.*#APP_URL=$([ "$USE_SSL" = "y" ] && echo https || echo http)://${FQDN}#" .env
sed -i "s#^DB_DATABASE=.*#DB_DATABASE=${DB_NAME}#" .env
sed -i "s#^DB_USERNAME=.*#DB_USERNAME=${DB_USER}#" .env
sed -i "s#^DB_PASSWORD=.*#DB_PASSWORD=${DB_PASS}#" .env
sed -i "s#^HYPIXEL_PUBLIC_IP=.*#HYPIXEL_PUBLIC_IP=${PUBLIC_IP}#" .env
sed -i "s#^HYPIXEL_DAEMON_INTERNAL_URL=.*#HYPIXEL_DAEMON_INTERNAL_URL=http://127.0.0.1:${ADAPTER_PORT}#" .env

say "Installing PHP deps (composer)..."
composer install --no-dev --optimize-autoloader --no-interaction -q
php artisan key:generate --force -q
php artisan p:environment:setup --author="$ADMIN_EMAIL" --url="$([ "$USE_SSL" = "y" ] && echo https || echo http)://${FQDN}" --timezone=UTC --cache=file --session=file --queue=redis --redis-host=127.0.0.1 --redis-pass= --redis-port=6379 --settings-ui=true 2>/dev/null || true
say "Running migrations + seeders..."
php artisan migrate --seed --force -q

say "Creating admin user..."
php artisan p:user:make --email="$ADMIN_EMAIL" --username="$ADMIN_USER" --name-first="$ADMIN_FIRST" --name-last="$ADMIN_LAST" --password="$ADMIN_PASS" --admin=1 --no-interaction 2>/dev/null || warn "user may already exist"

# location + node (single local node)
say "Creating local location + node..."
php artisan p:location:make --short=local --long="Local" 2>/dev/null || true
php artisan p:node:make \
  --name="Local Node" --description="Auto-connected local node" \
  --locationId=1 --fqdn="$FQDN" --public=1 \
  --scheme="$([ "$USE_SSL" = "y" ] && echo https || echo http)" \
  --proxy=0 --maxMemory=1048576 --overallocateMemory=-1 \
  --maxDisk=1048576 --overallocateDisk=-1 \
  --daemonListeningPort=443 --daemonSFTPPort=2022 \
  --daemonBase="$DATA_DIR" 2>/dev/null || warn "node may already exist"

# force node daemon key = our WINGS_TOKEN so adapter + panel agree
php artisan tinker --execute="
\$n=\Pterodactyl\Models\Node::first();
if(\$n){ \$n->daemon_token_id='${DAEMON_TOKEN_ID}'; \$n->daemon_token=Illuminate\Support\Facades\Crypt::encrypt('${WINGS_TOKEN}'); \$n->save(); echo 'node token synced'; }
" 2>/dev/null || warn "could not sync node token"

# ---------- 5. deploy runtime adapter ----------
say "Deploying adapter to /opt/.hypixel-runtime..."
mkdir -p /opt/.hypixel-runtime "$DATA_DIR"
cp -a "$RUNTIME_SRC/." /opt/.hypixel-runtime/
ln -sfn "$DATA_DIR" /opt/.hypixel-runtime/servers
cd /opt/.hypixel-runtime
say "Installing adapter deps (npm)..."
npm install --omit=dev --silent 2>/dev/null || npm install --production --silent

# adapter env
cat > /etc/hypixel-adapter.env <<ENV
WINGS_TOKEN=${WINGS_TOKEN}
PANEL_URL=http://127.0.0.1:${PANEL_PORT}
DAEMON_TOKEN_ID=${DAEMON_TOKEN_ID}
HYPIXEL_DATA_DIR=${DATA_DIR}
HYPIXEL_ADAPTER_PORT=${ADAPTER_PORT}
ENV
chmod 600 /etc/hypixel-adapter.env

# adapter needs a servers DB table; init empty sqlite
node -e "const DB=require('better-sqlite3');const db=new DB('${DATA_DIR}/panel.db');db.prepare('CREATE TABLE IF NOT EXISTS servers (id TEXT PRIMARY KEY,name TEXT,type TEXT,version TEXT,docker_image TEXT,java_version TEXT,ram INTEGER,cpu INTEGER,port INTEGER,status TEXT,container_id TEXT,owner_id TEXT,node_id TEXT,allocation_id TEXT,disk_gb INTEGER,created_at INTEGER,updated_at INTEGER)').run();console.log('sqlite ready');" 2>/dev/null || warn "sqlite init skipped"

# ---------- 6. permissions ----------
chown -R "$INSTALL_USER":"$INSTALL_USER" /opt/.hypixel-panel /opt/.hypixel-runtime "$DATA_DIR"
chmod -R 755 /opt/.hypixel-panel/storage /opt/.hypixel-panel/bootstrap/cache

# ---------- 7. systemd services ----------
say "Creating systemd services..."
cat > /etc/systemd/system/hypixel-panel.service <<UNIT
[Unit]
Description=Hypixel Panel
After=network.target redis-server.service mariadb.service
[Service]
Type=simple
User=${INSTALL_USER}
WorkingDirectory=/opt/.hypixel-panel
Environment=APP_ENV=production
ExecStart=/usr/bin/php artisan serve --host=127.0.0.1 --port=${PANEL_PORT}
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
UNIT

cat > /etc/systemd/system/hypixel-runtime.service <<UNIT
[Unit]
Description=Hypixel Local Runtime
After=network.target docker.service
Requires=docker.service
[Service]
Type=simple
User=root
WorkingDirectory=/opt/.hypixel-runtime
EnvironmentFile=/etc/hypixel-adapter.env
ExecStart=/usr/bin/node /opt/.hypixel-runtime/hypixel-adapter.js
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
UNIT

# queue worker (schedule)
cat > /etc/systemd/system/hypixel-queue.service <<UNIT
[Unit]
Description=Hypixel Panel Queue Worker
After=redis-server.service
[Service]
User=${INSTALL_USER}
WorkingDirectory=/opt/.hypixel-panel
ExecStart=/usr/bin/php artisan queue:work --sleep=3 --tries=3
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now hypixel-panel hypixel-runtime hypixel-queue >/dev/null 2>&1

# cron for scheduler
( crontab -u "$INSTALL_USER" -l 2>/dev/null; echo "* * * * * php /opt/.hypixel-panel/artisan schedule:run >> /dev/null 2>&1" ) | crontab -u "$INSTALL_USER" - 2>/dev/null || true

# ---------- 8. nginx ----------
say "Configuring nginx..."
# login rate-limit zone (http-level, idempotent)
if ! grep -q "zone=hypixel_login" /etc/nginx/nginx.conf; then
  sed -i "s#http {#http {\n\tlimit_req_zone \$binary_remote_addr zone=hypixel_login:10m rate=5r/m;#" /etc/nginx/nginx.conf
fi
cat > /etc/nginx/sites-available/hypixel.conf <<NGINX
map \$http_upgrade \$connection_upgrade { default upgrade; '' close; }
server {
    listen 80;
    server_name ${FQDN};
    client_max_body_size 8g;

    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;

    location = /auth/login {
        limit_req zone=hypixel_login burst=5 nodelay;
        limit_req_status 429;
        proxy_pass http://127.0.0.1:${PANEL_PORT};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    location = /api/system { proxy_pass http://127.0.0.1:${ADAPTER_PORT}; proxy_http_version 1.1; proxy_set_header Host \$host; proxy_set_header Authorization \$http_authorization; }
    location ^~ /api/servers { proxy_pass http://127.0.0.1:${ADAPTER_PORT}; proxy_http_version 1.1; proxy_set_header Host \$host; proxy_set_header Authorization \$http_authorization; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_read_timeout 86400; proxy_send_timeout 86400; }
    location = /upload/file { proxy_pass http://127.0.0.1:${ADAPTER_PORT}; proxy_http_version 1.1; proxy_set_header Host \$host; proxy_set_header Authorization \$http_authorization; proxy_request_buffering off; client_max_body_size 8g; proxy_read_timeout 86400; }
    location = /download/file { proxy_pass http://127.0.0.1:${ADAPTER_PORT}; proxy_http_version 1.1; proxy_set_header Host \$host; proxy_read_timeout 86400; }
    location / { proxy_pass http://127.0.0.1:${PANEL_PORT}; proxy_http_version 1.1; proxy_set_header Host \$host; proxy_set_header X-Real-IP \$remote_addr; proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto \$scheme; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_read_timeout 86400; }
}
NGINX
ln -sfn /etc/nginx/sites-available/hypixel.conf /etc/nginx/sites-enabled/hypixel.conf
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

# ---------- 9. SSL ----------
if [ "$USE_SSL" = "y" ]; then
  say "Requesting Let's Encrypt certificate..."
  apt-get install -y -qq certbot python3-certbot-nginx >/dev/null
  certbot --nginx -d "$FQDN" --non-interactive --agree-tos -m "$ADMIN_EMAIL" --redirect 2>/dev/null \
    && say "SSL enabled" || warn "certbot failed — check DNS points to this server, run 'certbot --nginx -d $FQDN' manually"
fi

# ---------- done ----------
echo
echo -e "${G}==============================================${NC}"
echo -e "${G}   Install complete${NC}"
echo -e "${G}==============================================${NC}"
echo -e "  Panel : ${B}$([ "$USE_SSL" = "y" ] && echo https || echo http)://${FQDN}${NC}"
echo -e "  Login : ${ADMIN_USER}  (email ${ADMIN_EMAIL})"
echo
echo -e "  Services: hypixel-panel, hypixel-runtime, hypixel-queue"
echo -e "  Logs    : journalctl -u hypixel-panel -f"
echo -e "  DB pass : saved in /opt/.hypixel-panel/.env"
echo
warn "Point DNS A record ${FQDN} -> ${PUBLIC_IP} before using."
