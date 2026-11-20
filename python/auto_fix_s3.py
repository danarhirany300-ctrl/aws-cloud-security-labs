import boto3

# Connect to the AWS S3 service in your home region
s3_client = boto3.client('s3', region_name='us-east-2')

print("Starting Python S3 Security Audit...")
print("------------------------------------")

# Get the list of all buckets
response = s3_client.list_buckets()

# Loop through each bucket
for bucket in response['Buckets']:
    bucket_name = bucket['Name']
    
    try:
        # Try to get the public access block settings
        s3_client.get_public_access_block(Bucket=bucket_name)
        print(f"[SAFE] {bucket_name} is private.")
        
    except s3_client.exceptions.ClientError:
        # If the error is 'NoSuchPublicAccessBlockConfiguration', it means it's PUBLIC!
        print(f"[WARNING] {bucket_name} is PUBLIC! Fixing it now...")
        
        # The fix: Apply the public block configuration
        s3_client.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
            }
        )
        print(f"[FIXED] {bucket_name} is now secure.")

print("------------------------------------")
print("Audit Complete.")
