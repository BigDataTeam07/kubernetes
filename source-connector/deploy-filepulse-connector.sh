#!/bin/bash

# Exit on error
set -e

echo "=== Deploying File Pulse Connector for Amazon Music Reviews ==="

# Step 1: Apply the File Pulse connector ConfigMap
echo "Creating File Pulse connector configuration..."
kubectl apply -f filepulse-connector-config.yaml

# Step 2: Check if Kafka Connect is already deployed
if kubectl get deployment -n amazon-music-review amazon-music-review-kafka-connect &>/dev/null; then
  echo "Kafka Connect deployment already exists. Updating..."
  kubectl apply -f kafka-connect-filepulse-deployment.yaml
else
  echo "Creating Kafka Connect deployment with File Pulse connector..."
  # Ensure we have the PVC for Kafka Connect
  if ! kubectl get pvc -n amazon-music-review amazon-music-review-kafka-connect-data &>/dev/null; then
    echo "Creating Kafka Connect PVC..."
    kubectl apply -f kafka-connect-pvc.yaml
  fi
  
  # Create the Kafka Connect config if it doesn't exist
  if ! kubectl get configmap -n amazon-music-review amazon-music-review-kafka-connect-config &>/dev/null; then
    echo "Creating Kafka Connect config..."
    kubectl apply -f kafka-connect-config.yaml
  fi
  
  # Deploy Kafka Connect
  kubectl apply -f kafka-connect-filepulse-deployment.yaml
fi

echo "Waiting for Kafka Connect deployment to be ready..."
kubectl rollout status deployment/amazon-music-review-kafka-connect -n amazon-music-review --timeout=180s

# Step 3: Get the Kafka Connect pod name
KAFKA_CONNECT_POD=$(kubectl get pods -n amazon-music-review -l app=amazon-music-review-kafka-connect -o jsonpath='{.items[0].metadata.name}')

# Step 4: Verify the connector is installed
echo "Verifying that the File Pulse connector is installed..."
kubectl exec -n amazon-music-review $KAFKA_CONNECT_POD -- curl -s http://localhost:8083/connector-plugins | grep FilePulseSourceConnector

# Step 5: Verify the connector is running
echo "Checking the status of the File Pulse connector..."
kubectl exec -n amazon-music-review $KAFKA_CONNECT_POD -- curl -s http://localhost:8083/connectors/music-review-filepulse-source/status

echo "=== File Pulse Connector Deployment Complete ==="
echo "The connector is now set up to monitor the /app/data directory for Avro files"
echo "and send them to the music-reviews-topic Kafka topic."
echo ""
echo "To copy Avro files to the Kafka Connect pod, use:"
echo "./copy-avro-files.sh <local_avro_directory>"
echo ""
echo "To check the connector status, use:"
echo "kubectl exec -n amazon-music-review $KAFKA_CONNECT_POD -- curl -s http://localhost:8083/connectors/music-review-filepulse-source/status"
echo ""
echo "To check if messages are being sent to the topic, use:"
echo "kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic music-reviews-topic --from-beginning --max-messages 5"
