#!/bin/bash
# filepath: /Users/workspace/Developer/big-data-iss-practice-module/k8s/amazon/deploy.sh

# Load environment variables from .env file (use set -a to export all variables)
set -a
source .env
set +a

# Check if AWS_ACCOUNT_ID and AWS_EC2_KEY are set
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_EC2_KEY" ]; then
    echo "Error: AWS_ACCOUNT_ID or AWS_EC2_KEY is not set in the .env file."
    exit 1
fi

# Process the template
envsubst < amazon-music-review-cluster.yaml > processed-cluster.yaml


# Create the cluster
eksctl create cluster -f processed-cluster.yaml