#!/bin/bash 
# Usage:
# bash delivery.sh DATA-TO-DELIVER
# this script assumes $USER is same on lfs and lsens!

# delivery server root
lfs_root="/srv/data"
# first arg is the data to deliver
data=$1
size=$(du -sh "${data}" | cut -f1)
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
mutt -s "CTG delivery - project ${project_id}" mattis.knulst@med.lu.se \
	-e 'unmy_hdr from; my_hdr From: CTG data delivery <mattis.knulst@med.lu.se>' \
	-e 'set content_type=text/html' \
	-a "/srv/data/ctgstaff/ctg-delivery-guide-v1.1.pdf" \
<< EOM
<h1 style="font-size: 24px; color: #333333;">CTG Data Delivery</h1>
<p style="font-size: 18px; color: #333333;">The sequencing and processing of your CTG samples is completed and ready for download. Please find download instructions below and QC reports attached.</p>
<img src="https://content.ilabsolutions.com/wp-content/uploads/2021/12/2021-12-08_15-26-03.jpg" width="500" alt="CTG Data Delivery">
<h2 style="font-size: 20px; color: #333333;">CTG-Project-ID</h2>
<h2 style="font-size: 20px; background-color: CadetBlue; color: white;">${project_id}</h2>
<hr>
<h3 style="font-size: 18px; color: #333333;">You can download the files with:</h3>
<p style="font-size: 16px; color: #333333;">
    <b>Make sure you have enough space for your project! This download will take up: ${size} </b><br>
    <span style="background-color: lightgrey">User: ${project_id}</span><br>
    Password: <span style="background-color: lightgrey">${password}</span><br><br>
    Example scp command:<br>
    <span style="background-color: lightgrey">scp -P 22022 -r ${project_id}@lfs603.srv.lu.se:/srv/data/${project_id} . </span>
</p>
<p style="font-size: 16px; color: #333333;">Find attached <b>ctg-delivery-guide-v1.1.pdf</b> for download instructions!</p>
<p style="font-size: 16px; color: #333333;">Please do not hesitate to contact us if you have any questions or issues.</p>
<p style="font-size: 16px; color: #333333;">
    Best regards,<br>
    CTG Bioinformatics<br>
    Center for Translational Genomics<br>
    Clinical Genomics<br>
    Lund
</p>


EOM



# add commands above this line
_remote_cmds