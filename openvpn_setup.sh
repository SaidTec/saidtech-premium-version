#!/bin/bash

# SAID_TÉCH - OpenVPN Setup Script
# Supports TCP & UDP (multi-port)

GREEN='\e[32m'
NC='\e[0m'
OVPN_DIR="/etc/openvpn"

clear
echo -e "${GREEN}
===========================================
      SAID_TÉCH - OPENVPN INSTALLER
===========================================${NC}"
sleep 1

# Step 1: Install OpenVPN & Easy-RSA
echo -e "${GREEN}[+] Installing OpenVPN and Easy-RSA...${NC}"
apt update -y && apt install -y openvpn easy-rsa ufw curl unzip

make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Step 2: Generate Keys
echo -e "${GREEN}[+] Setting up CA and keys...${NC}"
./easyrsa init-pki
echo | ./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey --secret ta.key
cp -r pki /etc/openvpn
cp ta.key /etc/openvpn

# Step 3: Server Configs (TCP & UDP)
echo -e "${GREEN}[+] Creating OpenVPN server configs...${NC}"

for proto in tcp udp; do
    for port in 80 443 1194 25000 53; do
        conf="$OVPN_DIR/server-$proto-$port.conf"
        cat > "$conf" <<EOF
port $port
proto $proto
dev tun
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/issued/server.crt
key /etc/openvpn/pki/private/server.key
dh /etc/openvpn/pki/dh.pem
tls-auth /etc/openvpn/ta.key 0
topology subnet
server 10.8.$((RANDOM % 255)).0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
status /var/log/openvpn-$proto-$port.log
verb 3
explicit-exit-notify 1
EOF
    done
done

# Step 4: Enable IP Forwarding & NAT
echo -e "${GREEN}[+] Enabling IP forwarding...${NC}"
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

# Step 5: Setup Firewall NAT
echo -e "${GREEN}[+] Setting firewall NAT rules...${NC}"
IP=$(curl -s ifconfig.me)
iptables -t nat -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
iptables-save > /etc/iptables.rules

# Step 6: Enable all OpenVPN services
echo -e "${GREEN}[+] Enabling and starting OpenVPN services...${NC}"
for f in $OVPN_DIR/*.conf; do
    name=$(basename "$f" .conf)
    systemctl enable openvpn@"$name"
    systemctl start openvpn@"$name"
done

# Step 7: Generate .ovpn client configs
mkdir -p /root/ovpn-clients
CA_CERT=$(</etc/openvpn/pki/ca.crt)
TA_KEY=$(</etc/openvpn/ta.key)
CLIENT_NAME="saidtech"

for proto in tcp udp; do
    for port in 80 443 1194 25000 53; do
        CLIENT_FILE="/root/ovpn-clients/$CLIENT_NAME-$proto-$port.ovpn"
        cat > "$CLIENT_FILE" <<EOF
client
dev tun
proto $proto
remote $IP $port
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-CBC
auth SHA256
verb 3
<ca>
$CA_CERT
</ca>
<tls-auth>
$TA_KEY
</tls-auth>
key-direction 1
EOF
    done
done

# Step 8: Add user for OVPN
useradd -m -s /bin/bash ovpnuser
echo "ovpnuser:saidtech123" | chpasswd

# Final Output
echo -e "${GREEN}
===========================================
 ✅ OPENVPN INSTALLED SUCCESSFULLY
===========================================
 🧑 User     : ovpnuser
 🔐 Pass     : saidtech123
 🌍 Server IP: $IP
 🔌 Ports    : 80, 443, 1194, 25000, 53
 📄 OVPN Configs: /root/ovpn-clients/*.ovpn
 📦 Protocols  : TCP + UDP
===========================================
 🔗 Telegram : http://t.me/saidtechisp
===========================================
${NC}"
