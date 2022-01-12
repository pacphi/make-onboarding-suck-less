#!/usr/bin/env bash

# Install Oracle CLI
mkdir -p ~/development/python && cd ~/development/python
python3 -m venv oracle-cli
. ./oracle-cli/bin/activate
curl -L "https://github.com/oracle/oci-cli/releases/download/v${OCI_VERSION}/oci-cli-${OCI_VERSION}.zip" -o /tmp/oci-cli-${OCI_VERSION}.zip
cd /tmp
unzip oci-cli-${OCI_VERSION}.zip
pip install /tmp/oci-cli/oci_cli-${OCI_VERSION}-py3-none-any.whl
echo "alias activate-oci='mkdir -p ~/development/python && cd ~/development/python && python3 -m venv oracle-cli && . ./oracle-cli/bin/activate'" >> ~/.bashrc
