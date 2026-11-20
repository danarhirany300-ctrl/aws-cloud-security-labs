provider "aws" {
  region = "us-east-2"
}

# 1. Create a bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "terraform-secure-danar-2026"

  tags = {
    Name        = "Terraform Secure Bucket"
    Environment = "Dev"
  }
}

# 2. The Security Guard (This is the crucial part)
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
