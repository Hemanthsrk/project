Provider configuration for AWS
provider "aws" {
  access_key = "access key in aws"
  secret_key = " secret key in aws"
  region = "ap-south-1"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Declare the main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "subnet-${count.index}"
  }
}
# Create an RDS Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
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
    Name = "rds-sg"
  }
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.subnet[*].id
}

# Create RDS Instance
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "14.7"
  instance_class       = "db.t2.medium"
  identifier           = "my-postgres-db"
  username             = "admin"
  password             = var.db_password
  db_name              = "mydatabase"
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.id
  skip_final_snapshot  = true

  tags = {
    Name = "postgres-db"
  }
}

# Create Security Group for Minikube EC2 instance
resource "aws_security_group" "minikube_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "minikube-security-group"
  }
}

# Create EC2 Instance for Minikube
resource "aws_instance" "minikube" {
  ami             = "ami-03753afda9b8ba740" # Amazon Linux 2 AMI
  instance_type   = "t3.micro"
  associate_public_ip_address = true
  subnet_id       = aws_subnet.subnet[0].id
  vpc_security_group_ids = [aws_security_group.minikube_sg.id]
  key_name        = "DEVOPS"

  tags = {
    Name = "minikube-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo install minikube-linux-amd64 /usr/local/bin/minikube",
      "minikube start --driver=docker"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/home/ec2-user/.ssh/id_rsa")
      host        = self.public_ip  # Ensure this references the EC2 instance's public IP
    }

   }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create a Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route-table"
  }
}

# Create a route to allow internet access
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

  # Associate the Route Table with the Public Subnet
resource "aws_route_table_association" "public_association" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


# Declare the db_password variable
variable "db_password" {
  description = "The password for the RDS database"
  type        = string
}

                           
