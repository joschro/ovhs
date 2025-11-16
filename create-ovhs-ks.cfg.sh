#!/bin/bash

# Exit on any error
set -e

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help      						Show this help message"
    echo "  -v, --verbose   						Enable verbose output"
    echo "  -f, --file FILE 						Specify output file"
    echo "  -b, --bootmode <bios|uefi>					Specify boot mode"
    echo "  -d, --diskmode <single_hd|mirrored_hd|mirrored_cached_hd>	Specify disk mode"
    exit 1
}

# Default values
VERBOSE=false
OUTPUT_FILE="ovhs-ks.cfg"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -f|--file)
            if [[ -n "$2" ]]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                echo "Error: --file requires an argument." >&2
                usage
            fi
            ;;
	-b|--bootmode)
	    if [[ -n "$2" ]]; then
                BOOT_MODE="$2"
                shift 2
            else
                echo "Error: --bootmode requires an argument." >&2
                usage
            fi  
            ;;
	-d|--diskmode)
	    if [[ -n "$2" ]]; then
                DISK_MODE="$2"
                shift 2
            else
                echo "Error: --diskmode requires an argument." >&2
                usage
            fi 
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            usage
            ;;
        *)
            echo "Error: Unknown argument $1" >&2
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$OUTPUT_FILE" ]]; then
    echo "Error: --file is required." >&2
    usage
fi

if [[ "$BOOT_MODE" != "bios" && "$BOOT_MODE" != "uefi" ]]; then
    echo "Error: --bootmode <bios|uefi> is required." >&2
    usage
fi

if [[ "$DISK_MODE" != "single_hd" && "$DISK_MODE" != "mirrored_hd" && "$DISK_MODE" != "mirrored_cached_hd" ]]; then
    echo "Error: --bootmode <single_hd|mirrored_hd|mirrored_cached_hd> is required." >&2
    usage
fi

# Main script logic
if [[ "$VERBOSE" == true ]]; then
    echo "Creating file: $OUTPUT_FILE"
    echo "BOOT_MODE: $BOOT_MODE"
    echo "DISK_MODE: $DISK_MODE"
fi

# Reset output file
cat > "$OUTPUT_FILE" <<EOF
#version=RHEL9

# https://docs.centos.org/en-US/centos/install-guide/Kickstart2/

EOF

# Creating output file
cat >> "$OUTPUT_FILE" <<EOF
# System authorization information
authselect --enableshadow --passalgo=sha512

# Use graphical install
#graphical
# Perform kickstart installation in text mode
text

# Use CDROM / network installation media
# when using http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-dvd1.iso:
#cdrom
# when using http://isoredirect.centos.org/centos/8/isos/x86_64/CentOS-8.5.2111-x86_64-boot.iso:
#url --mirrorlist="http://mirrorlist.centos.org/?release=$releasever&arch=x86_64&repo=BaseOS&infra=$infra"
# when using http://isoredirect.centos.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-boot.iso:
#url --mirrorlist="http://mirrorlist.centos.org/?release=$releasever-stream&arch=$basearch&repo=BaseOS&infra=$infra"
url --metalink=https://mirrors.centos.org/metalink?repo=centos-baseos-$releasever-stream&arch=$basearch&protocol=https

# disable kdump for testing purposes
# %addon com_redhat_kdump --enable
%addon com_redhat_kdump --disable
%end

# Run the Setup Agent on first boot
firstboot --enable

# Do not configure the X Window System
skipx

# Keyboard layouts
#keyboard --vckeymap=de --xlayouts='de (nodeadkeys)'
keyboard --xlayouts='de (nodeadkeys)'

# System language
#lang de_DE.UTF-8
lang en_US.UTF-8

# Network information
network  --hostname=ovhs --bootproto=dhcp --onboot=on --ipv6=auto --activate
#network  --bootproto=dhcp --onboot=on --ipv6=auto --activate
#network  --bootproto=dhcp --device=enp3s0 --ipv6=auto --activate
#network  --bootproto=dhcp --device=enp4s1 --ipv6=auto
#network --hostname=ovhs

