provider "aws" {
  region = "us-east-1" 
}

resource "aws_key_pair" "example" {
  key_name   = "example-key" 
  public_key = file("~/.ssh/id_rsa.pub")  
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "ubuntu_instance" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"  
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "UbuntuInstance-${count.index + 1}"
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

resource "aws_instance" "ubuntu_instance" {
  count         = 3
  security_groups = [aws_security_group.instance_sg.name]
}

