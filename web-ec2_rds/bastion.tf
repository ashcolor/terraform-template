################################
# Security group
################################
resource "aws_security_group" "bastion" {
    name = "bastion"
    description = "Allow SSH inbound traffic"
    vpc_id = "${aws_vpc.vpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

################################
# EC2 キーペア
################################
resource "tls_private_key" "main" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "main" {
    key_name = "${var.prefix}-key"
    public_key = tls_private_key.main.public_key_openssh

    tags = {
        Name = "ec2-keypair"
    }
}

resource "local_sensitive_file" "keypair_pem" {
    filename = "./.ssh/id_rsa.pem"
    content = tls_private_key.main.private_key_pem
    file_permission = "0600"
}

################################
# EC2
################################
resource "aws_instance" "bastion" {
    ami = data.aws_ssm_parameter.amzn2_latest_ami.value
    instance_type = "t2.nano"
    key_name = aws_key_pair.main.key_name
    vpc_security_group_ids = [
      "${aws_security_group.bastion.id}"
    ]
    subnet_id = "${aws_subnet.public_subnet_1a.id}"
    associate_public_ip_address = "true"
    tags = {
        Name = "bastion"
    }
}

################################
# Output
################################
output "bastion_public_ip" {
  description = "The public IP address assigned to the instanceue"
  value       = aws_instance.bastion.public_ip
}
