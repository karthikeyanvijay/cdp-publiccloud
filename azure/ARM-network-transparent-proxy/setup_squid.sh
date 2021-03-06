#!/bin/bash

### Enable IP forwarding
cat > /etc/sysctl.d/ip-forward.conf <<EOF
# Enabled at NIC level
net.ipv4.ip_forward=1
EOF
sysctl --system
grep . /proc/sys/net/ipv4/ip_forward /dev/null

### Setup SSL
# Create a SSL certificate for the SslBump Squid module
ssl_dir="/etc/squid/ssl"
mkdir -p $ssl_dir
openssl genrsa -out $ssl_dir/squid.key 4096
openssl req -new -key $ssl_dir/squid.key -out $ssl_dir/squid.csr -subj "/C=XX/ST=XX/L=squid/O=squid/CN=squid"
openssl x509 -req -days 3650 -in $ssl_dir/squid.csr -signkey $ssl_dir/squid.key -out $ssl_dir/squid.crt
cat $ssl_dir/squid.key $ssl_dir/squid.crt >> $ssl_dir/squid.pem

### Install & Configure Squid
yum install squid -y
cp -p /etc/squid/squid.conf /etc/squid/squid.conf.original
wget https://raw.githubusercontent.com/karthikeyanvijay/cdp-publiccloud/main/azure/ARM-network-transparent-proxy/squid.conf -O /etc/squid/squid.conf
wget https://raw.githubusercontent.com/karthikeyanvijay/cdp-publiccloud/main/azure/ARM-network-transparent-proxy/http_whitelist.txt -O /etc/squid/http_whitelist.txt
wget https://raw.githubusercontent.com/karthikeyanvijay/cdp-publiccloud/main/azure/ARM-network-transparent-proxy/https_whitelist.txt -O /etc/squid/https_whitelist.txt
systemctl restart squid && systemctl enable squid

### Setup IP Tables for transparent proxy 
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3129
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 3130
iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -p udp --dport 123 -j MASQUERADE

### CCM Traffic
iptables -t nat -A POSTROUTING -s 10.0.0.0/8 -p tcp --dport 6000:6049 -j MASQUERADE
