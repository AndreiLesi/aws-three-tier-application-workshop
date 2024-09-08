module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.0.0.0/16"

  azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24", "10.0.153.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
  }

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_name      = "${local.name}-default"
  manage_default_route_table    = true
  default_route_table_name      = "${local.name}-default"
  manage_default_security_group = true
  default_security_group_name   = "${local.name}-default"
}