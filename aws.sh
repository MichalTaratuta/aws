#!/bin/bash

set -e

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -k|--key)
    AWS_KEY="$2"
    shift
    shift
    ;;
    -s|--secret)
    AWS_SECRET="$2"
    shift
    shift
    ;;
    -r|--region)
    AWS_REGION="$2"
    shift
    shift
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


apt-add-repository ppa:ansible/ansible --yes
apt-get update && apt-get install python-pip ansible git -y

# There is locale issue with default Ubuntu 16.04 image
sudo locale-gen "en_GB.UTF-8"
sudo dpkg-reconfigure locales -f noninteractive

pip install awscli boto3 botocore

git clone https://github.com/SoftcatMS/cloud-ansible-plays.git

mv cloud-ansible-plays/* /etc/ansible/

if [ ! -d "${HOME}/.aws" ]; then
    mkdir "${HOME}/.aws"
fi

cat <<EOF > "${HOME}"/.aws/configure
[default]
region = ${AWS_REGION}
EOF

cat <<EOF > "${HOME}"/.aws/credentials
[default]
aws_access_key_id = ${AWS_KEY}
aws_secret_access_key = ${AWS_SECRET}
EOF

chown ${SUDO_USER}:${SUDO_USER} -R ${HOME}

# This will be the line to execute Ansbile playbook, we are not passing any
# arguments to the play for simplicity
sudo -u ${SUDO_USER} ansible-playbook /etc/ansible/configure_cloudhealth_aws.yaml
