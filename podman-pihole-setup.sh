#!/bin/sh

# install CentOS from https://people.centos.org/pgreco/CentOS-Userland-8-stream-aarch64-RaspberryPI-Minimal-4/
# if you want to use a german keyboard layout, run
#   [root@pihole ~] loadkeys de
# to make use of the whole SD card, remove the last partition and recreate it with the same parameters, but maximum size, with the following commands
#   [root@pihole ~] fdisk /dev/mmcblk0
#   [root@pihole ~] resize2fs /dev/mmcblk0p3
# if you want to use a wireless network, run
#   [root@pihole ~] nmtui
# to use the Cockpit management system, run
#   [root@pihole ~] yum -y install cockpit-dashboard cockpit-composer cockpit-machines cockpit-podman cockpit-storaged cockpit-session-recording epel-release vim
# update your installation with
#   [root@pihole ~] yum update -y
#   [root@pihole ~] reboot

# from https://monroec.com/?p=1408

test $# -lt 1 && echo "Syntax: $0 <webpassword>" && exit
serverIP="192.168.188.2"

ip li sh | grep cni-podman0 || ip link add cni-podman0 type bridge
podman volume ls | grep pihole_pihole || podman volume create pihole_pihole
podman volume ls | grep pihole_dnsmasq || podman volume create pihole_dnsmasq

podman run -d \
	--privileged \
	--restart=always \
	--name=pihole \
	--hostname pihole.schroeder-home.org \
	-e TZ=Europe/Berlin \
	-e WEBPASSWORD=$1 \
	-e SERVERIP=$serverIP \
	-v pihole_pihole:/etc/pihole:Z \
	-v pihole_dnsmasq:/etc/dnsmasq.d:Z \
	--dns=127.0.0.1 --dns=1.1.1.1 \
	-p 80:80 \
	-p 67:67/udp \
	-p $serverIP:53:53/udp \
	pihole/pihole
# --memory 512m --cpus 1

# optional:
# encrypt /var/lib/containers/storage/volumes on mmcblk0p4
