# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2"
}

# VPC Configuration
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "prod-eks-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]
}

variable "enable_nat_gateway" {
  description = "Should be true to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

# EKS Configuration
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
  validation {
    condition     = can(regex("^1\\.(2[89]|3[01])$", var.cluster_version))
    error_message = "Cluster version must be a valid Kubernetes version (1.28, 1.29, 1.30, or 1.31)."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Node Group Configuration
variable "node_group_name" {
  description = "Name of the EKS managed node group"
  type        = string
  default     = "prod-nodes"
}

variable "ami_type" {
  description = "The AMI type for the EKS worker nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_group_instance_types" {
  description = "List of instance types associated with the EKS Node Group"
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "node_group_instance_type" {
  description = "Instance type for the EKS worker nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
  validation {
    condition     = can(regex("^(ON_DEMAND|SPOT)$", var.node_group_capacity_type))
    error_message = "Node group capacity type must be either ON_DEMAND or SPOT."
  }
}

variable "node_group_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 150
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS Node Group"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS Node Group"
  type        = number
  default     = 10
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS Node Group"
  type        = number
  default     = 5
}

# Spot Node Group Configuration
variable "spot_node_group_name" {
  description = "Name of the spot EKS managed node group"
  type        = string
  default     = "prod-spot-nodes"
}

variable "spot_instance_types" {
  description = "List of instance types for spot nodes"
  type        = list(string)
  default     = ["m5.xlarge", "m5a.xlarge", "m4.xlarge"]
}

variable "spot_min_size" {
  description = "Minimum number of spot nodes"
  type        = number
  default     = 2
}

variable "spot_max_size" {
  description = "Maximum number of spot nodes"
  type        = number
  default     = 8
}

variable "spot_desired_size" {
  description = "Desired number of spot nodes"
  type        = number
  default     = 3
}

# Access Configuration
variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator as an administrator via access entry"
  type        = bool
  default     = true
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type = map(object({
    kubernetes_groups = optional(list(string), [])
    principal_arn     = string
    user_name         = optional(string)
    policy_associations = optional(map(object({
      policy_arn = string
      access_scope = object({
        type       = string
        namespaces = optional(list(string))
      })
    })), {})
  }))
  default = {}
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
  validation {
    condition     = can(regex("^(dev|development|staging|stage|prod|production)$", var.environment))
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production."
  }
}