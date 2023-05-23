resource "aws_s3_bucket" "client" {
  bucket = "${var.project}-${var.service}"
  tags   = local.tags
}

resource "aws_s3_bucket_policy" "client" {
  bucket = aws_s3_bucket.client.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.client.arn}/*"
        ],
        "Principal" : {
          "AWS" : [
            "${aws_cloudfront_origin_access_identity.client.iam_arn}"
          ]
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.client.arn}"
        ],
        "Principal" : {
          "AWS" : [
            "${aws_cloudfront_origin_access_identity.client.iam_arn}"
          ]
        }
      }
    ]
  })
}


resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-${var.service}-logs"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  depends_on = [aws_s3_bucket_ownership_controls.logs]

  bucket = aws_s3_bucket.logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
          "AWS" : "${aws_cloudfront_origin_access_identity.client.iam_arn}"
        },
        "Action" : [
          "s3:GetBucketAcl",
          "s3:PutBucketAcl",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : ["${aws_s3_bucket.logs.arn}/*", "${aws_s3_bucket.logs.arn}"]
      }
    ]
    }
  )
}
