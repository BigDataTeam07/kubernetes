#!/bin/bash
# Get the LoadBalancer URL
echo "Getting Jenkins URL..."
JENKINS_URL=$(kubectl -n jenkins get svc jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "Jenkins deployed successfully!"
echo "Access Jenkins at: http://${JENKINS_URL}:8080"
echo ""
echo "To get the initial admin password, run:"
echo "kubectl -n jenkins exec \$(kubectl -n jenkins get pods -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -- cat /var/jenkins_home/secrets/initialAdminPassword"
