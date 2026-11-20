#!/bin/bash

echo "Starting IAM MFA Security Audit..."
echo "----------------------------------"

# Get a list of all IAM users
USERS=$(aws iam list-users --query "Users[*].UserName" --output text)

# Loop through each user
for USER in $USERS; do
    # Ask AWS for the MFA devices attached to this user
    MFA_COUNT=$(aws iam list-mfa-devices --user-name "$USER" --query "MFADevices" --output text 2>/dev/null)
    
    # If the output is empty, it means no MFA is attached
    if [ -z "$MFA_COUNT" ]; then
        echo "[CRITICAL] User: $USER DOES NOT have MFA enabled!"
    else
        echo "[SAFE] User: $USER has MFA enabled."
    fi
done

echo "----------------------------------"
echo "Audit Complete."
