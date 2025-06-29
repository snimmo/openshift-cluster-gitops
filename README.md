# openshift-cluster-gitops

Login 
```shell
oc login --server=https://api.ocp.lab.snimmo.com:6443 -u kubeadmin -p <password>
```

Install GitOps
```shell 
./install-openshift-gitops.sh
```

Add Credentials for GitHub Repository
```shell
oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: github-snimmo-openshift-cluster-gitops-credentials
  namespace: cluster-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  url: https://github.com/snimmo/openshift-cluster-gitops.git
  username: <username>
  password: <github-token>
  name: github-snimmo-openshift-cluster-gitops
  project: cluster
EOF
```

Create Secret for Vault Token
```shell 
oc create secret generic vault-token -n openshift-config --from-literal=token=<token>
```

Create App-of-Apps for cluster-gitops
```shell
oc apply -f cluster-app-of-apps.yaml
```


## Debugging

```
kustomize build cluster-gitops
kustomize build operators
kustomize build storage
```

```
oc rollout restart deployment cluster-gitops-server -n cluster-gitops
oc rollout restart deployment cluster-gitops-repo-server -n cluster-gitops
```

```
oc delete project openshift-gitops
oc delete project openshift-gitops-operator
oc get crds -o name | grep '\.argoproj\.io' | xargs oc delete
```

## Helpful Link

https://github.com/argoproj/argo-cd/issues/5886#issuecomment-982674357

```
oc get packagemanifests -n openshift-marketplace | grep <searchterm>
oc describe packagemanifests -n openshift-marketplace <operator-name>
```

```
apiVersion: argoproj.io/v1alpha1
kind: Application
spec:
  syncPolicy:
    syncOptions:
    - SkipDryRunOnMissingResource=true
```

```
metadata:
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
```

