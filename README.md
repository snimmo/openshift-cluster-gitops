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