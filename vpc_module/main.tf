
resource "aws_vpc" "devops_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${terraform.workspace}-vpc"
    }
}

resource "aws_subnet" "devops_public_subnet1" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet1_cidr
    availability_zone = var.my_az_region1
    map_public_ip_on_launch = true
    tags = {
        Name = "${terraform.workspace}-public_subnet1"
    }
}

resource "aws_subnet" "devops_public_subnet2" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet2_cidr
    availability_zone = var.my_az_region2
    map_public_ip_on_launch = true
    tags = {
        Name = "${terraform.workspace}-public_subnet2"
    }
  
}

resource "aws_subnet" "devops_private_subnet1" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet3_cidr
    availability_zone = var.my_az_region1
    tags = {
        Name = "${terraform.workspace}-private_subnet1"
    }
}

resource "aws_subnet" "devops_private_subnet2" {
    vpc_id = aws_vpc.devops_vpc.id
    cidr_block = var.subnet4_cidr
    availability_zone = var.my_az_region2
    tags = {
        Name = "${terraform.workspace}-private_subnet2"
    }
}

resource "aws_internet_gateway" "devops_igw" {
    vpc_id = aws_vpc.devops_vpc.id
    tags = {
        Name = "${terraform.workspace}-igw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_igw.id
    }
    tags = {
        Name = "${terraform.workspace}-public_route_table"
    }
}

resource "aws_route_table_association" "assoc1" {
    subnet_id = aws_subnet.devops_public_subnet1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "assoc2" {
    subnet_id = aws_subnet.devops_public_subnet2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "devops_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "devops_natgw" {
    allocation_id = aws_eip.devops_eip.id
    subnet_id = aws_subnet.devops_public_subnet1.id
    tags = {
        Name = "${terraform.workspace}-natgw_name"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.devops_natgw.id
    }
    tags = {
        Name = "${terraform.workspace}-private_route_table"
    }
}

resource "aws_route_table_association" "private_assoc1" {
    subnet_id = aws_subnet.devops_private_subnet1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_assoc2" {
    subnet_id = aws_subnet.devops_private_subnet2.id
    route_table_id = aws_route_table.private_route_table.id
}