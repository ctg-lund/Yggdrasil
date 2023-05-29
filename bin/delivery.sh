#!/bin/bash 
# Usage:
# bash delivery.sh DATA-TO-DELIVER
# this script assumes $USER is same on lfs and lsens!

# delivery server root
lfs_root="/srv/data"
# first arg is the data to deliver
data=$1
# eg ../Jobs/proj_id we have to specify this
project_id=$2
# Set lfs603 ${project_id} and target folders
lfs_project_dir="${lfs_root}/${project_id}" 
# generate a password
password=$(date +%s | sha256sum | base64 | head -c 32)
# remote execution:
ssh -T "${USER}@lfs603.srv.lu.se" << _remote_cmds
# create project directory
sudo mkdir -p $lfs_project_dir
# create user: User_Name:Password:UID:GID:Comments:User_Home_Directory:Users_Shell_Name
echo "${project_id}:${password}::::${lfs_project_dir}:/bin/bash" | sudo newusers
# add user to ssh_users group
sudo adduser ${project_id} ssh_users

# add commands above this line
_remote_cmds

# sync directory to lfs603
rsync -rv --rsync-path="sudo rsync" --progress --human-readable --no-perms "${data%%/}" "${USER}@lfs603.srv.lu.se:${lfs_project_dir}" || exit 1

# output the password to file
# echo -e "${project_id}\n${password}\n\n" > "${HOME}/passwords.txt"

# post transfer commands
ssh -T "${USER}@lfs603.srv.lu.se" << _remote_cmds
# create project directory
sudo chown -R ${project_id}:${USER} $lfs_project_dir
sudo bash /home/mattis/Scripts/send_project.sh ${project_id} ${password}

# add commands above this line
_remote_cmds