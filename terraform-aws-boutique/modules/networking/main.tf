terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
      # This allows the module to accept the aliases passed from root
      configuration_aliases = [ aws.us_east_1 ]
    }
  }
}

# --- modules/networking/main.tf ---

data "aws_availability_zones" "available" {
  state = "available"
}

# 1. Amazon Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  #internal DNS resolution, Kubernetes service discovery, internal load balancers
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
    Env  = var.environment
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Public Subnets (3 AZs)
# Used for ALB, NAT Gateways, and Bastion
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true   #Any EC2 instance launched inside this subnet will automatically get a public IP address.

  tags = {
    Name                                        = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                    = "1" # Important for EKS ALB Discovery
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"   #These tags allow Amazon Elastic Kubernetes Service to automatically detect subnets.
  }
}

# 4. Private Subnets - App Layer (3 AZs)
# Used for EKS Nodes/Pods (e.g., frontend, checkoutservice)
resource "aws_subnet" "private_app" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                        = "${var.project_name}-private-app-${count.index + 1}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# 5. Private Subnets - Database/Cache Layer (3 AZs)
# Used for Amazon ElastiCache (Redis)
resource "aws_subnet" "private_db" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-db-${count.index + 1}"
  }
}

# 6. NAT Gateways (One per AZ for High Availability)
resource "aws_eip" "nat" {
  count = 3
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count         = 3
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# 7. Route Tables & Associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = 3
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
}

resource "aws_route_table_association" "private_app" {
  count          = 3
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count          = 3
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}