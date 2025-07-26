#!/bin/bash

# SAID_TÉCH PREMIUM INTERNET - SSH INSTALLER
# By Joshua Said

# Colors
GREEN='\e[32m'
RED='\e[31m'
NC='\e[0m'

clear
echo -e "${GREEN}
===========================================
    SAID_TÉCH SSH SETUP INSTALLER
===========================================${NC}"
sleep 1

# Step 1: Update & Install Dependencies
echo -e "${GREEN}[+] Updating system and installing required packages...${NC}"
apt update -y && apt upgrade -y
apt install -y openssh-server curl wget sudo net-tools ufw

# Step 2: Set Timezone
echo -e "${GREEN}[+] Setting timezone to Africa/Nairobi...${NC}"
timedatectl set-timezone Africa/Nairobi

# Step 3: Set Hostname (optional)
read -p "Enter hostname (or leave blank to skip): " hostname
if [[ ! -z "$hostname" ]]; then
    echo "$hostname" > /etc/hostname
    hostnamectl set-hostname "$hostname"
    echo -e "${GREEN}[+] Hostname set to $hostname${NC}"
fi

# Step 4: Create SSH Banner
echo -e "${GREEN}[+] Creating SSH login banner...${NC}"
cat > /etc/issue.net <<EOF

===========================================
 ✅ SAID_TÉCH PREMIUM INTERNET - CONNECTED 
-------------------------------------------
 🔐 Protocol : SSH
 🗓️ Date     : $(date)
 🧠 Status   : Login Successful!
===========================================
 Browse securely with encrypted tunneling. 🔒
 Join: http://t.me/saidtechisp
===========================================

EOF

sed -i 's|#Banner none|Banner /etc/issue.net|' /etc/ssh/sshd_config

# Step 5: Configure SSH Ports
echo -e "${GREEN}[+] Configuring SSH ports (22, 443, 80, 8080, 2222)...${NC}"
# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Clear existing Port lines
sed -i '/^Port/d' /etc/ssh/sshd_config

# Add custom ports
cat >> /etc/ssh/sshd_config <<EOF
Port 22
Port 443
Port 80
Port 8080
Port 2222
PermitRootLogin yes
PasswordAuthentication yes
PermitTunnel yes
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 60
UseDNS no
MaxAuthTries 3
EOF

# Step 6: Firewall Rules
echo -e "${GREEN}[+] Opening SSH ports in firewall...${NC}"
ufw allow 22/tcp
ufw allow 443/tcp
ufw allow 80/tcp
ufw allow 8080/tcp
ufw allow 2222/tcp
ufw reload

# Step 7: Add SSH User
echo -e "${GREEN}[+] Creating SSH user: vpnuser${NC}"
useradd -m -s /bin/bash vpnuser
echo "vpnuser:saidtech123" | chpasswd
usermod -aG sudo vpnuser

# Step 8: Optional - Enable BBR TCP Optimization
echo -e "${GREEN}[+] Enabling BBR TCP optimization (for speed boost)...${NC}"
modprobe tcp_bbr
echo "tcp_bbr" | tee -a /etc/modules-load.d/modules.conf
echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
sysctl -p

# Step 9: Restart Services
echo -e "${GREEN}[+] Restarting SSH service...${NC}"
systemctl restart ssh

# Final Output
IP=$(curl -s ifconfig.me)
echo -e "${GREEN}
===========================================
 ✅ SSH INSTALLATION COMPLETE!
===========================================
 🔐 Username: vpnuser
 🔑 Password: saidtech123
 🌍 IP       : $IP
 🔌 Ports    : 22, 443, 80, 8080, 2222
===========================================
 📡 Service by SAID_TÉCH PREMIUM INTERNET
 🔗 Telegram: http://t.me/saidtechisp
===========================================
${NC}"
