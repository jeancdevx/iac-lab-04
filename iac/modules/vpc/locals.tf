locals {
  public_subnets = {
    for index, cidr in var.public_subnet_cidrs : tostring(index) => {
      cidr = cidr
      az   = var.availability_zones[index]
      name = "${var.name_prefix}-public-${index + 1}"
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs : tostring(index) => {
      cidr = cidr
      az   = var.availability_zones[index]
      name = "${var.name_prefix}-private-${index + 1}"
    }
  }

  nat_gateway_keys = var.single_nat_gateway ? ["0"] : keys(local.public_subnets)

  common_tags = merge(var.tags, {
    Name = var.name_prefix
  })
}
