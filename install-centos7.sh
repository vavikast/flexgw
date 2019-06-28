
#!/bin/bash
###--down-loadrepo---###
curl -L https://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm -o epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum makecache fast

####----sysctl----####

sysctl -a | egrep "ipv4.*(accept|send)_redirects" | awk -F "=" '{print $1 "=0"}' > a.txt

cat a.txt >>/etc/sysctl.conf

cat /etc/sysctl.conf | sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
####----rpm----####
yum -y install strongswan openvpn zip curl wget
wget https://github.com/vavikast/flexgw/raw/master/flexgw-2.5.0-1.el6.x86_64.rpm
rpm -ivh flexgw-2.5.0-1.el6.x86_64.rpm

curl -L https://raw.githubusercontent.com/vavikast/flexgw/master/strongswan.conf -o strongswan.conf
\cp -f /usr/local/flexgw/rc/openvpn.conf /etc/openvpn/server.conf && echo 'push "redirect-gateway def1 bypass-dhcp"' >>  /etc/openvpn/server.conf


cat /etc/strongswan/strongswan.d/charon/dhcp.conf | sed  -i 's/load = yes/#load = yes/' /etc/strongswan/strongswan.d/charon/dhcp.conf 
>/etc/strongswan/ipsec.secrets
sed -i "s:data\[7:data\[8:g" /usr/local/flexgw/website/vpn/dial/services.py

curl -L  https://raw.githubusercontent.com/vavikast/flexgw/master/openvpn.service -o /usr/lib/systemd/system/openvpn.service


systemctl daemon-reload
systemctl enable openvpn
systemctl enable strongswan 
systemctl start openvpn
systemctl start strongswan 

ln -s /etc/init.d/initflexgw /etc/rc3.d/S98initflexgw
/etc/init.d/initflexgw
