module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "http port"
      cidr_blocks = var.whitelisted_ip
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "https port"
      cidr_blocks = var.whitelisted_ip
    },
    {
      from_port   = 4141
      to_port     = 4141
      protocol    = "tcp"
      description = "atlantis event port"
      cidr_blocks = var.whitelisted_ip
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh port"
      cidr_blocks = var.whitelisted_ip
    },
    {
      from_port   = 4000
      to_port     = 4000
      protocol    = "tcp"
      description = "atlantis port"
      cidr_blocks = var.whitelisted_ip
    }
  ]
  egress_rules        = ["all-all"]

  tags = {
    Name = "${var.security_group_nametag}"
  }
}