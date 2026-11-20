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