# Root password
# you can use "python -c 'import crypt; print(crypt.crypt("My Password", crypt.mksalt()))'" to create the hash on a linux command line
# the below example reflects the password "ovhs"
rootpw --iscrypted $6$4DVXePa2eKw4pukd$eS1jWHtxhROlAn0TWrzTirngzT4JHin6eFk1YQGBDGTVy3yG610bMyqoUgNTI6h.btAtrqcz4nt6Zu6qKs97r1
#  --allow-ssh
#  --lock

# add user ovhs
user --name=ovhs --gecos="OVHS system user" --groups="wheel" --iscrypted --password="$6$4DVXePa2eKw4pukd$eS1jWHtxhROlAn0TWrzTirngzT4JHin6eFk1YQGBDGTVy3yG610bMyqoUgNTI6h.btAtrqcz4nt6Zu6qKs97r1"

# Firewall
firewall --enabled --port=53

# System services
#services --enabled="chronyd,systemd-resolved"
services --enabled="chronyd"

# System timezone
#timezone Europe/Berlin --utc --ntpserver 0.de.pool.ntp.org --ntpserver 1.de.pool.ntp.org --ntpserver 2.de.pool.ntp.org --ntpserver 3.de.pool.ntp.org
timesource --ntp-server=0.de.pool.ntp.org
timesource --ntp-server=1.de.pool.ntp.org
timesource --ntp-server=2.de.pool.ntp.org
timezone Europe/Berlin --utc
EOF

test "$DISK_MODE" = "single_hd" && cat >> "$OUTPUT_FILE" <<EOF
### SINGLE HD INSTALL:
# Ignore all disks except the intended ones
#ignoredisk --only-use=sda
# Partition clearing information
#clearpart --all --initlabel --drives=sda
## Disk partitioning information
# For BIOS booting only
# <---
#part biosboot_sda --fstype="biosboot" --ondisk=sda --asprimary --size=1
#part /boot     --fstype="xfs" --ondisk=sda --asprimary --size=1024
# --->
# For UEFI booting only
# <---
#part /boot/efi --fstype="efi" --ondisk=sda --asprimary --size=200
#part pv.01 --ondisk=sda --asprimary --size=100000 --grow --encrypted --passphrase=1234567890
# --->
EOF

test "$DISK_MODE" = "mirrored_hd" && cat >> "$OUTPUT_FILE" <<EOF
### MIRRORED HD INSTALL:
# Ignore all disks except the intended ones
ignoredisk --only-use=sda,sdb
# Partition clearing information
clearpart --all --initlabel --drives=sda,sdb
# Disk partitioning information
# <---
# For BIOS booting only
#part biosboot_sda --fstype="biosboot" --ondisk=sda --asprimary --size=1
#part biosboot_sdb --fstype="biosboot" --ondisk=sdb --asprimary --size=1
# --->
part raid.01 --fstype="mdmember" --ondisk=sda --asprimary --size=1024
part raid.02 --fstype="mdmember" --ondisk=sdb --asprimary --size=1024
# <---
# For UEFI boot only
part raid.11 --fstype="mdmember" --ondisk=sda --asprimary --size=256
part raid.12 --fstype="mdmember" --ondisk=sdb --asprimary --size=256
# --->
EOF

test "$DISK_MODE" = "single_hd" -o "$DISK_MODE" = "mirrored_hd" && cat >> "$OUTPUT_FILE" <<EOF
part raid.21 --fstype="mdmember" --ondisk=sda --asprimary --size=200000
part raid.22 --fstype="mdmember" --ondisk=sdb --asprimary --size=200000
part raid.31 --fstype="mdmember" --ondisk=sda --asprimary --size=100000 --grow
part raid.32 --fstype="mdmember" --ondisk=sdb --asprimary --size=100000 --grow
raid /boot --device=boot --fstype="ext4" --level=1 raid.01 raid.02
# <---
# For UEFI boot only
raid /boot/efi --device=boot_efi --fstype="efi" --level=1 --fsoptions="umask=0077,shortname=winnt" raid.11 raid.12
# --->
raid pv.01 --device=md1 --level=1 raid.21 raid.22 --encrypted --passphrase=1234567890
raid pv.02 --device=md2 --level=1 raid.31 raid.32
volgroup ovhs_os --pesize=4096 pv.01 --reserved-percent=20
EOF

