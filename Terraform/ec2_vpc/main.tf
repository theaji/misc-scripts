# Create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = "10.70.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-dev-vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "tf-ig"
  }
}

# Create public subnet
resource "aws_subnet" "public_sub" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.70.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-public-1"
  }
}

# Create route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "tf-rt"
  }
}

# Associate public subnets with route table
resource "aws_route_table_association" "public_route" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.rt.id
}

# Create security groups
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create ec2 instance and install apache
resource "aws_instance" "web_instance" {
  count                       = var.instances_per_subnet
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  availability_zone           = "us-east-1a"
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_sub.id
  associate_public_ip_address = true
  user_data                   = file("userdata.tpl")

  root_block_device {
    volume_size = var.ec2_volume_size
  }

  tags = {
    Name = "tf-web_instance"
  }
}
