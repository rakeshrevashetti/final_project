resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "${terraform.workspace}-s3-bucket"
  tags = {
    Name        = "${terraform.workspace}-s3-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_object" "index_html" {
  bucket      = aws_s3_bucket.my_s3_bucket.bucket
  key         = "index.html"
  source      = "index.html"  
  content_type = "text/html"
  acl         = "private"  
  depends_on = [ aws_s3_bucket.my_s3_bucket ]
}


