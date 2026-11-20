provider "aws" {
  region = "us-east-2"
}

# 1. The Secure Bucket
resource "aws_s3_bucket" "good_bucket" {
  bucket = "terraform-good-bucket-danar-2026"
}

# 2. The Security Guard (Fixes the public access issue)
resource "aws_s3_bucket_public_access_block" "good_block" {
  bucket = aws_s3_bucket.good_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. The Secure Firewall (Fixes the open port issue)
resource "aws_security_group" "good_sg" {
  name        = "secure-firewall"
  description = "Allow SSH only from my IP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["203.0.113.10/32"] # example IP, replace with your own
  }
}
