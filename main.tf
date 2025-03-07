provider "aws" {
  region = "eu-west-1"
}

# Resursa pentru zonele de disponibilitate
data "aws_availability_zones" "available" {
  state = "available"
}

# IAM Role pentru GitHub Actions OIDC
resource "aws_iam_role" "github_oidc_role" {
  name = "GitHub-OIDC-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::329599661643:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:ionmariana531/sciitdevops:ref:refs/heads/add-terraform-github-actions-Mariana-fe"
        }
      }
    }]
  })
}

# Politici pentru acces la AWS
resource "aws_iam_role_policy" "github_oidc_policy" {
  name = "GitHubOIDCPolicy"
  role = aws_iam_role.github_oidc_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sts:AssumeRole"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:*", "ec2:*", "eks:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Creare VPC pentru EKS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# Creare cluster EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-cluster"
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    app-nodes = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 5
      desired_size   = 2
    }
  }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

