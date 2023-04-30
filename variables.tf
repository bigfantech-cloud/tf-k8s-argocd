variable "list_of_microservices" {
  description = "List of Microservices to create ArgoCD Applications"
  type        = list(string)
}

variable "charts_repo_url" {
  description = "Deployment Chart Git repo URL"
  type        = string
}

variable "repo_username" {
  description = "Git repo access token name or username"
  type        = string
}

variable "repo_token" {
  description = "Git repo access token"
  type        = string
}

variable "slack_app_token" {
  description = "Slack app token to register with ArgoCD for notifications"
  type        = string
  default     = null
}

#---
# ACM
#---


variable "domain_name" {
  description = "Rout53 hostedzone Domain name to create ACM DNS records in"
  type        = string
  default     = null
}

variable "argocd_domain_name" {
  description = "ArgoCD Domain name to create ACM certificate on"
  type        = string
  default     = null
}
