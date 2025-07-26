#!/bin/bash

# SAID_TÉCH - Trojan Installer with TLS
# Website: joshuasaid.tech | Telegram: @saidtechisp

GREEN='\e[32m'
NC='\e[0m'

clear
echo -e "${GREEN}
=======================================
    SAID_TÉCH - TROJAN INSTALLER
=======================================${NC}"
sleep 1

# Step 1: Ask for domain name (must point to server IP)
read -p "Enter domain pointed to this server (e.g. trojan.joshuasaid.tech): " DOMAIN
read -p "Enter password for Trojan user (e.g. saidtech123): " TROJAN_PASS

# Step 2: Install dependencies
echo -e "${GREEN}[+] Installing required packages...${NC}"
apt update -y && apt install -y socat curl cron netcat unzip wget sudo

# Step 3: Install acme.sh and get SSL cert
echo -e "${GREEN}[+] Installing acme.sh and issuing SSL cert...${NC}"
curl https://get.acme.sh | sh
source ~/.bashrc
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue --standalone -d $DOMAIN --force
~/.acme.sh/acme.sh --install-cert -d $DOMAIN \
    --key-file /etc/trojan/private.key \
    --fullchain-file /etc/trojan/fullchain.crt

# Step 4: Install Trojan
echo -e "${GREEN}[+] Installing Trojan-Go...${NC}"
mkdir -p /etc/trojan
cd /etc/trojan
wget https://github.com/p4gefau1t/trojan-go/releases/download/v0.10.6/trojan-go-linux-amd64.zip
unzip trojan-go-linux-amd64.zip
mv trojan-go /usr/local/bin/
chmod +x /usr/local/bin/trojan-go

# Step 5: Create Trojan config
cat > /etc/trojan/config.json <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "password": ["$TROJAN_PASS"],
  "ssl": {
    "cert": "/etc/trojan/fullchain.crt",
    "key": "/etc/trojan/private.key",
    "sni": "$DOMAIN"
  }
}
EOF

# Step 6: Create systemd service
cat > /etc/systemd/system/trojan.service <<EOF
[Unit]
Description=Trojan-Go Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Step 7: Start Trojan
systemctl daemon-reload
systemctl enable trojan
systemctl start trojan

# Step 8: Firewall
ufw allow 443/tcp

# Step 9: Output Client Config
echo -e "${GREEN}
===========================================
 ✅ TROJAN SERVER READY
===========================================
 🌍 Domain     : $DOMAIN
 🔐 Password   : $TROJAN_PASS
 🔌 Port       : 443 (TLS)
 📜 Cert Path  : /etc/trojan/fullchain.crt
===========================================
 📥 Client Link (JSON config):
===========================================
{
  \"run_type\": \"client\",
  \"local_addr\": \"127.0.0.1\",
  \"local_port\": 1080,
  \"remote_addr\": \"$DOMAIN\",
  \"remote_port\": 443,
  \"password\": [\"$TROJAN_PASS\"],
  \"ssl\": {
    \"verify\": true,
    \"sni\": \"$DOMAIN\"
  }
}
===========================================
 🔗 Telegram: http://t.me/saidtechisp
===========================================
${NC}"
