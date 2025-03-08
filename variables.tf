variable "aws_region" {
  description = "Region to deploy the infrastructure"
  default     = "eu-west-1" 
}

variable "instance_type" {
  description = "Type of instance which will be used"
  default = "t2.medium"
}

variable "ami" {
  description = "Ami which will be used"
  default = "ami-03fd334507439f4d1"
}
