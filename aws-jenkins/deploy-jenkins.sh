#!/bin/bash

# Apply Jenkins resources to Kubernetes
echo "Creating Jenkins namespace..."
kubectl apply -f jenkins-namespace.yaml

echo "Creating Jenkins RBAC resources..."
kubectl apply -f jenkins-rbac.yaml

echo "Creating Jenkins PVC..."
kubectl apply -f jenkins-pvc.yaml

echo "Creating Jenkins deployment..."
kubectl apply -f jenkins-deployment.yaml

echo "Creating Jenkins service..."
kubectl apply -f jenkins-service.yaml

echo "Waiting for Jenkins pod to be ready..."
kubectl -n jenkins wait --for=condition=ready pod -l app=jenkins --timeout=300s

# Get the LoadBalancer URL
echo "Getting Jenkins URL..."
JENKINS_URL=$(kubectl -n jenkins get svc jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Jenkins deployed successfully!"
echo "Access Jenkins at: http://${JENKINS_URL}:8080"
echo ""
echo "To get the initial admin password, run:"
echo "kubectl -n jenkins exec \$(kubectl -n jenkins get pods -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword"
