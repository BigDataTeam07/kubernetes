#!/bin/bash

# Exit on error
set -e

NAMESPACE="amazon-music-review"

echo "Checking Kafka Connect status..."
kubectl get pods -n $NAMESPACE -l app=kafka-connect

echo "Applying fixed Kafka Connect configuration..."
kubectl apply -f kafka-connect-deployment-fixed.yaml

echo "Waiting for deployment to complete..."
kubectl rollout status deployment/kafka-connect -n $NAMESPACE

echo "Verifying that Kafka Connect is running correctly..."
kubectl get pods -n $NAMESPACE -l app=kafka-connect

echo "Checking logs for Kafka Connect..."
POD_NAME=$(kubectl get pods -n $NAMESPACE -l app=kafka-connect -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n $NAMESPACE $POD_NAME

echo "Checking if connector is registered..."
kubectl exec -n $NAMESPACE $POD_NAME -- curl -s http://localhost:8083/connectors

echo "Creating Kafka topics if they don't exist yet..."
KAFKA_POD=$(kubectl get pods -n $NAMESPACE -l app=amazon-music-review-kafka -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n $NAMESPACE $KAFKA_POD -- /opt/kafka/bin/kafka-topics.sh --create --if-not-exists --topic music-reviews-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092
kubectl exec -n $NAMESPACE $KAFKA_POD -- /opt/kafka/bin/kafka-topics.sh --create --if-not-exists --topic social-media-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092
kubectl exec -n $NAMESPACE $KAFKA_POD -- /opt/kafka/bin/kafka-topics.sh --create --if-not-exists --topic user-input-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092
kubectl exec -n $NAMESPACE $KAFKA_POD -- /opt/kafka/bin/kafka-topics.sh --create --if-not-exists --topic recommendations-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

echo "Verify topics created:"
kubectl exec -n $NAMESPACE $KAFKA_POD -- /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

echo "Kafka Connect setup complete."
