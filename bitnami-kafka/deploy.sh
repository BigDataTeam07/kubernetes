#!/bin/bash

# Create the namespace first
kubectl apply -f kafka-namespace.yaml
echo "Created Kafka namespace"

# Create the services
kubectl apply -f kafka-service.yaml
echo "Created Kafka services"

# Deploy the Kafka StatefulSet
kubectl apply -f kafka-statefulset.yaml
echo "Deployed Kafka StatefulSet"

# Wait for the Kafka pod to be ready
echo "Waiting for Kafka pod to be ready..."
kubectl wait --for=condition=ready pod/bitnami-kafka-0 -n kafka-ns --timeout=300s

# Create the topics
kubectl apply -f kafka-topic-creation-job.yaml
echo "Applied topic creation job"

# Wait for the job to complete
echo "Waiting for topic creation job to complete..."
kubectl wait --for=condition=complete job/kafka-topic-creation -n kafka-ns --timeout=180s

# List the topics
echo "Listing created topics:"
kubectl exec -it bitnami-kafka-0 -n kafka-ns -- kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --list

echo "Kafka deployment complete!"