#!/bin/sh

# from https://www.golinuxcloud.com/network-bound-disk-encryption-tang-clevis/
# http://people.redhat.com/tmichett/Clevis_Tang/Encryption_and_Security.pdf
# https://github.com/latchset/tang

yum -y install tang
systemctl enable tangd.socket --now
firewall-cmd --add-port=7070/tcp
firewall-cmd --runtime-to-permanent
semanage port -a -t tangd_port_t -p tcp 7070
mkdir -p /etc/systemd/system/tangd.socket.d
cat > /etc/systemd/system/tangd.socket.d/override.conf <<EOF
[Socket]
ListenStream=
ListenStream=7070
EOF
systemctl daemon-reload

systemctl show tangd.socket -p Listen
# find keys here:
ls -l /var/db/tang/

exit
# client config:
yum -y install clevis clevis-luks clevis-dracut
blkid -t TYPE=crypto_LUKS -o device
# this is /dev/sdb1 used in the next command:
cryptsetup luksDump /dev/sdb1
clevis luks bind -d /dev/sdb1 tang '{"url":"192.168.188.121"}' # pihole
dracut -f # for DHCP clients
# - or - for static IP:
dracut -f --kernel-cmdline "ip=client_ip netmask=client_netmask gateway=client_gateway_ip nameserver=client_DNS_ip"
