#!/bin/sh

test -f ~/.ssh/id_rsa || ssh-keygen
#ssh-copy-id root@localhost

cd ~
rpm -q git || yum install -y git
test -f joschro/git-update.sh || git clone https://github.com/joschro/joschro.git
test -f ovhs/run_ovhs_ansible_install.sh || git clone https://github.com/joschro/ovhs.git

cd ovhs
rpm -q ansible || yum install -y ansible
ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts --check 01_ovhs_base_setup.yml

#ansible-galaxy install -r roles/requirements.yml -p roles
