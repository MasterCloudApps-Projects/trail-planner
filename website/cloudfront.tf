/*resource "aws_cloudfront_distribution" "frontend_s3_distribution" {

    depends_on = [aws_s3_bucket.static_web_bucket]
    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index.html"

    origin {
        domain_name = aws_s3_bucket_website_configuration.s3_bucket_website_config.website_endpoint
        origin_id   = aws_s3_bucket.static_web_bucket.id

        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }

  default_cache_behavior {

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    target_origin_id = aws_s3_bucket.static_web_bucket.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

      headers = ["Origin"]
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
        cloudfront_default_certificate = true
        ssl_support_method  = "sni-only"
  }
}
*/