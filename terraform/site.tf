resource "aws_s3_bucket" "site" {
  bucket = "choam.me"
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "site_policy" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.site.arn}/*",
    ]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_policy.json
}

resource "aws_s3_object" "site_index_html" {
  bucket = aws_s3_bucket.site.id
  key = "index.html"
  source = "../index.html"
  content_type = "text/html"

  etag = md5(file("../index.html"))
}

resource "aws_s3_object" "site_well_known_matrix" {
  bucket = aws_s3_bucket.site.id
  key = ".well-known/matrix/server"
  source = "../matrix-server"
  content_type = "application/json"

  etag = md5(file("../matrix-server"))
}

resource "aws_acm_certificate" "site_cert" {
  provider = aws.us-east-1
  domain_name = "choam.me"
  validation_method = "EMAIL"
}

locals {
  s3_origin_id = "MyS3Origin"
}

resource "aws_cloudfront_distribution" "site_distribution" {
  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id = local.s3_origin_id
  }

  aliases = ["choam.me"]

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.site_cert.arn
    ssl_support_method = "sni-only"
  }
}
