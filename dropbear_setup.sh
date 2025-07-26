#!/bin/bash

# SAID_TÉCH - Dropbear SSH over WebSocket Installer

GREEN='\e[32m'
NC='\e[0m'

clear
echo -e "${GREEN}
=======================================
     SAID_TÉCH - DROPBEAR + SSH WS
=======================================${NC}"
sleep 1

# Step 1: Install Dropbear
echo -e "${GREEN}[+] Installing Dropbear...${NC}"
apt update -y && apt install -y dropbear

# Step 2: Configure Dropbear ports
echo -e "${GREEN}[+] Configuring Dropbear ports (443, 80, 2222)...${NC}"
cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=443
DROPBEAR_EXTRA_ARGS="-p 80 -p 2222"
DROPBEAR_BANNER="/etc/issue.net"
EOF

# Step 3: Create SSH Banner
cat > /etc/issue.net <<EOF

===========================================
 ✅ SAID_TÉCH - DROPBEAR CONNECTED
-------------------------------------------
 🧠 Status   : SSH WS Tunnel Active!
 🌍 Ports    : 443, 80, 2222
 Join: http://t.me/saidtechisp
===========================================

EOF

# Step 4: Restart Dropbear
systemctl enable dropbear
systemctl restart dropbear

# Step 5: Install websocketd (or Node.js WS)
echo -e "${GREEN}[+] Installing WebSocket tunneling server (websocketd)...${NC}"
wget https://github.com/joewalnes/websocketd/releases/download/v0.4.1/websocketd-0.4.1-linux_amd64.zip -O ws.zip
unzip ws.zip
chmod +x websocketd
mv websocketd /usr/local/bin/

# Step 6: Create WS launcher
cat > /usr/local/bin/ws-ssh <<EOF
#!/bin/bash
websocketd --port=8080 --staticdir=/ --loglevel=info /bin/login
EOF

chmod +x /usr/local/bin/ws-ssh

# Step 7: Setup systemd service
cat > /etc/systemd/system/ws-ssh.service <<EOF
[Unit]
Description=WebSocket over Dropbear
After=network.target

[Service]
ExecStart=/usr/local/bin/ws-ssh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Enable and start service
systemctl daemon-reexec
systemctl enable ws-ssh
systemctl start ws-ssh

# Step 9: Add user
echo -e "${GREEN}[+] Creating WebSocket SSH user: wsuser${NC}"
useradd -m -s /bin/bash wsuser
echo "wsuser:saidtech123" | chpasswd

# Output
IP=$(curl -s ifconfig.me)
echo -e "${GREEN}
===========================================
 ✅ DROPBEAR + SSH WS INSTALL COMPLETE!
===========================================
 🧑 User     : wsuser
 🔐 Pass     : saidtech123
 🌍 IP       : $IP
 🔌 Dropbear : 443, 80, 2222
 📡 WS Port  : 8080 (WebSocket over login)
===========================================
 🔗 Telegram: http://t.me/saidtechisp
===========================================
${NC}"
