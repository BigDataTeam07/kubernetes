kubectl apply -f kafka-namespace.yaml
# pause for 5 seconds to allow the namespace to be created
echo "Waiting for 5 seconds to allow the namespace to be created..."
sleep 5
kubectl apply -f kafka-config.yaml
kubectl apply -f kafka-pvc.yaml
kubectl apply -f kafka-statefulset.yaml
kubectl apply -f kafka-service.yaml