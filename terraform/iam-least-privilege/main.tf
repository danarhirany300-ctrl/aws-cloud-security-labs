provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_policy" "read_one_bucket" {
  name        = "read-one-bucket-only"
  description = "Read-only access to one S3 bucket"
  policy      = file("${path.module}/policy.json")
}

# Only EC2 servers can use this role
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "reader" {
  name               = "s3-reader-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.reader.name
  policy_arn = aws_iam_policy.read_one_bucket.arn
}
