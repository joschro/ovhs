#!/bin/sh

pwd

test -d roles || exit

#ansible-galaxy install -r roles/requirements.yml -p roles
ansible-playbook ovhs.yml
