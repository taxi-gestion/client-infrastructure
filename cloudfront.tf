resource "aws_cloudfront_origin_access_identity" "client" {
  comment = "S3 cloudfront origin access identity for client service"
}

locals {
  s3_origin_id  = "client_s3"
  api_origin_id = "client_api"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = length(var.domain_name) > 0 ? [var.domain_name] : []

  custom_error_response {
    error_caching_min_ttl = 7200
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  origin {
    domain_name = aws_s3_bucket.client.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.client.cloudfront_access_identity_path
    }
  }

  dynamic "origin" {
    for_each = var.api_endpoint != "" ? [1] : []
    content {
      domain_name = replace(var.api_endpoint, "/^https?://([^/]*).*/", "$1")
      origin_id   = local.api_origin_id

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 3600
    min_ttl                = 0
    max_ttl                = 86400
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    response_headers_policy_id = aws_cloudfront_response_headers_policy.response_headers_policy_client.id

  }

  dynamic "ordered_cache_behavior" {
    for_each = var.api_endpoint != "" ? [1] : []
    content {
      # Using the CachingDisabled managed policy ID: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-policy-caching-disabled
      # Using the AllViewerExceptHostHeader managed origin request policies ID: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-origin-request-policies.html
      path_pattern               = "/api/*"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      target_origin_id           = local.api_origin_id
      compress                   = true
      viewer_protocol_policy     = "redirect-to-https"
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id   = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
      response_headers_policy_id = aws_cloudfront_response_headers_policy.response_headers_policy_api.id

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.remove_api_from_uri[0].arn
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["FR"]
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn != "" ? [1] : []
    content {
      acm_certificate_arn      = var.acm_certificate_arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }

  dynamic "viewer_certificate" {
    for_each = var.acm_certificate_arn == "" ? [1] : []
    content {
      cloudfront_default_certificate = true
      ssl_support_method             = "sni-only"
      minimum_protocol_version       = "TLSv1.2_2021"
    }
  }

  tags = local.tags
}

resource "aws_cloudfront_function" "remove_api_from_uri" {
  count = var.api_endpoint != "" ? 1 : 0

  name    = "rewrite-request-remove-api-from-uri"
  runtime = "cloudfront-js-1.0"
  code    = <<EOF
function handler(event) {
	var request = event.request;
	request.uri = request.uri.replace(/\/api\//, "/");
	return request;
}
EOF
}


resource "aws_cloudfront_response_headers_policy" "response_headers_policy_client" {
  name = "policy-client"

  custom_headers_config {
    items {
      header   = "permissions-policy"
      override = true
      value    = "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
    }
  }

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "same-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = var.content_security_policy_client
      override                = true
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "response_headers_policy_api" {
  name = "policy-api"

  custom_headers_config {
    items {
      header   = "permissions-policy"
      override = true
      value    = "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
    }
  }

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = "63072000"
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
    content_security_policy {
      content_security_policy = "default-src 'self';"
      override                = false
    }
  }
}
