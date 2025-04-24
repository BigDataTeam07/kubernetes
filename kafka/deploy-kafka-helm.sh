#!/bin/bash
# Script to deploy Bitnami Kafka using Helm chart

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

# Apply the StorageClass if it doesn't exist
echo "Applying EBS StorageClass..."
kubectl apply -f ../aws-eks-cluster/ebs-storageclass.yaml 2>/dev/null || echo "StorageClass already exists or path is incorrect"

# Install or upgrade Kafka using Helm
echo "Deploying Kafka using Helm chart..."
helm upgrade --install bitnami-kafka bitnami/kafka \
  --namespace kafka-ns \
  --values kafka-values.yaml \
  --timeout 10m \
  --wait

# Wait for the Kafka pod to be ready
echo "Waiting for Kafka pod to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka -n kafka-ns --timeout=300s

# Sleep to give Kafka time to fully initialize
echo "Giving Kafka time to fully initialize..."
sleep 30

# Verify the installation by listing topics
echo "Verifying Kafka installation by listing topics..."
# Determine the first Kafka pod name
KAFKA_POD=$(kubectl get pods -n kafka-ns -l app.kubernetes.io/name=kafka -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $KAFKA_POD -n kafka-ns -- kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --list

# Display connection information
echo -e "\n========== Kafka Deployment Information =========="
echo "Deployment Status: SUCCESS"
echo "Kafka Bootstrap Server (internal): bitnami-kafka.kafka-ns.svc.cluster.local:9092"
echo "Use this connection string in your applications"
echo "===================================================="