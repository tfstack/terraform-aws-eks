#!/bin/bash
set -euo pipefail

# Standard EKS bootstrap for self-managed nodes using EKS-optimized AMI
# Assumes the AMI provides /etc/eks/bootstrap.sh

CLUSTER_NAME="${cluster_name}"
API_SERVER_ENDPOINT="${cluster_endpoint}"
B64_CLUSTER_CA="${cluster_ca_certificate}"

# Optional: add extra kubelet args via KUBELET_EXTRA_ARGS env var if needed
# Example:
# KUBELET_EXTRA_ARGS='--node-labels=node.kubernetes.io/role=worker' \
#   /etc/eks/bootstrap.sh "$CLUSTER_NAME" \
#   --apiserver-endpoint "$API_SERVER_ENDPOINT" \
#   --b64-cluster-ca "$B64_CLUSTER_CA"

/etc/eks/bootstrap.sh "$CLUSTER_NAME" \
  --apiserver-endpoint "$API_SERVER_ENDPOINT" \
  --b64-cluster-ca "$B64_CLUSTER_CA"
