resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "ssh from jump host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_block]
  }

  ingress {
    description      = "web traffic from jump host"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_block]
  }

  ingress {
    description      = "web traffic from jump host"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webserver_sg"
  }
}



data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.0.20230517.1-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon.id
  instance_type = "t2.micro"
  key_name = "myapp_server_key"
  security_groups = [ aws_security_group.webserver_sg.id ]
  subnet_id = var.subnet_id
  root_block_device {
    volume_size = "8"
    volume_type = "gp3"
  }

  tags = {
    Name = "webserver"
  }
}