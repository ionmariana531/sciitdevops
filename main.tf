provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "Instance1" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  subnet_id = "subnet-0345b3efbea56581d"
  
  tags = {
    Name = "Instance-1"
  }
}


resource "aws_instance" "Instance2" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  subnet_id = "subnet-0345b3efbea56581d"
  
  
  tags = {
    Name = "Instance-2"
  }
}


resource "aws_instance" "Instance3" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  subnet_id = "subnet-0345b3efbea56581d"

  tags = {
    Name = "Instance-3"
  }
}

# Output added
output "instance_ips" {
  value = [
    aws_instance.Instance1.public_ip,
    aws_instance.Instance2.public_ip,
    aws_instance.Instance3.public_ip
  ]
}

