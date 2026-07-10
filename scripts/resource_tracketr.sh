#!/bin/bash
#################################################################
# Author: Rakesh Jha
# Date: July 2026
# Version: v2.0 (Grafana Integration)
# Description: Gathers AWS metrics and streams logs to Loki.
#################################################################
set -e # Terminate script execution immediately if any command fails

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
UNIX_NANO=$(date +%s%N)

echo "========================================="
echo " Starting AWS Audit Execution: $TIMESTAMP"
echo "========================================="

# ---- TELEMETRY INVENTORY COMPILATION ----
echo "Auditing compute infrastructure..."
EC2_COUNT=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text | wc -w)

echo "Auditing cloud object storage..."
S3_COUNT=$(aws s3api list-buckets --query "Buckets[*].Name" --output text | wc -w)

echo "Auditing serverless functions..."
LAMBDA_COUNT=$(aws lambda list-functions --query "Functions[*].FunctionName" --output text | wc -w)

echo "Auditing identity management layer..."
IAM_COUNT=$(aws iam list-users --query "Users[*].UserName" --output text | wc -w)

# ---- PACKAGING LOGQL STREAM PAYLOAD ----
# Loki strictly requires log fields to be strings paired with a nanosecond timestamp
PAYLOAD=$(jq -n \
  --arg nano "$UNIX_NANO" \
  --arg ec2 "$EC2_COUNT" \
  --arg s3 "$S3_COUNT" \
  --arg lam "$LAMBDA_COUNT" \
  --arg iam "$IAM_COUNT" \
  '{
    streams: [{
      stream: { job: "aws-resource-tracker", env: "production" },
      values: [[ $nano, "{\"ec2\": \($ec2), \"s3\": \($s3), \"lambda\": \($lam), \"iam\": \($iam)}" ]]
    }]
  }')

# ---- INGESTION TRANSIT TO GRAFANA LOKI ----
echo "Streaming structured telemetry payload to Grafana Cloud..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
     -H "Content-Type: application/json" \
     -u "${GRAFANA_USER_ID}:${GRAFANA_TOKEN}" \
     -X POST \
     -d "$PAYLOAD" \
     "$GRAFANA_LOKI_URL")

if [ "$RESPONSE" -eq 204 ] || [ "$RESPONSE" -eq 200 ]; then
    echo "SUCCESS: Metrics ingested cleanly (HTTP $RESPONSE)."
else
    echo "ERROR: Transmission failed with status code (HTTP $RESPONSE)."
    exit 1
fi

echo "========================================="
echo " Audit Workflow Successfully Terminated"
echo "========================================="
