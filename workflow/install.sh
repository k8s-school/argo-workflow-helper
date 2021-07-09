#!/bin/bash

# Install argo workflow using helm

# @author: Fabrice Jammes, IN2P3
set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
  cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h          this message
    -j          Add RBAC to argo-workflow service account so that it can manage Jobs.batch object

  Install argo workflow using helm

EOD
}

rbac_job=false

# get the options
while getopts hj c ; do
    case $c in
	    h) usage ; exit 0 ;;
	    j) rbac_job=true ;;
	    \?) usage ; exit 2 ;;
    esac
done
shift `expr $OPTIND - 1`

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi


NS=$(kubectl get sa -o=jsonpath='{.items[0].metadata.namespace}')

echo "Install Argo Workflow inside current namespace ($NS)"
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update
helm install --namespace "$NS" -f "$DIR/values.yaml" argo-workflows argo/argo-workflows --version 0.2.6

# -- Example: Grant all RBAC to argo service account
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

if [ $rbac_job = true ]
then
  echo "Add additional RBAC to argo-workflow service account (manage jobs.batch)"
  kubectl patch roles.rbac.authorization.k8s.io argo-workflows-workflow --type='json' \
    -p='[{"op": "add", "path": "/rules/-", "value": {"apiGroups": ["batch"],"resources": ["jobs"],"verbs": ["create", "get", "watch"]} }]'
fi

kubectl wait --namespace "$NS" --for=condition=available --timeout=600s deployment argo-workflows-server argo-workflows-workflow-controller
