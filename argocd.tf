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
    value = var.repo_username
  }

  set {
    name  = "configs.credentialTemplates.${var.project_name}-vcs-repo.password"
    value = var.repo_token
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
    value = aws_acm_certificate.argocd[0].arn
  }

  dynamic "set" {
    for_each = var.slack_app_token != null ? ["true"] : []
    content {
      name  = "notifications.secret.items.slack-token"
      value = var.slack_app_token
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
