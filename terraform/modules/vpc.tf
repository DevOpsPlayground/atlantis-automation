################################################################################
# Local resources
################################################################################
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

################################################################################
# Data resources
################################################################################
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

################################################################################
# VPC
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                  = "${var.project}-vpc"
  cidr                  = var.cidr_block
  enable_dns_hostnames  = true
  enable_dns_support    = true
  instance_tenancy      = "default"

  azs                                           = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  map_public_ip_on_launch                       = true
  public_subnets                                = [for x, y in local.azs : cidrsubnet(var.cidr_block, 3, x)]
  private_subnets                               = [for x, y in local.azs : cidrsubnet(var.cidr_block, 3, x + 3)]
  enable_nat_gateway                            = true
  single_nat_gateway                            = true
  default_security_group_name                   = data.aws_security_group.default.name
  manage_default_security_group                 = true
  default_security_group_egress                 = []
  default_security_group_ingress                = []
  default_route_table_name                      = "${var.project}-default-route-table"
  create_igw                                    = true

  private_subnet_names                          = ["${var.project}-private-subnet-one", "${var.project}-private-subnet-two", "${var.project}-private-subnet-three"]
  public_subnet_names                           = ["${var.project}-public-subnet-one", "${var.project}-public-subnet-two", "${var.project}-public-subnet-three"]
  
  # Name Tags
  default_route_table_tags                      = { Name = "${var.project}-default-route-table"}
  default_security_group_tags                   = { Name = "${var.project}-default-security-group" }
  igw_tags                                      = { Name = "${var.project}-internet-gateway" }
  nat_gateway_tags                              = { Name = "${var.project}-nat-gateway" }
  public_route_table_tags                       = { Name = "${var.project}-public-route-table" }
  private_route_table_tags                      = { Name = "${var.project}-private-route-table" }
  
}