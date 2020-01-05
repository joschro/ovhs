#!/bin/sh

rpm -q git ansible ovirt-release43 || yum install -y git ansible http://resources.ovirt.org/pub/yum-repo/ovirt-release43.rpm
rpm -q ovirt-hosted-engine-setup || yum install -y ovirt-hosted-engine-setup

test -f ~/.ssh/id_rsa || ssh-keygen

cd ~
test -f joschro/git-update.sh || git clone https://github.com/joschro/joschro.git
test -f ovhs/run-ovhs_ansible_install.sh || {
  git clone https://github.com/joschro/ovhs.git
  echo "Please add a password to ovhs/passwords.yml and encrypt it with \"ansible-vault encrypt passwords.yml\""
  exit
}

#test -d /etc/ansible/roles/ovirt.engine-setup || ansible-galaxy install ovirt.engine-setup
#test -d /etc/ansible/roles/ovirt.hosted_engine_setup || ansible-galaxy install ovirt.hosted_engine_setup
cd ovhs
#ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts --check 01-ovhs_base_setup.yml
ansible-playbook --ask-vault-pass -i inventory/hosts -t networking $* 01-ovhs_base_setup.yml
echo;echo "$0 done with networking part. Press any key."
read ANSW
ssh-copy-id root@ovhs01-back
ansible-playbook --ask-vault-pass -i inventory/hosts -t storage $* 01-ovhs_base_setup.yml

ansible-playbook --ask-vault-pass -i inventory/hosts -t ovirt $* 02-ovhs_ovirt_setup.yml

#ansible-playbook hosted_engine_deploy.yml --extra-vars='@he_deployment.json' --extra-vars='@passwords.yml' --ask-vault-pass

#ansible-galaxy install -r roles/requirements.yml -p roles
