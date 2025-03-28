#!/bin/bash

# Echo status
echo "Starting post_script.sh"

# Get the OpenAI API Key from Secrets Manager
OPENAI_API_KEY=$(aws secretsmanager get-secret-value \
  --secret-id OPENAI_API_KEY \
  --query SecretString \
  --output text)

# Login to ECR
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 471112585965.dkr.ecr.eu-central-1.amazonaws.com

# Pull the latest image
docker pull 471112585965.dkr.ecr.eu-central-1.amazonaws.com/python/flask_gpt_ec2:latest

# Stop and remove old container if it exists
docker stop flask_gpt || true
docker rm flask_gpt || true

# Run the new container with the secret injected as an env variable
docker run -d \
  --name flask_gpt \
  -p 5001:5001 \
  -e OPENAI_API_KEY="$OPENAI_API_KEY" \
  471112585965.dkr.ecr.eu-central-1.amazonaws.com/python/flask_gpt_ec2:latest
