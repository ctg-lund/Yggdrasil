#!/bin/bash

# default values for optional arguments
LFS_USER=$USER
EMAIL="cglu.bioinformatics@scilifelab.se"

# Define the options and arguments using getopts
while getopts ":d:p:u:e:" opt; do
  case "${opt}" in
    d)
      # Validate the directory argument
      if [[ -d "${OPTARG}" ]]; then
        DIRECTORY="${OPTARG}"
      else
        echo "Error: Invalid directory argument."
        exit 1
      fi
      ;;
    p)
      # Validate the project ID argument
      if [[ "${OPTARG}" =~ ^[0-9]{4}_[0-9]{3}$ ]]; then
        PROJECT_ID="${OPTARG}"
      else
        echo "Error: Invalid project ID argument."
        exit 1
      fi
      ;;
    u)
      # Set the LFS_USER variable to the specified user
      LFS_USER="${OPTARG}"
      ;;
    e)
      # Set the EMAIL variable to the specified email
      EMAIL="${OPTARG}"
      ;;
    :)
      echo "Error: Missing argument for -${OPTARG} option."
      exit 1
      ;;
    *)
      echo "Error: Invalid option -${OPTARG}."
      exit 1
      ;;
  esac
done

# Validate if the required arguments are set
if [[ -z "${DIRECTORY}" || -z "${PROJECT_ID}" ]]; then
  echo "Error: Missing required arguments. Specify at least -d directory/path and p YYYY_XXX"
  exit 1
fi

# print for testing purposes
echo "The directory is: ${DIRECTORY}"
echo "The project ID is: ${PROJECT_ID}"
echo "The LFS_USER is: ${LFS_USER}"
echo "The email is: ${EMAIL}"


# delivery server root
lfs_root="/srv/data"

size=$(du -sh "${DIRECTORY}" | cut -f1)
# Set lfs603 ${PROJECT_ID} and target folders
lfs_project_dir="${lfs_root}/${PROJECT_ID}" 
# generate a password
password=$(date +%s | sha256sum | base64 | head -c 32)
# remote execution:
ssh -T "${LFS_USER}@lfs603.srv.lu.se" << _remote_cmds
# create project directory
sudo mkdir -p $lfs_project_dir
# create user: User_Name:Password:UID:GID:Comments:User_Home_Directory:Users_Shell_Name
echo "${PROJECT_ID}:${password}::::${lfs_project_dir}:/bin/bash" | sudo newusers
# add user to ssh_users group
sudo adduser ${PROJECT_ID} ssh_users

# add commands above this line
_remote_cmds

# sync directory to lfs603, beware the trailing /
rsync -rvL --rsync-path="sudo rsync" --progress --human-readable --no-perms "${DIRECTORY%%/}" "${LFS_USER}@lfs603.srv.lu.se:${lfs_project_dir}" || exit 1

# post transfer commands
ssh -T "${LFS_USER}@lfs603.srv.lu.se" << _remote_cmds
# create project directory
sudo chown -R ${PROJECT_ID}:${LFS_USER} $lfs_project_dir
mutt -s "CTG delivery - project ${PROJECT_ID}" ${EMAIL} \
	-e 'unmy_hdr from; my_hdr From: CTG data delivery <${EMAIL}>' \
	-e 'set content_type=text/html' \
	-a "/srv/data/ctgstaff/latest.pdf" \
<< EOM
<h1 style="font-size: 24px; color: #333333;">CTG Data Delivery</h1>
<p style="font-size: 18px; color: #333333;">
    The sequencing and processing of your samples is completed and ready for download.
    <br><br>
    <b>IMPORTANT:</b>
    <ul>
        <li>Our delivery server has limited storage capacity. Please retrieve your data within <b>one week</b> of receiving this email or let us know when you are planning to download the data. A full delivery server can cause delays for everyone.</li>
        <li>We keep raw data that can be used to reconstruct your data on our HPC for a limited time:
            <ul>
                <li>Sequencing only: 30 days</li>
                <li>Other projects: 90 days</li>
            </ul>
            This time is counted from when the data was sequenced. After that, we need to clear raw data to enable us to process more projects. Please note that there is no guarantee that your raw data will still be with us after the above specified time.
        </li>
    </ul>
</p>

<img src="https://content.ilabsolutions.com/wp-content/uploads/2021/12/2021-12-08_15-26-03.jpg" width="500" alt="CTG Data Delivery">
<h2 style="font-size: 20px; color: #333333;">CTG-Project-ID</h2>
<h2 style="font-size: 20px; background-color: CadetBlue; color: white;">${PROJECT_ID}</h2>
<hr>
<h3 style="font-size: 18px; color: #333333;">You can download the files with:</h3>
<p style="font-size: 16px; color: #333333;">
    <b>Make sure you have enough space for your project! This download will take up: ${size} </b><br>
    <span style="background-color: lightgrey">User: ${PROJECT_ID}</span><br>
    Password: <span style="background-color: lightgrey">${password}</span><br><br>
    Example scp command:<br>
    <span style="background-color: lightgrey">scp -P 22022 -r ${PROJECT_ID}@lfs603.srv.lu.se:/srv/data/${PROJECT_ID} . </span>
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
