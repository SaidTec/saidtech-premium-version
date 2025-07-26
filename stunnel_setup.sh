#!/bin/bash

# SAID_TÉCH - Stunnel over Dropbear Installer

GREEN='\e[32m'
NC='\e[0m'

clear
echo -e "${GREEN}
===============================================
    SAID_TÉCH - SSL (Stunnel) over Dropbear
===============================================${NC}"
sleep 1

# Step 1: Install Stunnel
echo -e "${GREEN}[+] Installing stunnel4...${NC}"
apt update -y && apt install -y stunnel4

# Step 2: Generate SSL Certificate
echo -e "${GREEN}[+] Generating SSL certificate for Stunnel...${NC}"
openssl req -new -x509 -days 3650 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem <<EOF
KE
Makueni
Makueni
SAID_TÉCH
VPN
joshuasaid.tech
admin@joshuasaid.tech
EOF

chmod 600 /etc/stunnel/stunnel.pem

# Step 3: Configure Stunnel
cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/stunnel/stunnel.pem
client = no
[sshssl]
accept = 444
connect = 127.0.0.1:2222
EOF

# Step 4: Enable and Start Stunnel
sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
systemctl enable stunnel4
systemctl restart stunnel4

# Step 5: Add SSL SSH user
echo -e "${GREEN}[+] Creating user for SSL over SSH: ssluser${NC}"
useradd -m -s /bin/bash ssluser
echo "ssluser:saidtech123" | chpasswd

# Output
IP=$(curl -s ifconfig.me)
echo -e "${GREEN}
==============================================
 ✅ STUNNEL SSL + DROPBEAR CONFIG COMPLETE
==============================================
 🧑 User     : ssluser
 🔐 Pass     : saidtech123
 🌍 Server IP: $IP
 🌐 SSL Port : 444 (TCP)
 ↪️ Internally tunneled to Dropbear:2222
==============================================
 🔗 Telegram: http://t.me/saidtechisp
📌 Try in HTTP Injector / TLS VPN Apps
==============================================
${NC}"
