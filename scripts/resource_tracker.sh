#!/bin/bash
#################################################################
# Author: Rakesh Jha
# Date: July 2026
# Version: v1.1
# Description: Tracks AWS resource usage and sends data to a
#              decoupled API Gateway backend via GitHub Actions.
#################################################################

set -e # Exit immediately if a command exits with a non-zero status

# ---- CONFIGURATION ----
# Pulls the URL securely from the GitHub Actions environment secret
API_URL="${AWS_TRACKER_API_URL}" 
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "===================================================="
echo " Starting AWS Resource Tracking: $TIMESTAMP"
echo "===================================================="

# Sanity check to prevent empty payload dispatches
if [ -z "$API_URL" ]; then
    echo "ERROR: AWS_TRACKER_API_URL environment variable is missing."
    echo "Please ensure the secret is set up in your repository."
    exit 1
fi

# ---- DATA GATHERING ----

echo "Fetching EC2 Instances..."
EC2_DATA=$(aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,State:State.Name,LaunchTime:LaunchTime}" \
    --output json)

echo "Fetching S3 Buckets..."
S3_DATA=$(aws s3api list-buckets \
    --query "Buckets[*].{Name:Name,CreationDate:CreationDate}" \
    --output json)

echo "Fetching Lambda Functions..."
LAMBDA_DATA=$(aws lambda list-functions \
    --query "Functions[*].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified}" \
    --output json)

echo "Fetching IAM Users..."
IAM_DATA=$(aws iam list-users \
    --query "Users[*].{UserName:UserName,UserId:UserId,CreateDate:CreateDate}" \
    --output json)

# ---- PACKAGING PAYLOAD ----

echo "Packaging telemetry dataset into JSON format..."
# Combine all variables into a single clean JSON schema structure using jq
PAYLOAD=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --argjson ec2 "$EC2_DATA" \
    --argjson s3 "$S3_DATA" \
    --argjson lambda "$LAMBDA_DATA" \
    --argjson iam "$IAM_DATA" \
    '{timestamp: $ts, ec2: $ec2, s3: $s3, lambda: $lambda, iam: $iam}')

# ---- SENDING DATA ----
echo "Sending payload to API Gateway endpoint..."

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    "$API_URL")

if [ "$RESPONSE" -eq 200 ] || [ "$RESPONSE" -eq 201 ]; then
    echo "SUCCESS: Data successfully uploaded to dashboard backend (HTTP $RESPONSE)."
else
    echo "ERROR: Failed to upload data (HTTP $RESPONSE)."
    exit 1
fi

echo "===================================================="
echo " Resource Tracking Completed Successfully."
echo "===================================================="
