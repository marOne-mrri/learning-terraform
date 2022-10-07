provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg" {
  name = "my-sec-grp"
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "access internet"
    protocol = "all"
    from_port = 0
    to_port = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vm" {
  ami                    = "ami-08c40ec9ead489470"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = <<-EOF
                        #!/bin/bash
                        sudo apt update -y
                        sudo apt install -y nginx
                        sudo service start nginx
                      EOF
  tags = {
    Name = "terraform-vm"
  }
}
