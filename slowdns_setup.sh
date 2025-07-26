#!/bin/bash

# SAID_TÉCH - SlowDNS Server Installer (UDP 53 Tunnel)

GREEN='\e[32m'
NC='\e[0m'

clear
echo -e "${GREEN}
===========================================
   SAID_TÉCH - SLOWDNS SERVER INSTALLER
===========================================${NC}"
sleep 1

# Step 1: Install Dependencies
echo -e "${GREEN}[+] Installing dependencies...${NC}"
apt update -y && apt install -y curl wget git dnsutils screen

# Step 2: Create SlowDNS Folder
mkdir -p /etc/slowdns
cd /etc/slowdns

# Step 3: Download SlowDNS binaries
echo -e "${GREEN}[+] Downloading SlowDNS server binaries...${NC}"
wget -O sldns-server https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/SLDNS/sldns-server
wget -O sldns-client https://raw.githubusercontent.com/fisabiliyusri/Mantap/main/SLDNS/sldns-client

chmod +x sldns-client sldns-server

# Step 4: Generate Keys
echo -e "${GREEN}[+] Generating key pair...${NC}"
./sldns-server -gen-key -privkey server.key -pubkey server.pub

# Step 5: Setup domain input
read -p "Enter your SLOWDNS NS domain (e.g. ns1.yourdomain.com): " NSDOMAIN

# Step 6: Create run script
cat > /etc/slowdns/run <<EOF
#!/bin/bash
cd /etc/slowdns
screen -dmS slowdns ./sldns-server -udp :53 -privkey server.key -domain $NSDOMAIN -dns 1.1.1.1
EOF

chmod +x /etc/slowdns/run

# Step 7: Setup systemd service
cat > /etc/systemd/system/slowdns.service <<EOF
[Unit]
Description=SlowDNS UDP 53 Tunnel
After=network.target

[Service]
ExecStart=/etc/slowdns/run
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable slowdns
systemctl start slowdns

# Final Output
IP=$(curl -s ifconfig.me)
PUBKEY=$(cat /etc/slowdns/server.pub)

echo -e "${GREEN}
===============================================
 ✅ SLOWDNS SERVER INSTALLED SUCCESSFULLY
===============================================
 🌍 Server IP : $IP
 🛰️ NS Domain : $NSDOMAIN
 🔐 Public Key: 
$PUBKEY

 ✅ Protocol  : UDP (DNS)
 📡 Port      : 53
 💬 Tunnel    : sldns-client ➝ this server
===============================================
 🛠 Use client config like HTTP Custom, etc
 🔗 Telegram : http://t.me/saidtechisp
===============================================
${NC}"
