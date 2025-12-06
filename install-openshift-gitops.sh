#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
set -euo pipefail

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1 ${@:2}"
}

log "[INFO] Applying OpenShift GitOps operator subscription manifests..."
oc apply -k openshift-gitops-operator

echo -n "[INFO] Waiting for the OpenShift GitOps Operator to be available..."
until oc wait --for=condition=Available --timeout=300s deployment/openshift-gitops-operator-controller-manager -n openshift-gitops-operator >/dev/null 2>&1; do
  echo -n "."
  sleep 30
done
echo ""
log "[INFO] OpenShift GitOps Operator is now available."

log "[INFO] Applying OpenShift GitOps instance openshift-gitops-cluster manifests..."
oc apply -k openshift-gitops-cluster

echo -n "[INFO] Waiting for deployment/openshift-gitops-cluster-server to be created..."
until oc get deployment openshift-gitops-cluster-server -n openshift-gitops-cluster >/dev/null 2>&1; do
  echo -n "."
  sleep 30
done
echo ""  # Print a newline when done
log "[INFO] deployment/openshift-gitops-cluster-server is now created."

# Verify ArgoCD is running
log "[INFO] Waiting for deployment/openshift-gitops-cluster-server to be ready..."
oc wait --for=condition=Available --timeout=300s deployment/openshift-gitops-cluster-server -n openshift-gitops-cluster
log "[INFO] OpenShift GitOps successfully installed in openshift-gitops-cluster."

ARGOCD_ROUTE=$(oc get route openshift-gitops-cluster-server -n openshift-gitops-cluster -o jsonpath='{.spec.host}')
log "[INFO] Cluster Argo CD is accessible at: https://$ARGOCD_ROUTE"
