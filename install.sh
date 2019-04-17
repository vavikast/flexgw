#!/bin/bash
####----sysctl----####
sysctl -a | egrep "ipv4.*(accept|send)_redirects" | awk -F "=" '{print $1 "=0"}'
 > a.txt

cat a.txt >>/etc/sysctl.conf

cat /etc/sysctl.conf | sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1
/' /etc/sysctl.conf
sysctl -p
####----rpm----####
yum -y install strongswan openvpn zip curl wget
wget https://github.com/vavikast/flexgw/raw/master/flexgw-2.5.0-1.el6.x86_64.rpm
rpm -ivh flexgw-2.5.0-1.el6.x86_64.rpm

cp -f /usr/local/flexgw/rc/strongswan.conf /etc/strongswan/strongswan.conf
cp -f /usr/local/flexgw/rc/openvpn.conf /etc/openvpn/server.conf

cat >> /etc/openvpn/server.conf << EOF
push "redirect-gateway def1 bypass-dhcp"
EOF


cat /etc/strongswan/strongswan.d/charon/dhcp.conf | sed  -i 's/load = yes/#load = yes/' /etc/strongswan/strongswan.d/charon/dhcp.conf >/etc/strongswan/ipsec.secrets



echo "/etc/init.d/openvpn  start" >> /etc/rc.local
echo "sleep 5" >> /etc/rc.local
echo "/etc/init.d/strongswan  start" >> /etc/rc.local
sed -i "s:data\[7:data\[8:g" /usr/local/flexgw/website/vpn/dial/services.py

ln -s /etc/init.d/initflexgw /etc/rc3.d/S98initflexgw
/etc/init.d/initflexgw
