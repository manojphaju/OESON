output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_host.public_ip
}

output "k8s_node_ips" {
  description = "Public IPs of the Kubernetes nodes"
  value       = [for instance in aws_instance.k8s_nodes : instance.public_ip]
}


# output "kubeconfig" {
#   description = "Kubeconfig for EKS cluster"
#   value       = aws_eks_cluster.eks_cluster.kubeconfig[0].raw_kubeconfig
# }