test "$DISK_MODE" = "mirrored_cached_hd" && cat >> "$OUTPUT_FILE" <<EOF
### MIRRORED HD INSTALL WITH OS&CACHE HD
# Ignore all disks except the intended ones
ignoredisk --only-use=sda,sdb,sdc
# Partition clearing information
#clearpart --none --initlabel
clearpart --all --initlabel --drives=sda,sdb,sdc --all
# Disk partitioning information
# OS disk
part /boot/efi --fstype="efi"   --ondisk=disk/by-id/scsi-SATA_Samsung_SSD_860_S4XBNJ0N604366Y --asprimary --size=1024 --fsoptions="umask=0077,shortname=    winnt"
part /boot     --fstype="ext4"  --ondisk=disk/by-id/scsi-SATA_Samsung_SSD_860_S4XBNJ0N604366Y --asprimary --size=4096
part pv.1001   --fstype="lvmpv" --ondisk=disk/by-id/scsi-SATA_Samsung_SSD_860_S4XBNJ0N604366Y --asprimary --size=254806 --encrypted --luks-version=luks2     #--passphrase=1234567890
part pv.1002   --fstype="lvmpv" --ondisk=disk/by-id/scsi-SATA_Samsung_SSD_860_S4XBNJ0N604366Y --asprimary --size=10000 --grow
# Mirrored data disks
part raid.0001 --fstype="mdmember" --ondisk=disk/by-id/scsi-SATA_TOSHIBA_HDWN180_X9I5K14AFAVG --size=100000 --grow
part raid.0002 --fstype="mdmember" --ondisk=disk/by-id/scsi-SATA_TOSHIBA_HDWN180_X9I5K14BFAVG --size=100000 --grow
raid pv.0012 --device=luks-pv00 --fstype="lvmpv" --level=RAID1 raid.0001 raid.0002

### Volume Group information:
#volgroup ovhs_os --pesize=4096 pv.1001 --reserved-percent=20
volgroup ovhs_os --pesize=4096 pv.1001

# add cache pv to data volume group
#volgroup ovhs_cache --pesize=4096 pv.1002

volgroup ovhs_data --pesize=4096 pv.0012 pv.1002
# create thick volumes:
logvol /data          --vgname=ovhs_data --fstype="ext4" --size=102400 --encrypted --luks-version=luks2 --name=data --cachepvs=pv.1002 --cachemode=writeback --cachesize=200000 #--passphrase=1234567890
EOF

cat >> "$OUTPUT_FILE" <<EOF
### Logical Volume information:
## create thick volumes:
#logvol swap           --vgname=ovhs_os --fstype="swap" --size=16136 --name=swap
logvol swap           --vgname=ovhs_os --fstype="swap" --size=16097 --name=swap
#logvol /              --vgname=ovhs_os --fstype="ext4" --size=30000 --name=root
logvol /              --vgname=ovhs_os --fstype="ext4" --size=71680 --name=root
logvol /var           --vgname=ovhs_os --fstype="ext4" --size=20000 --name=var
logvol /var/crash     --vgname=ovhs_os --fstype="ext4" --size=10000 --name=var_crash
logvol /var/log       --vgname=ovhs_os --fstype="ext4" --size=8000  --name=var_log
logvol /var/log/audit --vgname=ovhs_os --fstype="ext4" --size=2000  --name=var_audit
logvol /home          --vgname=ovhs_os --fstype="ext4" --size=10000 --name=home
logvol /tmp           --vgname=ovhs_os --fstype="ext4" --size=2000  --name=tmp

