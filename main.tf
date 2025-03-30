provider "aws" {
  region = "eu-west-1"
}

# Select the VPC
data "aws_vpc" "VPC_terraform" {
  id = "vpc-0269360390e175ec7"
}

# Select the Subnet
data "aws_subnet" "Subnet-VPC" {
  id = "subnet-0592d5af417aa893f"
}

# Use Existing Security Group
data "aws_security_group" "existing_sg" {
  id = "sg-008e2201608e83f75"
}

# Add SSH rule to the existing Security Group (DANGEROUS: Open to the internet!)
resource "aws_security_group_rule" "open_ssh" {
  security_group_id = data.aws_security_group.existing_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # ⚠️ DANGEROUS: SSH allowed from anywhere
}

resource "aws_security_group_rule" "egress_http" {
  security_group_id = data.aws_security_group.existing_sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_https" {
  security_group_id = data.aws_security_group.existing_sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_dns_tcp" {
  security_group_id = data.aws_security_group.existing_sg.id
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Select the key
data "aws_key_pair" "existing_key" {
  key_name = "app-ssh-key"
}

# Create EC2 Instances
resource "aws_instance" "Instance1" {
  ami                    = "ami-03fd334507439f4d1"
  instance_type          = "t2.medium"
  subnet_id              = data.aws_subnet.Subnet-VPC.id
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  key_name               = data.aws_key_pair.existing_key.key_name

 root_block_device {
    volume_size = 20  # Setează 20GB pentru root volume
    volume_type = "gp3"
  }

  tags = {
    Name = "Instance-1"
    "Master-Node" = "true"
  }
}

#resource "aws_instance" "Instance2" {
#  ami                    = "ami-03fd334507439f4d1"
#  instance_type          = "t2.medium"
#  subnet_id              = data.aws_subnet.Subnet-VPC.id
#  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
#  key_name               = data.aws_key_pair.existing_key.key_name

#  tags = {
#    Name = "Instance-2"
#    "Worker-Node" = "true"
#  }
#}


# Output added
output "instance_ips" {
  value = [
    aws_instance.Instance1.public_ip,
#    aws_instance.Instance2.public_ip
#    aws_instance.Instance3.public_ip
  ]
}

# Use the existing S3 bucket (instead of creating a new one)
data "aws_s3_bucket" "argocd_password_bucket" {
  bucket = "my-argocd-bucket"  # Numele bucket-ului tău creat manual
}

# Output the S3 bucket name with the correct name
output "my-argocd-bucket" {
  value = data.aws_s3_bucket.argocd_password_bucket.bucket
}
