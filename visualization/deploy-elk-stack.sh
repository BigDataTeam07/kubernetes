#!/bin/bash

# Deploy Elasticsearch
kubectl apply -f elasticsearch-deployment.yaml
echo "Deploying Elasticsearch..."
sleep 10

# Check if Elasticsearch is running
echo "Checking Elasticsearch deployment status..."
kubectl get pods -n amazon-music-review -l app=elasticsearch
echo "Waiting for Elasticsearch to be ready..."
kubectl wait --for=condition=ready pod -l app=elasticsearch -n amazon-music-review --timeout=180s

# Deploy Kibana
kubectl apply -f kibana-deployment.yaml
echo "Deploying Kibana..."
sleep 10

# Check if Kibana is running
echo "Checking Kibana deployment status..."
kubectl get pods -n amazon-music-review -l app=kibana
echo "Waiting for Kibana to be ready..."
kubectl wait --for=condition=ready pod -l app=kibana -n amazon-music-review --timeout=180s

# Create the connector configuration ConfigMap
kubectl create configmap -n amazon-music-review elasticsearch-sink-config --from-file=elasticsearch-sink.json
echo "Created Elasticsearch sink connector configuration..."

# Deploy Kafka Connect
kubectl apply -f kafka-connect-deployment.yaml
echo "Deploying Kafka Connect..."
sleep 10

# Check if Kafka Connect is running
echo "Checking Kafka Connect deployment status..."
kubectl get pods -n amazon-music-review -l app=kafka-connect
echo "Waiting for Kafka Connect to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka-connect -n amazon-music-review --timeout=180s

# Port-forward Kibana to access it locally
echo "Setting up port-forward for Kibana on port 5601..."
kubectl port-forward -n amazon-music-review svc/kibana-service 5601:5601 &

echo "ELK stack deployment completed."
echo "You can access Kibana at http://localhost:5601"
