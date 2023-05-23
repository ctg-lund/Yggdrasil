#!/bin/bash 
# Usage:
# bash delivery.sh DATA-TO-DELIVER
# this script assumes $USER is same on lfs and lsens!

# delivery server root
lfs_root="/srv/data"
# first arg is the data to deliver
data="$1"
# eg ../Jobs/proj_id
project_id="$(basename $data)"
# Set lfs603 ${project_id} and target folders
lfs_project_dir="${lfs_root}/${project_id}" 
# generate a password
password=$(openssl rand --base64 16)
# remote execution:
ssh -T "${USER}@lfs603.srv.lu.se" << _remote_cmds
# create project directory
sudo mkdir -p $lfs_project_dir
# create user: User_Name:Password:UID:GID:Comments:User_Home_Directory:Users_Shell_Name
echo '${project_id}:${password}::::${lfs_project_dir}:/bin/bash' |sudo newusers"
# add user to ssh_users group
sudo adduser ${project_id} ssh_users"

# add commands above this line
_remote_cmds

# sync directory to lfs603
rsync -av --progress --human-readable --no-perms "${data%%/} ${$USER}@lfs603.srv.lu.se:${lfs_project_dir}"

# output the password to file
echo "${password}" > "password.txt"
