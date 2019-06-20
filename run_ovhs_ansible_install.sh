#!/bin/sh

ssh-keygen
#ssh-copy-id root@localhost

rpm -q git || yum install -y git && {
  git clone https://github.com/joschro/joschro.git
  git clone https://github.com/joschro/ovhs.git
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  cat <<EOF > ~/.vimrc
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'pearofducks/ansible-vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()
EOF
}

rpm -q ansible || yum install -y ansible && {
  echo ansible-playbook 01_ovirt.yml
}
#ansible-galaxy install -r roles/requirements.yml -p roles
