# ---------------------------------------------------------------------------------------------------------------------
# AWS S3 BUCKET - FRONTEND
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "artifacts_bucket" {
  bucket        = var.artifacts_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "static_web_bucket" {
  bucket = var.static_web_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "static_web_bucket_ownership" {
  bucket = aws_s3_bucket.static_web_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "static_web_bucket_public_access" {
  bucket = aws_s3_bucket.static_web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "static_web_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_web_bucket_ownership,
    aws_s3_bucket_public_access_block.static_web_bucket_public_access,
  ]

  bucket = aws_s3_bucket.static_web_bucket.id
  acl    = "public-read"
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS S3 TO STATIC WEB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_cors_configuration" "s3_bucket_cors_config" {
  bucket = aws_s3_bucket.static_web_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "s3_bucket_website_config" {
  bucket = aws_s3_bucket.static_web_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS S3 - IAM POLICY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_static_web" {
  bucket = aws_s3_bucket.static_web_bucket.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_static_web_document.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_static_web_document" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:GetBucketVersioning",
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy"
    ]

    resources = [
      "${aws_s3_bucket.static_web_bucket.arn}/*",
      aws_s3_bucket.static_web_bucket.arn
    ]
  }
}