## create above volumes as thin volumes:
#logvol none            --vgname=ovhs_os --name=lvThinPool --thinpool --metadatasize=16000 --size=120000 --grow
#logvol /               --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=30000 --name=root
#logvol /var            --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=20000 --name=var
#logvol /var/crash      --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=10000 --name=var_crash
#logvol /var/log        --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=8000  --name=var_log
#logvol /var/log/audit  --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=2000  --name=var_audit
#logvol /home           --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=10000 --name=home
#logvol /tmp            --vgname=ovhs_os --fstype="ext4" --thin --poolname=lvThinPool --fsoptions="defaults,discard" --size=2000  --name=tmp
EOF

cat >> "$OUTPUT_FILE" <<EOF
# Base Software installation:
%packages
@base
@core
#@network-file-system-client
#@headless-management
#@remote-system-management

# standard selection for server:
#@^server-product-environment
#@system-tools
#@^virtualization-host-environment
#@virtualization-hypervisor
#@virtualization-platform
#@virtualization-tools
#@container-management
#bind-utils
chrony
#cockpit-machines
cockpit
cockpit-bridge
cockpit-system
cockpit-ws
#deltarpm
#screen
#nfs-utils
#system-storage-manager
#ctdb
#git
tmux
#vim
vim-enhanced
%end
EOF

cat >> "$OUTPUT_FILE" <<EOF
# self-hosted engine setup with gluster storage taken from
# https://www.ovirt.org/documentation/gluster-hyperconverged/chap-Single_node_hyperconverged.html
# http://community.redhat.com/blog/2014/10/up-and-running-with-ovirt-3-5/ and
# http://community.redhat.com/blog/2014/11/up-and-running-with-ovirt-3-5-part-two/
%post
# multipathd throws ugly errors, thus we blacklist the harddisks
#cat >> /etc/multipath.conf <<EOF
#
#blacklist {
#       devnode "^sd[a-b]"
#}
#EOF

# configure nested virtualization for the host
#grep -i "^model.*intel" /proc/cpuinfo && /usr/bin/sed -i "s/^#\(options kvm_intel nested=1.*\)/\1/" /etc/modprobe.d/kvm.conf
#grep -i "^model.*amd" /proc/cpuinfo && /usr/bin/sed -i "s/^#\(options kvm_amd nested=1.*\)/\1/" /etc/modprobe.d/kvm.conf

# update installation
#yum -y install epel-release
#/bin/yum -y install http://resources.ovirt.org/pub/yum-repo/ovirt-release-master.rpm
#/bin/yum -y install http://resources.ovirt.org/pub/yum-repo/ovirt-release43.rpm
#/bin/yum -y install gdeploy cockpit-ovirt-dashboard vdsm-gluster ovirt-engine-appliance #ansible git
#/bin/yum -y update
systemctl enable cockpit.socket
%end
EOF

cat >> "$OUTPUT_FILE" <<EOF
# copy CentOS install ISO image to /home/tmp/ for later re-use
#%post --nochroot
#mkdir -p /mnt/sysimage/home/tmp
#dd if=$(df | grep "/run/install" | head -n1 | cut -d" " -f1) of=/mnt/sysimage/home/tmp/$(blkid -o value $(df | grep "/run/install" | head -n1 | cut -d" " -f1) | grep -i CentOS).iso bs=4M
#%end

# automatically start oVirtHomeServer installation via ansible (deactivated, just download setup script)
%post
/bin/yum -y install epel-release
/bin/yum -y install ansible
# oVirt engine
/bin/yum -y install centos-release-ovirt45
/bin/yum -y install ovirt-hosted-engine-setup
#/bin/yum -y install ovirt-engine-appliance
#ansible-pull -U https://github.com/joschro/ovhs.git
#/bin/curl -o /home/ovhs/run-ovhs_ansible_install.sh https://raw.githubusercontent.com/joschro/ovhs/master/run-ovhs_ansible_install.sh
#chown ovhs:ovhs /home/ovhs/run-ovhs_ansible_install.sh
%end

reboot
EOF

cat >> "$OUTPUT_FILE" <<EOF

EOF

# Success message
echo "Script completed successfully."
