provider "aws" {
  region = var.region
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "devops-igw"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "${var.region}a"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-a"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = "${var.region}b"

  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-b"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "ssh_http_nodeport" {
  name        = "allow-ssh-http-nodeport"
  description = "Allow SSH, HTTP and NodePort"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range"
    from_port   = 30000
    to_port     = 32767
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
    Name = "allow-ssh-http-nodeport"
  }
}

resource "aws_instance" "jenkins_host" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.ssh_http_nodeport.id]
  key_name                   = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "jenkins-host"
  }
}

resource "aws_instance" "k8s_nodes" {
  count                      = 2
  ami                        = var.instance_ami
  instance_type              = var.instance_type
  subnet_id                  = element([aws_subnet.subnet_a.id, aws_subnet.subnet_b.id], count.index)
  vpc_security_group_ids     = [aws_security_group.ssh_http_nodeport.id]
  key_name                   = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
}
