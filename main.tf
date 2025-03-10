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

# Select the SG
data "aws_security_group" "VPC-SG" {
  filter {
    name = "group-name"
    values = ["VPC needed for final exam"]
  }  
}

# Select the key
data "aws_key_pair" "existing_key" {
  key_name = "app-ssh-key"
}

resource "aws_instance" "Instance1" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.micro"
  subnet_id = data.aws_subnet.Subnet-VPC.id
  vpc_security_group_ids = [data.aws_security_group.VPC-SG.id]
  key_name = data.aws_key_pair.existing_key.key_name
  
  tags = {
    Name = "Instance-1"
  }
}


#resource "aws_instance" "Instance2" {
#  ami = "ami-03fd334507439f4d1"
#  instance_type = "t2.micro"
#  subnet_id = data.aws_subnet.Subnet-VPC.id
#  vpc_security_group_ids = [data.aws_security_group.VPC-SG.id]
#  key_name = data.aws_key_pair.existing_key.key_name
  
#  tags = {
#    Name = "Instance-2"

#  }
#}


#resource "aws_instance" "Instance3" {
#  ami = "ami-03fd334507439f4d1"
#  instance_type = "t2.micro"
#  subnet_id = data.aws_subnet.Subnet-VPC.id
#  vpc_security_group_ids = [data.aws_security_group.VPC-SG.id]
#   key_name = data.aws_key_pair.existing_key.key_name


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

