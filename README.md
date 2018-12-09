# oVirtHomeServer
An extensible virtualization server setup based on oVirt on Gluster for home use

## Overview

## Installation

### Install master server
Download the latest CentOS image for x86 64bit from `https://www.centos.org/download/`; on a Linux system this could look like this:
```
wget -c http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso
```

Now, as user `root` write the ISO image to an SD card to boot the server from; on Linux, this could look like this:
```
# dd if=CentOS-7-x86_64-DVD-1810.iso of=/dev/sdb bs=4M
```

```
http://raw.githubusercontent.com/joschro/ovhs/master/ovhs-ks.cfg
```
