#!/bin/bash
# Simple script to deploy Bitnami Kafka using Helm chart with LoadBalancer exposure

set -e  # Exit immediately if a command exits with a non-zero status

# Create namespace if it doesn't exist
echo "Creating Kafka namespace..."
kubectl create namespace kafka-ns --dry-run=client -o yaml | kubectl apply -f -

# Add the Bitnami Helm repo if it's not already added
if ! helm repo list | grep -q "bitnami"; then
  echo "Adding Bitnami Helm repository..."
  helm repo add bitnami https://charts.bitnami.com/bitnami
else
  echo "Bitnami Helm repository already exists"
fi

# Update Helm repos to get the latest charts
echo "Updating Helm repositories..."
helm repo update

# Check if Kafka is already deployed
if helm list -n kafka-ns | grep -q "bitnami-kafka"; then
  echo "Uninstalling existing Kafka deployment..."
  helm uninstall bitnami-kafka -n kafka-ns
  
  echo "Waiting for resources to be deleted..."
  sleep 20
fi

# Install Kafka using Helm
echo "Installing Kafka using Helm chart..."
helm install bitnami-kafka bitnami/kafka \
  --namespace kafka-ns \
  --values kafka-values.yaml \
  --timeout 10m \
  --debug \
  --wait

echo "Deployment initiated. Check status with:"
echo "kubectl get pods -n kafka-ns"
echo "kubectl get svc -n kafka-ns"