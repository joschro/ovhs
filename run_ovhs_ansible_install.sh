#!/bin/sh

ssh-keygen
#ssh-copy-id root@localhost

rpm -q git || yum install -y git && {
  git clone https://github.com/joschro/joschro.git
  git clone https://github.com/joschro/ovhs.git
}

rpm -q ansible || yum install -y ansible && {
  echo ansible-playbook 01_ovirt.yml
}
#ansible-galaxy install -r roles/requirements.yml -p roles
