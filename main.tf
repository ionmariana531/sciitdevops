provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "Instance1" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  
  tags = {
    Name = "Instance-1"
  }
}


resource "aws_instance" "Instance2" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  
  tags = {
    Name = "Instance-2"
  }
}


resource "aws_instance" "Instance3" {
  ami = "ami-03fd334507439f4d1"
  instance_type = "t2.medium"
  
  tags = {
    Name = "Instance-3"
  }
}
