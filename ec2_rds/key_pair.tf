################################
# EC2 キーペア
################################
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.prefix}-key"
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = "ec2-keypair"
  }
}

################################
# Output
################################
resource "local_sensitive_file" "keypair_pem" {
  filename        = "./.ssh/id_rsa.pem"
  content         = tls_private_key.main.private_key_pem
  file_permission = "0600"
}
