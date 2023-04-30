#----
# ACM
#----

resource "aws_acm_certificate" "argocd" {
  count = var.domain_name != null ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = ["${var.argocd_domain_name}"]
  validation_method         = "DNS"

  tags = module.this.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "argocd" {
  for_each = {
    for dvo in aws_acm_certificate.argocd[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if var.domain_name != null
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}


resource "aws_acm_certificate_validation" "argocd" {
  count = var.domain_name != null ? 1 : 0

  certificate_arn         = aws_acm_certificate.argocd[0].arn
  validation_record_fqdns = [for record in aws_route53_record.argocd[0] : record.fqdn]

  timeouts {
    create = "5m"
  }
}
