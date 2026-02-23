# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}-main"
  }
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  availability_zone       = var.azs[count.index]
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = merge(
    { Name = "${var.environment}-public-${var.azs[count.index]}" },
    var.public_subnet_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  availability_zone = var.azs[count.index]
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.this.id

  tags = merge(
    { Name = "${var.environment}-private-${var.azs[count.index]}" },
    var.private_subnet_tags
  )
}

resource "aws_subnet" "trusted" {
  count = length(var.trusted_subnets)

  availability_zone = var.azs[count.index]
  cidr_block        = var.trusted_subnets[count.index]
  vpc_id            = aws_vpc.this.id

  tags = merge(
    { Name = "${var.environment}-trusted-${var.azs[count.index]}" },
    var.public_subnet_tags
  )
}

# ------------------------------------------------------------------------------
# Internet Gateway
# ------------------------------------------------------------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ------------------------------------------------------------------------------
# NAT Gateway
# ------------------------------------------------------------------------------

resource "aws_eip" "this" {
  count  = var.is_enable_nat ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count         = var.is_enable_nat ? 1 : 0
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.environment}-natgw"
  }

  depends_on = [aws_internet_gateway.this]
}

# ------------------------------------------------------------------------------
# Routes
# ------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = var.is_enable_nat ? null : aws_internet_gateway.this.id
    nat_gateway_id = var.is_enable_nat ? aws_nat_gateway.this[0].id : null
  }

  tags = {
    Name = "${var.environment}-private"
  }
}

resource "aws_route_table" "trusted" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = var.is_enable_nat ? null : aws_internet_gateway.this.id
    nat_gateway_id = var.is_enable_nat ? aws_nat_gateway.this[0].id : null
  }

  tags = {
    Name = "${var.environment}-trusted"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "trusted" {
  count = length(var.trusted_subnets)

  subnet_id      = aws_subnet.trusted[count.index].id
  route_table_id = aws_route_table.trusted.id
}
