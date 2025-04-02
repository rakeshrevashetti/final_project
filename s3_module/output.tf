output "domain_name" {
    value = aws_s3_bucket.my_s3_bucket.bucket_regional_domain_name
}

output "bucket_id" {
    value = aws_s3_bucket.my_s3_bucket.id
}