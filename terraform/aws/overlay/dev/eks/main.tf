# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Provider configuration: use named CLI profile from variables
# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = var.vpc_name

  cidr = var.vpc_cidr
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = [
    var.cidr_block_private1,
    var.cidr_block_private2,
    var.cidr_block_private3
  ]
  public_subnets  = [
    var.cidr_block_public1,
    var.cidr_block_public2,
    var.cidr_block_public3
  ]

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

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

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types                        = var.eks_nodegroup_instance_type
    attach_cluster_primary_security_group = true
  }

  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }
  create_iam_role = true
  eks_managed_node_groups = {
    node_group = {
      #name = "default-node-group"
      iam_role_use_name_prefix = false
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_group_instance_type]
      capacity_type  = var.eks_nodegroup_capacity_type
      disk_size      = 100

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      iam_role_additional_policies = { AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy" }
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100 # Must match disk_size
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
      }
    }

    # need to fix the name issue before implementing additional policies, manaully adding policy now
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    "MyAccess" = {
      kubernetes_groups = ["admins"]
      principal_arn     = "arn:aws:iam::803103365620:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AdministratorAccess_5f7fb06786c4f7b8"
      user_name         = "arn:aws:sts::803103365620:assumed-role/AWSReservedSSO_AdministratorAccess_5f7fb06786c4f7b8/{{SessionName}}"
      policy_associations = {
        "clusterAdmin" = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
  }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}
