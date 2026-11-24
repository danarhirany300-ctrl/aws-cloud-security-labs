# AWS Cloud Security Labs

Hands-on labs where I find and fix common AWS security problems.
I built these while learning cloud security, coming from a SOC analyst background.

![Checkov](https://github.com/danarhirany300-ctrl/aws-cloud-security-labs/actions/workflows/checkov.yml/badge.svg)

Terraform code is scanned automatically by Checkov on every push (GitHub Actions). First scan: 14 findings. I fixed 4 types (versioning, KMS encryption, lifecycle rules, security group description) and skipped 4 types with written reasons (cost or lab scope).

## What is inside

| Folder | File | What it does |
|---|---|---|
| `bash/` | `check_s3.sh` | Checks all S3 buckets and warns if any bucket can be public |
| `bash/` | `check_iam_mfa.sh` | Finds IAM users that do not have MFA turned on |
| `python/` | `auto_fix_s3.py` | Uses boto3 to turn on "Block Public Access" for buckets automatically |
| `terraform/s3-bucket/` | `main.tf` | Creates an S3 bucket with all public access blocked |
| `terraform/secure-baseline/` | `main.tf` | S3 bucket plus a security group that allows SSH only from one IP |

## Why I built it

- Public S3 buckets and users without MFA are very common cloud security mistakes.
- Checking by hand does not scale, so I automated the checks with Bash and Python.
- I wrote the secure setup as Terraform code so it is repeatable and can be scanned with Checkov.

## How to use

You need an AWS account, AWS CLI configured, and (for Terraform) Terraform installed.

```bash
bash bash/check_s3.sh
bash bash/check_iam_mfa.sh
python3 python/auto_fix_s3.py
cd terraform/secure-baseline && terraform init && terraform plan
```

The IP address in the security group is an example (`203.0.113.10`). Replace it with your own.

## Next steps

- Run Checkov automatically with GitHub Actions
- Write least-privilege IAM policies
- Add KMS encryption

## IAM least privilege

`terraform/iam-least-privilege/` has a policy that can only read objects from one S3 bucket (no write, no delete, no other buckets), and a role that only EC2 can use.
`bash/test_iam_policy.sh` proves this with the IAM policy simulator. Checkov result: 20 passed, 0 failed.

Note: if the bucket is encrypted with KMS, the role also needs `kms:Decrypt` on that key.

## Role with MFA

`terraform/mfa-role/` has a read-only security auditor role (AWS `SecurityAudit` policy).
Only one named IAM user can assume it, and only if MFA was used (`aws:MultiFactorAuthPresent`).
Sessions last 1 hour, so the credentials are temporary. The user ARN is a variable, so no account number is stored in the repo.
Checkov result: 19 passed, 0 failed. The role was scanned and validated, but not applied to AWS.

## Free local testing with LocalStack

You can run `terraform apply` on a fake AWS on your own computer: no AWS account, no cost, nothing touches a real account.

How I did it:
1. Start LocalStack (version 4.14, the last one that needs no auth token), bound only to your own machine (`127.0.0.1:4566`).
2. Set fake test credentials and `AWS_ENDPOINT_URL=http://127.0.0.1:4566` in the terminal. Check with `aws sts get-caller-identity`: the account must be made of zeros. If it is a real account number, stop.
3. Copy `terraform/s3-bucket/localstack_override.tf.example` to `localstack_override.tf` (Git ignores it) and run `terraform init`, `plan`, `apply`.
4. Check the result with the AWS CLI, then run `terraform destroy`.

Result: all 6 resources were created, then verified (versioning on, public access blocked, KMS encryption on), then destroyed.

Lesson learned: the AWS provider puts the account ID in front of the S3 Control host name, so `127.0.0.1` fails and `localhost` works. Tool versions must match: pin your provider and LocalStack versions.

## Security exercise notes
`docs/flaws-cloud-notes.md` has my notes on the flaws.cloud AWS challenges: the mistakes, how to prevent them, and how to detect them.
