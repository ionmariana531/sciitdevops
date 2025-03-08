resource "aws_key_pair" "key_devops" {
  key_name   = "keydevops"
  public_key = tls_private_key.private_key.public_key_openssh
}

# RSA key of size 4096 bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tfkey" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "tfkey"
}