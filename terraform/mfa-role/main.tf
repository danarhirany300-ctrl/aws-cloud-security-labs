provider "aws" {
  region = "us-east-2"
}

# The user that is allowed to try this role.
# The value is NOT in the code, so no account number goes to GitHub.
variable "trusted_user_arn" {
  type        = string
  description = "ARN of the IAM user that may assume this role"
}

# WHO can use the role, and only WITH MFA
data "aws_iam_policy_document" "mfa_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_user_arn]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role" "security_auditor" {
  name                 = "security-auditor-mfa-role"
  assume_role_policy   = data.aws_iam_policy_document.mfa_trust.json
  max_session_duration = 3600 # 1 hour, then the keys expire
}

# WHAT the role can do: read security settings, change nothing
resource "aws_iam_role_policy_attachment" "audit" {
  role       = aws_iam_role.security_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
