kubectl apply -f kafka-namespace.yaml
# pause for 5 seconds to allow the namespace to be created
echo "Waiting for 5 seconds to allow the namespace to be created..."
sleep 5
kubectl apply -f kafka-config.yaml
kubectl apply -f kafka-pvc.yaml
kubectl apply -f kafka-statefulset.yaml
kubectl apply -f kafka-service.yaml

echo "Kafka deployment completed."
# # to create topics, use the following commands to create topics
# kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-topics.sh --create --topic music-reviews-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

# kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-topics.sh --create --topic social-media-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

# kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-topics.sh --create --topic user-input-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

# kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-topics.sh --create --topic recommendations-topic --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092

# Verify the topics
# kubectl exec -it amazon-music-review-kafka-0 -n amazon-music-review -- /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092