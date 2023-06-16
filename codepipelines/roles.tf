# ---------------------------------------------------------------------------------------------------------------------
# CODEBUILD CONTAINER ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codebuild_container_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path = "/"
}

resource "aws_iam_policy" "codebuild_container_policy" {
  description = "Policy to allow codebuild to execute build spec"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeDhcpOptions",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeVpcs",
                "ecr:BatchCheckLayerAvailability",
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart",
                "ecs:RunTask",
                "iam:PassRole",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ssm:GetParameters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.codepipeline_bucket.arn}/*", "${aws_s3_bucket.codepipeline_bucket.arn}"]
    },
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability", "ecr:PutImage",
        "ecr:InitiateLayerUpload", "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Effect": "Allow",
      "Resource": "${var.image_backend_arn}"
    },
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Effect": "Allow",
      "Resource": "${var.image_backend_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "arn:aws:ec2:${var.aws_region}:*:network-interface/*",
      "Condition": {
        "StringEquals": {
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        },
        "ArnEquals": {
          "ec2:Subnet": ["${var.subnet.private[0].arn}", "${var.subnet.private[1].arn}"]
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild-container-attach" {
  role       = aws_iam_role.codebuild_container_role.name
  policy_arn = aws_iam_policy.codebuild_container_policy.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CODEPIPELINE CONTAINER ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "codepipeline_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  path               = "/"
}

resource "aws_iam_policy" "codepipeline_policy" {
  description = "Policy to allow codepipeline to execute"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:GetBucketVersioning"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.codepipeline_bucket.arn}/*", "${var.artifacts_bucket.arn}/*", "${var.static_web_bucket.arn}/*"]
    },
    {
      "Action" : [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "cloudformation:*",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action" : [
        "ecs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline-attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

# ---------------------------------------------------------------------------------------------------------------------
# STATIC WEB BUILD ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "static_build_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "build-role-frontend"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "build_policy" {
  description = "Policy used in trust relationship with CodeBuild"
  name        = "build-policy-frontend"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:*"
          ],
          "Resource" = [
            "${var.static_web_bucket.arn}/*",
            "${var.artifacts_bucket.arn}/*"
          ]
        },
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*"
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "build_policy_attachment" {
  role       = aws_iam_role.static_build_role.name
  policy_arn = aws_iam_policy.build_policy.arn
}
