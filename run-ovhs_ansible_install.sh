#!/bin/sh

test -f ~/.ssh/id_rsa || ssh-keygen

cd ~
rpm -q git || yum install -y git
test -f joschro/git-update.sh || git clone https://github.com/joschro/joschro.git
test -f ovhs/run-ovhs_ansible_install.sh || {
  git clone https://github.com/joschro/ovhs.git
  echo "Please add a password to ovhs/passwords.yml and encrypt it with \"ansible-vault encrypt passwords.yml\""
  exit
}

cd ovhs
rpm -q ansible || yum install -y ansible
#ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts --check 01-ovhs_base_setup.yml
ansible-playbook --ask-vault-pass -i inventory/hosts -t networking $* 01-ovhs_base_setup.yml
echo;echo "$0 done with networking part. Press any key."
read ANSW
ssh-copy-id root@ovhs01-back
ansible-playbook --ask-vault-pass -i inventory/hosts -t storage $* 01-ovhs_base_setup.yml

#ansible-playbook hosted_engine_deploy.yml --extra-vars='@he_deployment.json' --extra-vars='@passwords.yml' --ask-vault-pass
ansible-playbook --ask-vault-pass -i inventory/hosts -t ovirt $* 01-ovhs_base_setup.yml --ask-vault-pass

#ansible-galaxy install -r roles/requirements.yml -p roles
