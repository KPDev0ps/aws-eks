# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "aws_region" {
  description = "aws eks region"
  default     = "eu-east-2"
}

variable "cidr_block_private1" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}
variable "cidr_block_private2" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}
variable "cidr_block_private3" {
  description = "CIDR block for private subnet 3"
  type        = string
  default     = "10.0.3.0/24"
}
variable "cidr_block_public1" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.4.0/24"
}
variable "cidr_block_public2" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.5.0/24"
}
variable "cidr_block_public3" {
  description = "CIDR block for public subnet 3"
  type        = string
  default     = "10.0.6.0/24"
}
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "eks_cluster_Terraform"
}
variable "vpc_aws_module" {
  description = "The VPC AWS Module to use"
  type        = string
  default     = "terraform-aws-modules/vpc/aws"
}
variable "vpc_aws_module_version" {
  description = "The version of the VPC AWS Module to use"
  type        = string
  default     = "5.8.1"
}
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "vpc_eks_london-01"
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "eks_aws_module" {
  description = "The EKS AWS Module to use"
  type        = string
  default     = "terraform-aws-modules/vpc/aws"
}
variable "eks_aws_module_version" {
  description = "The version of the EKS AWS Module to use"
  type        = string
  default     = "20.8.5"

}
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
variable "single_nat_gateway" {
  description = "Use a single NAT Gateway"
  type        = bool
  default     = true
}
variable "enable_dns_hostnames" {
  description = "Enable DNS Hostnames in the VPC"
  type        = bool
  default     = true
}
variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}
variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS cluster endpoint"
  type        = bool
  default     = true
}
variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the cluster creator"
  type        = bool
  default     = true
}
variable "AMI_TYPE" {
  description = "The AMI type for the EKS worker nodes"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}
variable "node_group_instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}
variable "node_group_name1" {
  description = "The name of the EKS worker node group"
  type        = string
  default     = "Node-group-1"
}
variable "node_min_size" {
  description = "Minimum size of the EKS worker node group"
  type        = number
  default     = 1
}
variable "node_max_size" {
  description = "Maximum size of the EKS worker node group"
  type        = number
  default     = 3
}
variable "node_desired_size" {
  description = "Desired size of the EKS worker node group"
  type        = number
  default     = 2
}
variable "node_group_name2" {
  description = "The name of the second EKS worker node group"
  type        = string
  default     = "Node-group-2"
}
variable "ebs_csi_policy_arn" {
  description = "The ARN of the EBS CSI Driver IAM policy"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

variable "iam_assumable_role_with_oidc_module" {
  description = "The IAM Assumable Role with OIDC Module to use"
  type        = string
  default     = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
}
variable "iam_assumable_role_with_oidc_module_version" {
  description = "The version of the IAM Assumable Role with OIDC Module to use"
  type        = string
  default     = "5.39.0"
}


variable "eks_nodegroup_capacity_type" {
  description = "The capacity type for the EKS worker node group"
  type        = string
  default     = "ON_DEMAND"
}
variable "environment" {
  description = "The environment for the EKS cluster"
  type        = string
  default     = "dev"
}

variable "eks_nodegroup_instance_type" {
  description = "The instance types of the AWS nodes used in EKS"
  type        = list(string)
  default     = ["m5.2xlarge", "c5.2xlarge", "m6i.2xlarge", "c6i.2xlarge"]
}

