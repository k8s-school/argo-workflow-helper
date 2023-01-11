#!/bin/bash

# Install argo client

# @author Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/conf.sh"
. "$DIR/include.sh"

readonly argo_bin="/usr/local/bin/argo"

echo "Install Argo client $ARGO_CLIENT_VERSION"

# If argo client exists, compare current version to desired one: kind version | awk '{print $2}'
if [ -e "$argo_bin" ]; then
    current_argo_version="$(argo version --short |  awk '{print $2}')"
    if [ "$current_argo_version" == "$ARGO_CLIENT_VERSION" ]; then
        warning "argo client "$ARGO_CLIENT_VERSION" is already installed"
        exit 0
    fi
fi

curl --create-dirs --output-dir /tmp/ -sLO https://github.com/argoproj/argo-workflows/releases/download/$ARGO_CLIENT_VERSION/argo-linux-amd64.gz
gunzip /tmp/argo-linux-amd64.gz
chmod +x /tmp/argo-linux-amd64

if [ "$(id -u)" -ne 0 ]
then
  sudo mv /tmp/argo-linux-amd64 /usr/local/bin/argo	
else
  mv /tmp/argo-linux-amd64 /usr/local/bin/argo
fi
