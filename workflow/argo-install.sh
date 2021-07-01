#!/bin/bash

# Install argo workflow using helm

# @author: Fabrice Jammes, IN2P3
set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

NS=$(kubectl get sa -o=jsonpath='{.items[0].metadata.namespace}')

echo "Install Argo Workflow inside namespace $NS"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update
helm install --create-namespace --namespace "$NS" -f "$DIR/values.yaml" argo-workflows argo/argo-workflows --version 0.2.6

# cat <<EOF | kubectl apply -f -
# apiVersion: rbac.authorization.k8s.io/v1
# kind: RoleBinding
# metadata:
#   name: argo
#   namespace: $NS
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: edit
# subjects:
# - kind: ServiceAccount
#   name: argo-workflow
#   namespace: $NS
# EOF

echo "Add additional RBAC to  argo-workflow service account (manage jobs.batch)"
kubectl patch roles.rbac.authorization.k8s.io argo-workflows-workflow --type='json' \
    -p='[{"op": "add", "path": "/rules/-", "value": {"apiGroups": ["batch"],"resources": ["jobs"],"verbs": ["create", "get", "watch"]} }]'

kubectl wait --namespace "$NS" --for=condition=available --timeout=600s deployment argo-workflows-server argo-workflows-workflow-controller


argo submit -n "$NS" --serviceaccount=argo-workflow https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml --watch