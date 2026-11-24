output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Name of the bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the bucket (useful for IAM policies)"
}

output "kms_key_arn" {
  value       = aws_kms_key.this.arn
  description = "ARN of the KMS key that encrypts the bucket"
}
