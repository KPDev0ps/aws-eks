# Development Environment Configuration

# AWS Configuration
aws_region = "us-east-2"

# VPC Configuration
vpc_name        = "dev-eks-vpc"
vpc_cidr        = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

# Cost optimization for development
enable_nat_gateway   = true
single_nat_gateway   = true
enable_dns_hostnames = true

# EKS Cluster Configuration
cluster_name                         = "dev-eks-kp"
cluster_version                      = "1.31"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = false
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

# Node Group Configuration (smaller instances for dev)
node_group_name           = "dev-nodes"
ami_type                  = "AL2023_x86_64_STANDARD"
node_group_instance_types = ["t3.medium"]
node_group_instance_type  = "t3.medium"
node_group_capacity_type  = "ON_DEMAND"
node_group_disk_size      = 100

# Scaling Configuration
node_min_size     = 1
node_max_size     = 3
node_desired_size = 2

# Access Configuration
enable_cluster_creator_admin_permissions = true
environment                              = "dev"

# Access entries - customize as needed for your team
access_entries = {
  # Example access entry - uncomment and modify as needed
  # "admin_user" = {
  #   kubernetes_groups = ["system:masters"]
  #   principal_arn     = "arn:aws:iam::ACCOUNT_ID:user/admin-user"
  #   policy_associations = {
  #     "admin" = {
  #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #       access_scope = {
  #         type = "cluster"
  #       }
  #     }
  #   }
  # }
}
