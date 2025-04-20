
kubectl apply -f kafka-config.yaml
kubectl apply -f kafka-pvc.yaml
kubectl apply -f kafka-statefulset.yaml
kubectl apply -f kafka-service.yaml