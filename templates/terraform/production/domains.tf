resource "aws_route53_zone" "primary" {
  count = var.domain_name == null ? 0 : 1

  name = var.domain_name
}

resource "aws_route53_record" "root" {
  count = var.domain_name == null ? 0 : 1

  zone_id = aws_route53_zone.primary[0].id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.application.alb.dns_name
    zone_id                = module.application.alb.zone_id
    evaluate_target_health = true
  }
}
