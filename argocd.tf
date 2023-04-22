locals {
  argocd_apps_value_template_input = {
    environment             = var.environment
    microservices_list      = var.list_of_microservices
    microservices_namespace = "${var.project_name}-${var.environment}"
    charts_repo_url         = var.charts_repo_url
  }

  argocd_apps_value = [templatefile("${path.module}/values/apps_values.tpl", local.argocd_apps_value_template_input)]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "5.5.8"
  depends_on = [kubernetes_namespace.argocd]

  name      = "argocd"
  namespace = kubernetes_namespace.argocd.metadata.0.name
  wait      = true
  timeout   = 300

  values = [file("${path.root}/values/values.yaml")]

  set {
    name  = "configs.credentialTemplates.${var.project_name}-vcs-repo.url"
    value = var.charts_repo_url
  }

  set {
    name  = "configs.credentialTemplates.${var.project_name}-vcs-repo.username"
    value = var.repo_username_argocd
  }

  set {
    name  = "configs.credentialTemplates.${var.project_name}-vcs-repo.password"
    value = var.repo_token_argocd
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.argocd_domain_name
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
    value = "internet-facing"
  }

  set {
    name  = "server.ingress.annotations.alb\\.ingress\\.kubernetes\\.io/certificate-arn"
    value = aws_acm_certificate.argocd.arn
  }

  dynamic "set" {
    for_each = var.argocd_slack_app_token != "" ? ["true"] : []
    content {
      name  = "notifications.secret.items.slack-token"
      value = var.argocd_slack_app_token
    }
  }
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  chart      = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  depends_on = [helm_release.argocd]

  namespace = kubernetes_namespace.argocd.metadata.0.name
  wait      = true
  timeout   = 300

  values = local.argocd_apps_value
}

#----
# ACM
#----

resource "aws_acm_certificate" "argocd" {
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
    for dvo in aws_acm_certificate.argocd.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}


resource "aws_acm_certificate_validation" "argocd" {
  certificate_arn         = aws_acm_certificate.argocd.arn
  validation_record_fqdns = [for record in aws_route53_record.argocd : record.fqdn]

  timeouts {
    create = "5m"
  }
}
