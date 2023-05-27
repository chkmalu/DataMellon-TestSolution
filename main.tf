provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev_vpc" {
  cidr_block       = var.cidr_block
  
  tags = {
    Name = "dev_vpc"
  }

}

resource "aws_subnet" "private_sub" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.private_sub
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_sub"
  }
}

resource "aws_subnet" "public_sub" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = var.public_sub
  availability_zone = "us-east-1b"

  tags = {
    Name = "public_sub"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "private_rtb"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }
  

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route_table_association" "private_artb" {
  subnet_id      = aws_subnet.private_sub.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "public_artb" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.public_rtb.id
}


module "webserver" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.dev_vpc.id
    subnet_id = aws_subnet.private_sub.id
    cidr_block = var.cidr_block
}

module "jumphost" {
    source = "./modules/jumphost"
    vpc_id = aws_vpc.dev_vpc.id
    subnet_id = aws_subnet.public_sub.id
}