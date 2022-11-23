#!/bin/bash

# use your private docker account https://hub.docker.com to prevent rate limit issues
REGISTRY_NAME=docker.io
REGISTRY_USER=your-docker-user-name
#REGISTRY_PASS=your-docker-password

NAMESPACE=kubernetes-dashboard
HELM_VALUES=./kubernetes-dashboard-helm-values.yaml

echo "Installing Kubernetes Dashboard"

if [ -z $REGISTRY_PASS ]
then
  echo "You need to specify your registry password in the REGISTRY_PASS environment variable"
  exit 1
fi

kubectl create ns $NAMESPACE

# workaround for docker rate limit
kubectl -n $NAMESPACE create secret docker-registry tdh-docker-repo \
            --docker-server $REGISTRY_NAME \
            --docker-username $REGISTRY_USER \
            --docker-password $REGISTRY_PASS

# request a self signed certificate
kubectl apply -f ./kubernetes-dashboard-cert.yaml

# sources for dashboard deployment:
#   - https://github.com/kubernetes/dashboard pointing to 
#     - https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard

# add the repo 
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

# install with custom values
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace $NAMESPACE -f $HELM_VALUES --wait --wait-for-jobs

# deploy the contour proxy
kubectl apply -f ./kubernetes-dashboard-proxy.yaml
sleep 2

# configure the service account
kubectl apply -f ./kubernetes-dashboard-sa.yaml
kubectl apply -f ./kubernetes-dashboard-rbac.yaml

# display the DNS name for the dashboard
echo "Use the following DNS name to connect to the Kubernetes Dashboard:"
kubectl get httpproxy -n kubernetes-dashboard

# display the access token
TOKEN=$(kubectl -n $NAMESPACE get secret $(kubectl -n $NAMESPACE get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
echo "Kubernetes Dashboard Token:"
echo $TOKEN

exit 0
