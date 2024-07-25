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
  # vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id
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

module "ec2" {
  # Note: the // is not a typo
  source                      = "git::git@github.com:codeasone/terra-modules.git//ec2?ref=4e1a4629247ff22a0edaecec172e0e825e912cbb"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = data.aws_ssm_parameter.public_subnet_id.value
  key_name                    = aws_key_pair.deployer.key_name
  security_group_ids          = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  instance_name               = "terra-service-instance"
}
