################################
# ENI
################################
# resource "aws_network_interface" "web_01" {
#   subnet_id       = aws_subnet.private_subnet_1a.id
#   private_ips     = ["10.0.21.1"]
#   security_groups = [aws_security_group.web_sg.id]

#   tags = {
#     Name = "${var.prefix}-web-01"
#   }
# }

################################
# EC2 キーペア
################################
# resource "tls_private_key" "main" {
#     algorithm = "RSA"
#     rsa_bits = 4096
# }

# resource "aws_key_pair" "main" {
#     key_name = "${var.prefix}-key"
#     public_key = tls_private_key.main.public_key_openssh

#     tags = {
#         Name = "ec2-keypair"
#     }
# }

# resource "local_sensitive_file" "keypair_pem" {
#     filename = "./.ssh/id_rsa.pem"
#     content = tls_private_key.main.private_key_pem
#     file_permission = "0600"
# }

################################
# EC2
################################
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web_01" {
  ami                     = data.aws_ssm_parameter.amzn2_latest_ami.value
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  instance_type           = "t2.micro"
  # iam_instance_profile    = aws_iam_instance_profile.ec2.name
  disable_api_termination = false
  monitoring              = false
  user_data               = file("./param/user_data.sh")
  subnet_id              = aws_subnet.private_subnet_1a.id
  key_name                = aws_key_pair.main.key_name

  private_ip = "10.0.21.11"
  # network_interface {
  #   network_interface_id = aws_network_interface.web_01.id
  #   device_index         = 0
  # }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "${var.prefix}-web-01"
  }

  volume_tags = {
    Name = "${var.prefix}-web-01"
  }
}

# output "web01_private_ip" {
#   description = "The public IP address assigned to the instanceue"
#   value       = aws_instance.web_01.public_ip
# }
