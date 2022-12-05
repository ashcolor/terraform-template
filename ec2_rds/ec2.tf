################################
# EC2
################################
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "web_01" {
  ami                    = data.aws_ssm_parameter.amzn2_latest_ami.value
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  instance_type          = "${var.web_instance_class}"
  disable_api_termination = false
  monitoring              = false
  user_data               = file("./param/user_data.sh")
  subnet_id               = aws_subnet.public_subnet_1a.id
  key_name                = aws_key_pair.main.key_name

  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name = "${var.prefix}-web-01"
  }

  volume_tags = {
    Name = "${var.prefix}-web-01"
  }
}

# EIP
resource "aws_eip" "eip_for_web_01" {
    instance = "${aws_instance.web_01.id}"
    vpc = true
}

output "web01_public_ip" {
  description = "The public IP address assigned to the instanceue"
  value       = aws_instance.web_01.public_ip
}
