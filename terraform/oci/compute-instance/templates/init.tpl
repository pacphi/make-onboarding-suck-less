#!/bin/bash

cp /home/ubuntu/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys.bak
echo "${ssh_public_key}" >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu /home/ubuntu/.ssh/authorized_keys

mkdir -p /home/ubuntu/.oci

echo '
[DEFAULT]
user=${user_ocid}
fingerprint=${fingerprint}
key_file=/home/ubuntu/.oci/oci_api_key.pem
tenancy=${tenancy_ocid}
region=${region}
' >> /home/ubuntu/.oci/config

echo '
${oci_pk_file_contents}
' >> /home/ubuntu/.oci/oci_api_key.pem

chown -R ubuntu:ubuntu /home/ubuntu/.oci
chmod 600 /home/ubuntu/.oci/*
