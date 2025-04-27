#!/bin/bash
# Script to test Kafka connectivity

# Get the LoadBalancer endpoint from the ConfigMap
EXTERNAL_BOOTSTRAP=$(kubectl get configmap -n kafka-ns kafka-endpoints -o jsonpath='{.data.external-bootstrap}')
INTERNAL_BOOTSTRAP=$(kubectl get configmap -n kafka-ns kafka-endpoints -o jsonpath='{.data.internal-bootstrap}')

echo "Kafka External Bootstrap: $EXTERNAL_BOOTSTRAP"
echo "Kafka Internal Bootstrap: $INTERNAL_BOOTSTRAP"

# Create a temporary pod to test the Kafka connection
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kafka-test-client
  namespace: kafka-ns
spec:
  containers:
  - name: kafka-client
    image: confluentinc/cp-kafka:7.5.0
    command:
      - /bin/sh
      - -c
      - "exec tail -f /dev/null"
    env:
      - name: KAFKA_OPTS
        value: "-Djava.security.auth.login.config=/tmp/jaas.conf"
    volumeMounts:
      - name: jaas-config
        mountPath: /tmp/jaas.conf
        subPath: jaas.conf
  volumes:
    - name: jaas-config
      configMap:
        name: kafka-client-jaas
        items:
          - key: jaas.conf
            path: jaas.conf
EOF

# Create a ConfigMap with the JAAS configuration for SASL/PLAIN authentication
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-client-jaas
  namespace: kafka-ns
data:
  jaas.conf: |
    KafkaClient {
      org.apache.kafka.common.security.plain.PlainLoginModule required
      username="user1"
      password="vErm3tFwNEcMqyDWEGxqkT";
    };
EOF

# Wait for the pod to be ready
echo "Waiting for the test pod to be ready..."
kubectl wait --for=condition=ready pod/kafka-test-client -n kafka-ns --timeout=60s

echo "Testing internal connection..."
kubectl exec -it -n kafka-ns kafka-test-client -- kafka-topics.sh \
  --bootstrap-server $INTERNAL_BOOTSTRAP \
  --list \
  --command-config /tmp/client.properties

echo "Testing external connection..."
# Create client properties for SASL authentication
kubectl exec -i -n kafka-ns kafka-test-client -- bash -c "cat > /tmp/client.properties << 'EOL'
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"user1\" password=\"vErm3tFwNEcMqyDWEGxqkT\";
EOL"

# Test listing topics
kubectl exec -it -n kafka-ns kafka-test-client -- kafka-topics.sh \
  --bootstrap-server $EXTERNAL_BOOTSTRAP \
  --list \
  --command-config /tmp/client.properties

# Test the ability to produce messages
echo "Testing message production to social-media-topic..."
kubectl exec -i -n kafka-ns kafka-test-client -- bash -c "echo 'Test message from external client' | kafka-console-producer.sh \
  --bootstrap-server $EXTERNAL_BOOTSTRAP \
  --topic social-media-topic \
  --producer.config /tmp/client.properties"

# Test the ability to consume messages
echo "Testing message consumption from social-media-topic..."
kubectl exec -it -n kafka-ns kafka-test-client -- timeout 10s kafka-console-consumer.sh \
  --bootstrap-server $EXTERNAL_BOOTSTRAP \
  --topic social-media-topic \
  --from-beginning \
  --max-messages 1 \
  --consumer.config /tmp/client.properties

# Clean up
echo "Cleaning up test resources..."
kubectl delete pod kafka-test-client -n kafka-ns
kubectl delete configmap kafka-client-jaas -n kafka-ns

echo "Kafka connectivity test completed"