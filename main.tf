data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7r9kPM7aVR9AJ2KmB3dkpbzjNwbEBA2ly3Hqic2M7c codeasone@gmail.com"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/codeasone/vpc/id"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  # vpc_id      = data.terraform_remote_state.shared.outputs.vpc_id
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  ingress {
    description = "SSH from anywhere"
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

  tags = {
    Name = "allow_ssh"
  }
}

data "aws_ssm_parameter" "public_subnet_id" {
  name = "/codeasone/subnet/public/a"
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  # subnet_id                   = data.terraform_remote_state.shared.outputs.subnet_id
  subnet_id                   = data.aws_ssm_parameter.public_subnet_id.value
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true # This ensures the instance gets a public IP

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "terra-service-instance"
  }
}
