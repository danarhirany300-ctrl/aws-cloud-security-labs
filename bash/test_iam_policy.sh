#!/usr/bin/env bash
# Tests the least-privilege policy with the IAM policy simulator.
# Run from the repo root. Creates nothing in AWS.
set -euo pipefail

POLICY="terraform/iam-least-privilege/policy.json"
BUCKET="terraform-secure-danar-2026"

echo "Test 1: our bucket (expect GetObject allowed, Put/Delete denied)"
aws iam simulate-custom-policy \
  --policy-input-list "$(cat "$POLICY")" \
  --action-names s3:GetObject s3:PutObject s3:DeleteObject \
  --resource-arns "arn:aws:s3:::${BUCKET}/test.txt" \
  --query 'EvaluationResults[].[EvalActionName,EvalDecision]' --output table

echo "Test 2: another bucket (expect GetObject denied)"
aws iam simulate-custom-policy \
  --policy-input-list "$(cat "$POLICY")" \
  --action-names s3:GetObject \
  --resource-arns "arn:aws:s3:::some-other-bucket/test.txt" \
  --query 'EvaluationResults[].[EvalActionName,EvalDecision]' --output table
