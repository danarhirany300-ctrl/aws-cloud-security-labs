# flaws.cloud notes

flaws.cloud is a free, intentionally vulnerable AWS game. Only flaws.cloud was tested, as the game allows.

## Scope (honest note)
- **Level 1:** done hands-on.
- **Levels 2 to 6:** not run. My lab account is in an AWS Organization whose policy (SCP) allows only one region, and signed requests to other regions are denied. I tested this with four regions. I studied the mistakes and the fixes instead.

## Levels

| Level | Mistake | Prevent | Detect |
|---|---|---|---|
| 1 | Public bucket allows anonymous listing. A hosted website bucket has the same name as its domain. | Block Public Access, no public `ListBucket` | Script that checks the public access block on every bucket |
| 2 | ACL gives access to "Authenticated Users" (anyone with any AWS account) | Turn ACLs off (`BucketOwnerEnforced`), Block Public Access, name specific accounts or roles | Access Analyzer or a bucket ACL check |
| 3 | Public bucket holds a `.git` folder, and the history contains AWS keys | No secrets in Git, `.gitignore`, secret scanning, rotate keys | Secret scanning on repos |
| 4 | Public EBS snapshot with passwords inside | Block public snapshots, KMS encryption, use a secrets service | `aws ec2 describe-snapshots --owner-ids self --restorable-by-user-ids all` |
| 5 | Proxy lets an attacker reach the EC2 metadata service and steal role keys | Require IMDSv2, no open proxies, least-privilege roles | Alerts on role keys used from a strange place |
| 6 | Leaked read-only audit user still shows the whole account | Least privilege, protect keys, MFA on powerful roles | Alerts on unusual API calls |

## Prevent and detect
- **Prevent:** Terraform and Checkov in a pipeline. A test on a bad bucket failed 12 checks, including public ACL and all four Block Public Access checks. My real bucket passes them.
- **Detect:** check scripts. Checkov cannot see a public bucket created by hand in the console.
