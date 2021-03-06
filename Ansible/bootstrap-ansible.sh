#!/usr/bin/env bash

set -e

home_dir="/home/vagrant"
git_repo="https://github.com/Novitoll/devops-linux-mentoring-program.git"
git_repo_dir="$home_dir/my_repo"

# install ansible on ansible node
sudo yum install -y epel-release
sudo yum install -y ansible

echo "Ansible version is $(ansible --version)"

# install git
yum install -y git

# copy repo to ansbile VM
# ideally, we should also pull master branch of git repo if the repo directory exists,
# but we also need to handle Git auth then, so wont make complex things
if [ ! -d $git_repo_dir ]; then
    echo "No repository found. Cloning Git repo $git_repo.."
    git clone $git_repo $git_repo_dir;
fi

mkdir -p /root/.ssh
chmod 700 /root/.ssh

# check SSH RSA keys
if [ ! -f "/root/.ssh/id_rsa" ]; then
    cp /vagrant/node/ssh/id_rsa /root/.ssh/id_rsa
    chmod 400 /root/.ssh/id_rsa
fi

if [ ! -f $home_dir/hosts.ini ]; then
    cp $git_repo_dir/Ansible/node/hosts.ini $home_dir/hosts.ini
fi

# configure hosts file for our internal network defined by Vagrantfile
# TODO: need to check this for idempotence
cat $git_repo_dir/Ansible/node/hosts >> "/etc/hosts"
cat $git_repo_dir/Ansible/node/ansible.cfg >> "/etc/ansible/ansible.cfg"

echo "DONE. You can now play the main playbook $git_repo_dir/Ansible/node/site.yml via ansible-playbook."
