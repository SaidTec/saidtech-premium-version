#!/bin/bash

# SAID_TÉCH - V2Ray Installer (VMess & VLESS)
# Path: /saidtechisp | TLS Enabled

GREEN='\e[32m'
NC='\e[0m'
UUID=$(cat /proc/sys/kernel/random/uuid)
PORT=443
WS_PATH="/saidtechisp"

clear
echo -e "${GREEN}
=======================================
   SAID_TÉCH V2RAY INSTALLER (TLS+WS)
=======================================${NC}"
sleep 1

read -p "Enter your domain (pointed to this VPS): " DOMAIN

# Install dependencies
apt update -y && apt install -y curl wget unzip socat cron netcat sudo

# Install acme.sh + SSL
curl https://get.acme.sh | sh
source ~/.bashrc
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue --standalone -d $DOMAIN --force
~/.acme.sh/acme.sh --install-cert -d $DOMAIN \
  --key-file /etc/v2ray/private.key \
  --fullchain-file /etc/v2ray/fullchain.crt

# Install V2Ray core
mkdir -p /etc/v2ray
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh) >/dev/null 2>&1 || \
wget -qO- https://raw.githubusercontent.com/XTLS/Xray-install/main/install-release.sh | bash

# Create V2Ray config
cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/v2ray/fullchain.crt",
              "keyFile": "/etc/v2ray/private.key"
            }
          ]
        }
      }
    },
    {
      "port": 8443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "$WS_PATH"
        },
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/v2ray/fullchain.crt",
              "keyFile": "/etc/v2ray/private.key"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# Create systemd service
cat > /etc/systemd/system/v2ray.service <<EOF
[Unit]
Description=V2Ray Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/v2ray -config /etc/v2ray/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable v2ray
systemctl restart v2ray

# Open firewall
ufw allow 443/tcp
ufw allow 8443/tcp

# Generate shareable links
VMESS_LINK="vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"SAIDTECH-VMESS\",\"add\":\"$DOMAIN\",\"port\":\"$PORT\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$DOMAIN\",\"path\":\"$WS_PATH\",\"tls\":\"tls\"}" | base64 -w 0)"
VLESS_LINK="vless://$UUID@$DOMAIN:8443?encryption=none&security=tls&type=ws&host=$DOMAIN&path=$WS_PATH#SAIDTECH-VLESS"

# Output
echo -e "${GREEN}
===========================================
 ✅ V2RAY (VMESS + VLESS) INSTALLED
===========================================
 🌍 Domain        : $DOMAIN
 🔐 UUID          : $UUID
 📁 WS Path       : $WS_PATH
 💠 TLS Cert      : Installed (Let's Encrypt)
===========================================
 🔗 VMESS LINK:
$VMESS_LINK

🔗 VLESS LINK:
$VLESS_LINK
===========================================
 🧾 Path: /saidtechisp
 📥 Apps: Ignition | NapsternetV | V2RayN | Clash
 🌐 Telegram: http://t.me/saidtechisp
===========================================
${NC}"
