output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${var.name}"
}

output "grafana_secret_name" {
  description = "The name of the secret containing the Grafana admin password."
  value       = var.enable_kube_prometheus_stack ? aws_secretsmanager_secret.grafana[0].name : null
}

output "dynamo_stack_version" {
  description = "The version of the Dynamo stack to deploy"
  value       = var.dynamo_stack_version
}
