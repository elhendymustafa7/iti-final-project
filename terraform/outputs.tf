
output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_id" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-cluster.id
}