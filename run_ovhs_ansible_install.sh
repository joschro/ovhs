#!/bin/sh

test -f ~/.ssh/id_rsa || ssh-keygen

cd ~
rpm -q git || yum install -y git
test -f joschro/git-update.sh || git clone https://github.com/joschro/joschro.git
test -f ovhs/run_ovhs_ansible_install.sh || git clone https://github.com/joschro/ovhs.git

cd ovhs
rpm -q ansible || yum install -y ansible
#ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts --check 01_ovhs_base_setup.yml
ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts -t networking $* 01_ovhs_base_setup.yml
echo;echo "$0 done with networking part. Press any key."
read ANSW
ssh-copy-id root@ovhs01_back
ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts -t storage $* 01_ovhs_base_setup.yml


#ansible-galaxy install -r roles/requirements.yml -p roles
