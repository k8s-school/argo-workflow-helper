#!/bin/bash

# Install operator-lifecycle-manager inside k8s

# @author Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR/conf.sh"
. "$DIR/include.sh"


ARGO_OPERATOR_VERSION="v0.6.0"
echo "Install ArgoCD Operator $ARGO_OPERATOR_VERSION"

GITHUB_URL="https://raw.githubusercontent.com/argoproj-labs/argocd-operator/$ARGO_OPERATOR_VERSION"
kubectl apply -n olm -f "$GITHUB_URL/deploy/catalog_source.yaml"
kubectl get catalogsources -n olm argocd-catalog
kubectl get pods -n olm -l olm.catalogSource=argocd-catalog

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f "$GITHUB_URL/deploy/operator_group.yaml"
kubectl get operatorgroups -n argocd
kubectl apply -n argocd -f "$GITHUB_URL/deploy/subscription.yaml"
kubectl get subscriptions -n argocd argocd-operator
kubectl get installplans -n argocd

echo "Wait for ArgoCD Operator to be ready"
kubectl rollout status deployment/argocd-operator --timeout=120s -n argocd
kubectl get pods -n argocd -l name=argocd-operator

echo "Install ArgoCD $ARGOCD_VERSION"
kubectl apply -n argocd -f "$GITHUB_URL/examples/argocd-basic.yaml"

# !!! TODO look for error below
kubectl describe -n olm catalogsources.operators.coreos.com argocd-catalog
