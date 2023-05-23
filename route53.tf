locals {
  hasValidHostedZone = length(var.hosting_zone_name) > 0 && length(var.hosting_zone_id) > 0
}

resource "aws_route53_record" "record_ipv4" {
  count = local.hasValidHostedZone ? 1 : 0

  name    = var.hosting_zone_name //aws_route53_zone.hosting_zone.name
  zone_id = var.hosting_zone_id   //aws_route53_zone.hosting_zone.zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "record_ipv6" {
  count = local.hasValidHostedZone ? 1 : 0

  name    = var.hosting_zone_name //aws_route53_zone.hosting_zone.name
  zone_id = var.hosting_zone_id   //aws_route53_zone.hosting_zone.zone_id
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
