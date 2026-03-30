# ============================================================
# Terraform Module: {APP_NAME}
# Provider: {CLOUD_PROVIDER}
# ============================================================

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "{APP_NAME}"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "staging"
}

variable "image_tag" {
  type        = string
  description = "Container image tag"
}

variable "replicas" {
  type        = number
  description = "Number of replicas"
  default     = 2
}

# Resource definitions (customize per cloud provider)
# Example: AWS ECS, GCP Cloud Run, etc.

output "app_url" {
  value       = "https://${var.app_name}.${var.environment}.example.com"
  description = "Application URL"
}

output "deployment_status" {
  value       = "deployed"
  description = "Deployment status"
}
