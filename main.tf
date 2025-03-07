###############################################################################
# Required version was added
###############################################################################
#terraform {
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "3.74.0"
#    }
#  }
#}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "devops_role" {
  name               = "DevOps-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Federated = "arn:aws:iam::329599661643:oidc-provider/token.actions.githubusercontent.com"
        }
        Action    = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:ionmariana531/sciitdevops:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}
# Permisiuni pentru rol
resource "aws_iam_role_policy" "devops_role_policy" {
  name   = "DevOpsRolePolicy"
  role   = aws_iam_role.devops_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ec2:*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

data "aws_availability_zones" "available" {}

locals {
  name            = "eks-cluster-${basename(path.cwd)}"
  cluster_version = "1.31"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Environment = "Dev"
    Project     = "AWS-EKS"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general-purpose = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 1
    }
  }

  tags = local.tags
}

# Trigger GitHub Actions
# Trigger GitHub Actions
# Trigger GitHub Actions
