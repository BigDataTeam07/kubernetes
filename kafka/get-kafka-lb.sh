#!/bin/bash
# Script to get Kafka LoadBalancer details and create ConfigMap

# Check if Kafka service exists
if ! kubectl get svc -n kafka-ns bitnami-kafka >/dev/null 2>&1; then
  echo "Error: Kafka service not found. Make sure Kafka is deployed."
  exit 1
fi

# Get the LoadBalancer hostname/IP
LOADBALANCER_HOSTNAME=$(kubectl get svc -n kafka-ns bitnami-kafka -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
LOADBALANCER_IP=$(kubectl get svc -n kafka-ns bitnami-kafka -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Use hostname if available, otherwise use IP
if [ -n "$LOADBALANCER_HOSTNAME" ]; then
  LOADBALANCER_ENDPOINT=$LOADBALANCER_HOSTNAME
elif [ -n "$LOADBALANCER_IP" ]; then
  LOADBALANCER_ENDPOINT=$LOADBALANCER_IP
else
  echo "LoadBalancer endpoint not yet assigned. This may take a few minutes."
  echo "Run this script again later or check with: kubectl get svc -n kafka-ns bitnami-kafka"
  exit 0
fi

# Get the port
LOADBALANCER_PORT=$(kubectl get svc -n kafka-ns bitnami-kafka -o jsonpath='{.spec.ports[?(@.name=="client")].port}')

# Create an endpoint string
KAFKA_EXTERNAL_ENDPOINT="${LOADBALANCER_ENDPOINT}:${LOADBALANCER_PORT}"

echo "Kafka LoadBalancer Endpoint: $KAFKA_EXTERNAL_ENDPOINT"

# Create/update ConfigMap with endpoints
echo "Creating ConfigMap with Kafka endpoints..."
kubectl create configmap -n kafka-ns kafka-endpoints \
  --from-literal=internal-bootstrap=bitnami-kafka.kafka-ns.svc.cluster.local:9092 \
  --from-literal=external-bootstrap=${KAFKA_EXTERNAL_ENDPOINT} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "ConfigMap 'kafka-endpoints' created in namespace 'kafka-ns'"
echo ""
echo "You can use this endpoint in your applications to connect to Kafka"
echo "SASL/PLAIN authentication is required with username: user1"