#!/bin/sh

pwd

test -d roles || exit

ssh-keygen
#ssh-copy-id root@localhost

#ansible-galaxy install -r roles/requirements.yml -p roles
rpm -q ansible || yum install -y ansible
ansible-playbook 01_ovirt.yml
