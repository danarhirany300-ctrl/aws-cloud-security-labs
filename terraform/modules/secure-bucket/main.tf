data "aws_caller_identity" "current" {}

# 1. Our own KMS key for this bucket (with automatic yearly rotation)
resource "aws_kms_key" "this" {
  description         = "Key for bucket ${var.bucket_name}"
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

# 2. The bucket itself
resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV_AWS_144:Cross-region replication costs extra, not needed for a lab
  #checkov:skip=CKV2_AWS_62:No event notifications are needed in this lab
  #checkov:skip=CKV_AWS_18:Access logging needs a separate log bucket, planned for later
  bucket = var.bucket_name
  tags   = var.tags
}

# 3. Turn ACLs off (the Level 2 lesson from flaws.cloud)
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 4. Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket_ownership_controls.this]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. Keep old versions of files
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 6. Encrypt everything with our KMS key
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this.arn
    }
  }
}

# 7. Clean up old versions and unfinished uploads
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket     = aws_s3_bucket.this.id
  depends_on = [aws_s3_bucket_versioning.this]

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
