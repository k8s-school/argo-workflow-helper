#!/bin/bash

# @author: Fabrice Jammes, IN2P3
set -euxo pipefail

echo "Install Argo Workflow inside k8s"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update
helm install argo-workflows argo/argo-workflows --version 0.2.6

kubectl wait --for=condition=available --timeout=600s deployment argo-workflows-server argo-workflows-workflow-controller
