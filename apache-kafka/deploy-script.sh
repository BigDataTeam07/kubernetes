# Apply only the namespace first
kubectl apply -f kraft-namespace.yaml

# Wait a moment for the namespace to be fully created
sleep 2

# Then apply all resources again (which will skip the already-created namespace)
kubectl apply -f .