resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

// "10.0.0.0/24", "10.0.1.0/24"
resource "aws_subnet" "public" {
  for_each = local.first_two_azs_set

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.first_two_azs_list, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-${each.key}"
    Environment = var.environment
    Type        = "public"
  }
}

// "10.0.10.0/24" etc
resource "aws_subnet" "private_app" {
  for_each = local.first_two_azs_set

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(local.first_two_azs_list, each.key) + 10)
  availability_zone = each.key

  tags = {
    Name        = "${var.project_name}-private-app-subnet-${each.key}"
    Environment = var.environment
    Type        = "private-app"
  }
}

resource "aws_subnet" "private_db" {
  for_each = local.first_two_azs_set

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(local.first_two_azs_list, each.key) + 20)
  availability_zone = each.key

  tags = {
    Name        = "${var.project_name}-private-db-subnet-${each.key}"
    Environment = var.environment
    Type        = "private-db"
  }
}

resource "aws_eip" "nat" {
  for_each = local.first_two_azs_set
  
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip-${each.key}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public
  
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name        = "${var.project_name}-nat-gateway-${each.key}"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  for_each = local.first_two_azs_set
  
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name        = "${var.project_name}-private-rt-${each.key}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}