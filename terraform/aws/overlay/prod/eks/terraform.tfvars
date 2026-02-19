# Production Environment Configuration

# AWS Configuration
aws_region = "us-east-2"

# VPC Configuration
vpc_name        = "prod-eks-vpc"
vpc_cidr        = "10.2.0.0/16"
private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
public_subnets  = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]

# Multiple NAT gateways for high availability
enable_nat_gateway = true
single_nat_gateway = false
enable_dns_hostnames = true

# EKS Cluster Configuration
cluster_version = "1.31"
cluster_endpoint_public_access = false  # More secure for production
cluster_endpoint_private_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Restrict as needed

# Node Group Configuration (production-grade instances)
node_group_name = "prod-nodes"
ami_type = "AL2023_x86_64_STANDARD"
node_group_instance_types = ["m5.xlarge"]
node_group_instance_type = "m5.xlarge"
node_group_capacity_type = "ON_DEMAND"
node_group_disk_size = 150

# Scaling Configuration
node_min_size = 3
node_max_size = 10
node_desired_size = 5

# Spot Node Group Configuration
spot_node_group_name = "prod-spot-nodes"
spot_instance_types = ["m5.xlarge", "m5a.xlarge", "m4.xlarge"]
spot_min_size = 2
spot_max_size = 8
spot_desired_size = 3

# Access Configuration
enable_cluster_creator_admin_permissions = true
environment = "prod"

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