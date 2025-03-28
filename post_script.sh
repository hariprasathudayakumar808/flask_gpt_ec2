#!/bin/bash

echo "Starting deployment..."

# Pull OpenAI key from Secrets Manager
OPENAI_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id OPENAI_API_KEY \
  --query SecretString \
  --output text)

# Log in to ECR (non-TTY safe)
aws ecr get-login-password --region eu-central-1 | \
docker login --username AWS --password-stdin 471112585965.dkr.ecr.eu-central-1.amazonaws.com

# Stop & remove existing container
docker stop flask_gpt || true
docker rm flask_gpt || true

# Pull image
docker pull 471112585965.dkr.ecr.eu-central-1.amazonaws.com/python/flask_gpt_ec2:latest

# Run container with secret injected
docker run -d \
  --name flask_gpt \
  -p 5001:5001 \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  471112585965.dkr.ecr.eu-central-1.amazonaws.com/python/flask_gpt_ec2:latest
