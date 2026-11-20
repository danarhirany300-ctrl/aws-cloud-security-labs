provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "good_key" {
  description         = "Key for S3 bucket encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAccountAdmin"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
      Action    = "kms:*"
      Resource  = "*"
    }]
  })
}

resource "aws_s3_bucket" "good_bucket" {
  #checkov:skip=CKV_AWS_144:Cross-region replication costs extra and is not needed for a learning lab
  #checkov:skip=CKV2_AWS_62:No event notifications are needed in this lab
  #checkov:skip=CKV_AWS_18:Access logging needs a separate log bucket, planned for later
  bucket = "terraform-good-bucket-danar-2026"
}

resource "aws_s3_bucket_public_access_block" "good_block" {
  bucket = aws_s3_bucket.good_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "good_versioning" {
  bucket = aws_s3_bucket.good_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "good_encryption" {
  bucket = aws_s3_bucket.good_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.good_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "good_lifecycle" {
  bucket     = aws_s3_bucket.good_bucket.id
  depends_on = [aws_s3_bucket_versioning.good_versioning]

  rule {
    id     = "cleanup"
    status = "Enabled"
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_security_group" "good_sg" {
  #checkov:skip=CKV2_AWS_5:Baseline example, intentionally not attached to an instance
  name        = "secure-firewall"
  description = "Allow SSH only from my IP"

  ingress {
    description = "SSH from my IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"] # example IP, replace with your own
  }
}
