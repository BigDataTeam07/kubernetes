#!/bin/bash

# Check for input directory
if [ -z "$1" ]; then
  echo "Error: No Avro directory specified"
  echo "Usage: $0 <local_avro_directory>"
  exit 1
fi

# Get the name of the Kafka Connect pod
KAFKA_CONNECT_POD=$(kubectl get pods -n amazon-music-review -l app=amazon-music-review-kafka-connect -o jsonpath='{.items[0].metadata.name}')

if [ -z "$KAFKA_CONNECT_POD" ]; then
  echo "Error: Kafka Connect pod not found"
  exit 1
fi

# Check if the local avro directory exists
if [ ! -d "$1" ]; then
  echo "Error: Local Avro directory not found: $1"
  echo "Usage: $0 <local_avro_directory>"
  exit 1
fi

echo "Copying Avro files from $1 to Kafka Connect pod $KAFKA_CONNECT_POD..."

# Create the data directory in the pod if it doesn't exist
kubectl exec -n amazon-music-review $KAFKA_CONNECT_POD -- mkdir -p /app/data /app/data/processed /app/data/error

# Copy all Avro files to the pod
for FILE in $1/*.avro; do
  if [ -f "$FILE" ]; then
    FILENAME=$(basename $FILE)
    echo "Copying $FILENAME..."
    kubectl cp $FILE amazon-music-review/$KAFKA_CONNECT_POD:/app/data/$FILENAME
  fi
done

echo "Files copied successfully. The File Pulse connector should now process these files."
echo "To check the connector status, use:"
echo "kubectl exec -n amazon-music-review $KAFKA_CONNECT_POD -- curl -s http://localhost:8083/connectors/music-review-filepulse-source/status"

echo "To verify that messages are being sent to the topic, use:"
echo "kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic music-reviews-topic --from-beginning --max-messages 5"

# Check the logs to see if the connector is processing files
echo ""
echo "Checking the Kafka Connect logs for file processing activity..."
kubectl logs -n amazon-music-review $KAFKA_CONNECT_POD | grep -i "filepulse" | tail -20
