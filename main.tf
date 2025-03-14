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

# Select the key
data "aws_key_pair" "existing_key" {
  key_name = "app-ssh-key"
}

# Create EC2 Instances
resource "aws_instance" "Instance1" {
  ami                    = "ami-03fd334507439f4d1"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnet.Subnet-VPC.id
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
  key_name               = data.aws_key_pair.existing_key.key_name

  tags = {
    Name = "Instance-1"
  }
}

#resource "aws_instance" "Instance2" {
#  ami                    = "ami-03fd334507439f4d1"
#  instance_type          = "t2.micro"
#  subnet_id              = data.aws_subnet.Subnet-VPC.id
#  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
#  key_name               = data.aws_key_pair.existing_key.key_name

#  tags = {
#    Name = "Instance-2"
#  }
#}

#resource "aws_instance" "Instance3" {
#  ami                    = "ami-03fd334507439f4d1"
#  instance_type          = "t2.micro"
#  subnet_id              = data.aws_subnet.Subnet-VPC.id
#  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]
#  key_name               = data.aws_key_pair.existing_key.key_name

#  tags = {
#    Name = "Instance-3"
#  }
#}

# Output added
output "instance_ips" {
  value = [
    aws_instance.Instance1.public_ip,
#    aws_instance.Instance2.public_ip,
#    aws_instance.Instance3.public_ip
  ]
}

