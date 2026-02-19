# Staging Environment Configuration

# AWS Configuration
aws_region = "us-east-2"

# VPC Configuration
vpc_name        = "staging-eks-vpc"
vpc_cidr        = "10.1.0.0/16"
private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnets  = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]

# Multiple NAT gateways for higher availability
enable_nat_gateway   = true
single_nat_gateway   = false
enable_dns_hostnames = true

# EKS Cluster Configuration
cluster_version                      = "1.31"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

# Node Group Configuration (medium instances for staging)
node_group_name           = "staging-nodes"
ami_type                  = "AL2023_x86_64_STANDARD"
node_group_instance_types = ["t3.large"]
node_group_instance_type  = "t3.large"
node_group_capacity_type  = "ON_DEMAND"
node_group_disk_size      = 120

# Scaling Configuration
node_min_size     = 2
node_max_size     = 6
node_desired_size = 3

# Access Configuration
enable_cluster_creator_admin_permissions = true
environment                              = "staging"

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