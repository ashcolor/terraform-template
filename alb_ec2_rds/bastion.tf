################################
# Security group
################################
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################
# EC2
################################
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.nano"
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [
    "${aws_security_group.bastion.id}"
  ]
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = "true"
  tags = {
    Name = "bastion"
  }
}

################################
# Output
################################
output "bastion_public_ip" {
  description = "踏み台サーバ外部IP"
  value       = aws_instance.bastion.public_ip
}
