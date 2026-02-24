terraform {
  required_version = ">= 1.5.7"

  backend "s3" {
    bucket  = "terraf0rmstate1"
    key     = "eks/dev/terraform.tfstate"
    region  = "eu-west-2"
    # Backend settings should match the shared state bucket.
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Terraform   = "true"
      Project     = "EKS-DevOps"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  environment  = "dev"
  cluster_name = "${local.environment}-eks-cluster"
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)

  common_tags = {
    Environment = local.environment
    Project     = "EKS-DevOps"
    ManagedBy   = "terraform"
    CostCenter  = "development"
  }
}

# VPC Module using AWS predefined module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = true

  # EKS tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = local.common_tags
}

# EKS Module using AWS predefined module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  # Network configuration
  vpc_id                               = module.vpc.vpc_id
  subnet_ids                           = module.vpc.private_subnets
  control_plane_subnet_ids             = module.vpc.private_subnets
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  # EKS Managed Node Group defaults
  eks_managed_node_group_defaults = {
    instance_types                        = var.node_group_instance_types
    attach_cluster_primary_security_group = true
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }

  # Node security group tags
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  create_iam_role = true

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    default = {
      name                     = var.node_group_name
      iam_role_use_name_prefix = false
      ami_type                 = var.ami_type
      instance_types           = [var.node_group_instance_type]
      capacity_type            = var.node_group_capacity_type
      disk_size                = var.node_group_disk_size

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_group_disk_size
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
      }

      tags = merge(
        local.common_tags,
        {
          "kubernetes.io/cluster/${local.cluster_name}" = "owned"
        }
      )
    }
  }

  # Cluster access entry
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # Access entries - customize as needed for your environment
  access_entries = var.access_entries

  tags = local.common_tags
}
