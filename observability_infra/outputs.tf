output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_group_arn" {
  value = module.eks.eks_managed_node_groups["default"].node_group_arn
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name}"
}
