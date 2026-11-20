provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

# KMS key used to encrypt the bucket
resource "aws_kms_key" "bucket_key" {
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

resource "aws_s3_bucket" "secure_bucket" {
  #checkov:skip=CKV_AWS_144:Cross-region replication costs extra and is not needed for a learning lab
  #checkov:skip=CKV2_AWS_62:No event notifications are needed in this lab
  #checkov:skip=CKV_AWS_18:Access logging needs a separate log bucket, planned for later
  bucket = "terraform-secure-danar-2026"

  tags = {
    Name        = "Terraform Secure Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket     = aws_s3_bucket.secure_bucket.id
  depends_on = [aws_s3_bucket_versioning.versioning]

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
