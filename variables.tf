variable "list_of_microservices" {
  description = "List of Microservices to create ArgoCD Applications"
  type        = list(string)
  default     = []
}

variable "charts_repo_url" {
  description = "Deployment Chart Git repo URL"
  type        = string
}

variable "repo_username_argocd" {
  description = "Git repo access token name or username"
  type        = string
}

variable "repo_token_argocd" {
  description = "Git repo access token"
  type        = string
}

variable "argocd_slack_app_token" {
  description = "Slack app token to register with ArgoCD for notifications"
  type        = string
  default     = ""
}

#---
# ACM
#---


variable "domain_name" {
  description = "Rout53 hostedzone Domain name"
  type        = string
}

variable "argocd_domain_name" {
  description = "ArgoCD Domain name to create ACM certificate on"
  type        = string
}
