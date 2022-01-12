#!/bin/sh

# generate ssh key
sudo test -f ~/.ssh/id_rsa || sudo ssh-keygen

cd ~
test -f joschro/git-update.sh || git clone https://github.com/joschro/joschro.git
test -f ovhs/run-ovhs_ansible_install.sh || {
  git clone https://github.com/joschro/ovhs.git
  echo "Please add a password to ovhs/passwords.yml and encrypt it with \"ansible-vault encrypt passwords.yml\""
  exit
}


exit

# from https://ovirt.org/documentation/gluster-hyperconverged/chap-Single_node_hyperconverged.html
#ssh-keygen
#ssh-copy-id root@ovhs.fritz.box
#yum install http://resources.ovirt.org/pub/yum-repo/ovirt-release44.rpm
#yum install gluster-ansible-roles cockpit-ovirt-dashboard vdsm-gluster ovirt-engine-appliance

rpm -q git ansible ovirt-release44 || yum install -y git ansible http://resources.ovirt.org/pub/yum-repo/ovirt-release44.rpm
rpm -q ansible || yum install -y ansible
rpm -q epel-next-release || yum install -y epel-next-release
rpm -q ovirt-hosted-engine-setup || yum install -y ovirt-hosted-engine-setup

# /etc/hosts
192.168.178.5   ovhs.local      ovhs    ovhs-storage.local      ovhs-storage
192.168.178.6   ovirt-engine.local      ovirt-engine


#test -d /etc/ansible/roles/ovirt.engine-setup || ansible-galaxy install ovirt.engine-setup
#test -d /etc/ansible/roles/ovirt.hosted_engine_setup || ansible-galaxy install ovirt.hosted_engine_setup
cd ovhs
#ansible-playbook --vault-password-file ../vault_pass -i inventory/hosts --check 01-ovhs_base_setup.yml
#ansible-playbook --ask-vault-pass -i inventory/hosts -t networking $* 01-ovhs_base_setup.yml
ansible-playbook -i inventory/hosts -t networking $* 01-ovhs_base_setup.yml
echo;echo "$0 done with networking part. Press any key."
read ANSW

ansible-playbook -i inventory/hosts 01b-check-resolve_conf.yml
ssh-copy-id root@ovhs01-back || exit

#ansible-playbook --ask-vault-pass -i inventory/hosts -t storage $* 01-ovhs_base_setup.yml
ansible-playbook -i inventory/hosts -t storage $* 01-ovhs_base_setup.yml

#ansible-playbook --ask-vault-pass -i inventory/hosts -t ovirt $* 02-ovhs_ovirt_setup.yml
ansible-playbook -i inventory/hosts -t ovirt $* 02-ovhs_ovirt_setup.yml

#ansible-playbook hosted_engine_deploy.yml --extra-vars='@he_deployment.json' --extra-vars='@passwords.yml' --ask-vault-pass

#ansible-galaxy install -r roles/requirements.yml -p roles

exit
ovirt-hosted-engine-cleanup;rm -rf /var/tmp/localvm*;cat /etc/resolv.conf;vim /etc/hosts;systemctl restart dnsmasq;systemctl status dnsmasq
