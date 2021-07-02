# argoproj-helper

Helper to install and run argo-workflow

Based on helm chart: https://github.com/argoproj/argo-helm

## Pre-requisites

Access to an up and running Kubernetes cluster.

## Install argo workflow

```
git clone https://github.com/k8s-school/argoproj-helper.git
./argoproj-helper/workflow/install.sh
```

## Install argo client

```
./argoproj-helper/argo-client-install.sh
argo --help
```
