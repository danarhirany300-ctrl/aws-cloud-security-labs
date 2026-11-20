#!/bin/bash

echo "Starting S3 Security Audit..."
echo "---------------------------------"

# Get a list of all S3 bucket names
BUCKETS=$(aws s3api list-buckets --query "Buckets[*].Name" --output text)

# Loop through each bucket
for BUCKET in $BUCKETS; do
    # Check the public access block configuration
    PUBLIC_STATUS=$(aws s3api get-public-access-block --bucket "$BUCKET" --query "PublicAccessBlockConfiguration.BlockPublicAcls" --output text 2>/dev/null)

    if [ "$PUBLIC_STATUS" == "True" ]; then
        echo "[SAFE] Bucket: $BUCKET is blocked from public access."
    else
        echo "[WARNING] Bucket: $BUCKET might be PUBLIC! Check this immediately."
    fi
done

echo "---------------------------------"
echo "Audit Complete."
