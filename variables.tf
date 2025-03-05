variable "aws_region" {
  description = "Region to deploy the infrastructure"
  default     = "eu-west-1"  #Change the region from us-west-2 to eu-west-1
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "create_cluster" {
  description = "Control if the EKS cluster should be created"
  type        = bool
  default     = true
}

