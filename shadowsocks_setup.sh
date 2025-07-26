#!/bin/bash

# SAID_TÉCH - Shadowsocks Installer
# Fast & Encrypted Proxy Tunnel

GREEN='\e[32m'
NC='\e[0m'

clear
echo -e "${GREEN}
===========================================
   SAID_TÉCH - SHADOWSOCKS INSTALLER
===========================================${NC}"
sleep 1

# Step 1: Ask for password & ports
read -p "Enter Shadowsocks password: " SSPASS
read -p "Enter port to use (default 8388): " SSPORT
SSPORT=${SSPORT:-8388}

# Step 2: Install dependencies
echo -e "${GREEN}[+] Installing shadowsocks-libev...${NC}"
apt update -y && apt install -y shadowsocks-libev

# Step 3: Create config
echo -e "${GREEN}[+] Generating Shadowsocks config...${NC}"
cat > /etc/shadowsocks-libev/config.json <<EOF
{
    "server":"0.0.0.0",
    "server_port":$SSPORT,
    "password":"$SSPASS",
    "timeout":300,
    "method":"aes-256-gcm",
    "fast_open": true,
    "nameserver":"1.1.1.1",
    "mode":"tcp_and_udp"
}
EOF

# Step 4: Start and enable service
systemctl enable shadowsocks-libev
systemctl restart shadowsocks-libev

# Step 5: Open port
ufw allow $SSPORT/tcp
ufw allow $SSPORT/udp

# Step 6: Output client JSON
IP=$(curl -s ifconfig.me)
ENCODED_LINK=$(echo -n "aes-256-gcm:$SSPASS@$IP:$SSPORT" | base64 -w 0)
SS_LINK="ss://$ENCODED_LINK#SAID_TÉCH"

echo -e "${GREEN}
===========================================
 ✅ SHADOWSOCKS SETUP COMPLETE
===========================================
 🌍 Server IP : $IP
 🔐 Password  : $SSPASS
 🔌 Port      : $SSPORT
 🔒 Cipher    : aes-256-gcm
===========================================
 🧾 JSON CONFIG:
{
  \"server\": \"$IP\",
  \"server_port\": $SSPORT,
  \"password\": \"$SSPASS\",
  \"method\": \"aes-256-gcm\",
  \"timeout\": 300,
  \"mode\": \"tcp_and_udp\"
}

🔗 Share Link:
$SS_LINK
===========================================
 📥 Use on: Shadowsocks Android/iOS, Clash, Ignition, NapsternetV
 🔗 Telegram: http://t.me/saidtechisp
===========================================
${NC}"
