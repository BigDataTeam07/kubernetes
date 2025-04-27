# Amazon Music Review Project - Cloud Native Structure

This document outlines the recommended project structure for the Amazon Music Review project using Helm charts for Kafka deployment on AWS EKS.

## Project Structure

```
Kubernetes/
├── aws-eks-cluster/              # EKS cluster configuration
│   ├── amazon-music-review-cluster.yaml
│   ├── deploy.sh
│   ├── ebs-storageclass.yaml
│   └── .env                      # AWS credentials and environment variables
│
├── kafka/                        # Kafka Helm deployment
│   ├── kafka-values.yaml         # Helm chart values for Bitnami Kafka
│   ├── deploy-kafka-helm.sh      # Script to deploy Kafka using Helm
│   ├── migrate-to-helm.sh        # Migration script from manual K8s to Helm
│   └── README.md                 # Documentation for Kafka deployment
│
├── services/                     # Application micro-services
│   ├── telegram-bot-listener/        # Telegram bot service
│   │   ├── Dockerfile
│   │   ├── build.gradle.kts
│   │   ├── src/
│   │   └── k8s/
│   │       └── telegram-bot-listener-deployment.yaml
|   │       └── telegram-bot-secret.yaml
│   │
│   ├── sentiment-analyzer/       # Sentiment analysis service
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   ├── src/
│   │   └── k8s/
│   │       └── sentiment-analyzer-deployment.yaml
│   │
│   └── recommendation-engine/    # Recommendation engine service
│       ├── Dockerfile
│       ├── requirements.txt
│       ├── src/
│       └── k8s/
│           └── recommendation-engine-deployment.yaml
│
├── visualization/                # ELK stack for visualization
│   ├── elasticsearch-deployment.yaml
│   ├── kibana-deployment.yaml
│   ├── kafka-connect-deployment.yaml
│   ├── elasticsearch-sink.json
│   └── deploy-elk-stack.sh
│
└── README.md                     # Main project documentation
```

## Key Components

1. **Kafka Helm Deployment (`kafka/`)**:

   - Contains Helm chart configuration for Bitnami Kafka
   - Scripts for deployment and migration
   - Documentation

2. **Application Services (`services/`)**:

   - Separate directories for each microservice, (the files are abstraction from the original project)
   - Each service contains its own Dockerfile and Kubernetes manifests
   - Services communicate via Kafka topics

3. **Infrastructure (`aws-eks-cluster/`)**:

   - EKS cluster configuration
   - Scripts for cluster setup and management

4. **Visualization (`visualization/`)**:
   - ELK stack for monitoring and visualization
   - Kafka Connect to bridge Kafka and Elasticsearch
     å

## Dependencies Between Components

- **Kafka → Services**: All services depend on Kafka for messaging
- **Services → Visualization**: Services produce data that's visualized by the ELK stackå
