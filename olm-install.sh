#!/bin/bash

# Install operator-lifecycle-manager inside k8s

# @author Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/conf.sh"
. "$DIR/include.sh"

echo "Install operator-lifecycle-manager $OLM_VERSION"

curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$OLM_VERSION/install.sh -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh "$OLM_VERSION"

echo "Wait for operator-lifecycle-manager to be ready"
kubectl rollout status deployment/olm-operator --timeout=120s -n olm