/*
   Copyright 2024 Julien FOURET

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

# This role is separated in case where a VPC with paid ressources such as NAT are
# used 

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_string

  tags = {
    Name = "${var.prefix}-main-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}-main-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, length(data.aws_availability_zones.available.names) + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-subnet-private-${count.index}"
  }
}

resource "aws_eip" "nat" {
  count = var.network_type == "private" ? (var.only_one_nat ? 1 : length(data.aws_availability_zones.available.names)) : 0
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = var.network_type == "private" ? (var.only_one_nat ? 1 : length(data.aws_availability_zones.available.names)) : 0
  allocation_id = aws_eip.nat[count.index].id
  connectivity_type = "public"
  subnet_id     = aws_subnet.public[count.index].id
  depends_on = [aws_subnet.public, aws_internet_gateway.gw]

  tags = {
    Name = "nat-gateway-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.network_type == "private" ? (var.only_one_nat ? 1 : length(data.aws_availability_zones.available.names)) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "private-route-table-${count.index}"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.network_type == "private" ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.only_one_nat ? 0 : count.index].id
}

resource "aws_security_group" "ecs_batch_sg" {
  name        = "${var.prefix}_sg"
  description = "Security group for ECS/AWS Batch"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "${var.prefix}_sg"
  }
}
