#!/bin/bash

# Test argo workflow

# @author: Fabrice Jammes, IN2P3
set -euxo pipefail

argo submit -n "$NS" --serviceaccount=argo-workflow \
  https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml --watch