# Purpose

> This is final implementation Terraform code to `terraform apply`, not a module

- To install ArgoCD in Kubernetes Cluster
- Create ArgoCD Apps
- For ArgoCD custom domain (optional)
  - Create AWS ACM certificate
  - Add DNS record in AWS Route53 HostedZone

## Required Providers

| Name                  | Description |
| --------------------- | ----------- |
| aws (hashicorp/aws)   | >= 4.47     |
| helm (hashicorp/helm) | >= 2.7      |

## Variables

### Required Variables

| Name                  | Description                                               | Default |
| --------------------- | --------------------------------------------------------- | ------- |
| list_of_microservices | List of Microservices to create ArgoCD Applications       |         |
| charts_repo_url       | Deployment Chart Git repo URL                             |         |
| repo_username         | Git repo access token name or username                    |         |
| repo_token            | Git repo access token                                     |         |
| slack_app_token       | Slack app token to register with ArgoCD for notifications | null    |

### Optional Variables

| Name               | Description                                                | Default |
| ------------------ | ---------------------------------------------------------- | ------- |
| domain_name        | Rout53 hostedzone Domain name to create ACM DNS records in | null    |
| argocd_domain_name | ArgoCD Domain name to create ACM certificate on            | null    |

### Example config

> This repo itself the example
