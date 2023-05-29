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
# create user: User_Name:Password:UID:GID:Comments:User_Home_Directory:Users_Shell_Name
ssh "${USER}@lfs603.srv.lu.se sudo echo '${project_id}:${password}::::${lfs_project_dir}:/bin/bash' | newusers"
# add user to ssh_users group
ssh "${USER}@lfs603.srv.lu.se sudo adduser ${project_id} ssh_users"
# sync directory to lfs603
rsync -av --progress --human-readable --no-perms "${data%%/} ${USER}@lfs603.srv.lu.se:${lfs_project_dir}"

# output the password to file
echo "${password}" > "password.txt"
