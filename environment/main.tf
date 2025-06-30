# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 6.0"
#     }
#   }
# }


# module "vpc" {
#   for_each = var.vpcs

#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"


#   name = each.value.name
#   cidr = each.value.cidr

#   azs             = each.value.availability_zones
#   public_subnets  = each.value.public_subnets
#   private_subnets = each.value.private_subnets

#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = each.value.tags
# }



# module "security_groups" {
#   for_each = var.security_groups

#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git"

#   name        = each.value.name
#   description = each.value.description
#   vpc_id      = module.vpc[each.value.vpc_key].vpc_id

#   ingress_cidr_blocks = [each.value.ingress_cidr]
#   ingress_rules       = each.value.ingress_rules
#   egress_rules        = each.value.egress_rules

#   tags = each.value.tags
# }


# module "bastion" {
#   for_each = var.bastion_vm

#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"


#   name           = each.value.name
#   ami            = data.aws_ami.ubuntu.id
#   instance_type  = each.value.instance_type
#   key_name       = each.value.key_name

#   subnet_id              = module.vpc[each.value.vpc_key].public_subnets[0]
#   vpc_security_group_ids = [module.bastion_sg[each.key].security_group_id]
#   associate_public_ip_address = true

#   user_data = file("./bastion-user.sh")

#   tags = each.value.tags
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
# }
  

# data "aws_secretsmanager_secret_version" "rds_creds" {
#   for_each  = var.rds
#   secret_id = each.value.secret_name
# }

# locals {
#   rds_credentials = tomap({
#     for k, v in var.rds :
#     k => jsondecode(data.aws_secretsmanager_secret_version.rds_creds[k].secret_string)
#   })
# }


# module "rds" {
#   for_each = var.rds

#   source  = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git"
  
#   identifier         = each.value.identifier
#   family=each.value.family
#   engine             = each.value.engine
#   engine_version     = each.value.engine_version
#   instance_class     = each.value.instance_class
#   allocated_storage  = each.value.allocated_storage
#   # name               = each.value.db_name
#   username           = local.rds_credentials[each.key].username
#   password           = local.rds_credentials[each.key].password

#   subnet_ids             = module.vpc[each.value.vpc_key].private_subnets
#   vpc_security_group_ids = [module.rds_sg[each.key].security_group_id]
#   publicly_accessible    = false
#   skip_final_snapshot    = true

#   tags = each.value.tags
# }
  
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
      
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc" {
  for_each = var.vpcs

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"

  name = each.value.name
  cidr = each.value.cidr

  azs             = each.value.availability_zones
  public_subnets  = each.value.public_subnets
  private_subnets = each.value.private_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = each.value.tags
}

module "security_groups" {
  for_each = var.security_groups

  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git"

  name        = each.value.name
  description = each.value.description
  vpc_id      = module.vpc[each.value.vpc_key].vpc_id

  ingress_cidr_blocks = [each.value.ingress_cidr]
  ingress_rules       = each.value.ingress_rules
  egress_rules        = each.value.egress_rules

  tags = each.value.tags
}

module "bastion" {
  for_each = var.bastion_vm

  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"

  name           = each.value.name
  ami            = data.aws_ami.ubuntu.id
  instance_type  = each.value.instance_type
  key_name       = each.value.key_name

  subnet_id                  = module.vpc[each.value.vpc_key].public_subnets[0]
  vpc_security_group_ids     = [module.security_groups[each.value.sg_key].security_group_id]
  associate_public_ip_address = true

  user_data = file("./bastion-user.sh")

  tags = each.value.tags
}

data "aws_secretsmanager_secret_version" "rds_creds" {
  for_each  = var.rds_inst
  secret_id = each.value.secret_name
}

locals {
  rds_credentials = tomap({
    for k, v in var.rds_inst :
    k => jsondecode(data.aws_secretsmanager_secret_version.rds_creds[k].secret_string)
  })
}

module "rds_inst" {
  for_each = var.rds_inst

  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git"

  identifier         = each.value.identifier
  family             = each.value.family
  engine             = each.value.engine
  engine_version     = each.value.engine_version
  instance_class     = each.value.instance_class
  allocated_storage  = each.value.allocated_storage
  username           = local.rds_credentials[each.key].username
  password           = local.rds_credentials[each.key].password
  db_name            = each.value.db_name
  port               = each.value.port

  vpc_security_group_ids = [module.security_groups[each.value.sg_key].security_group_id]
  subnet_ids             = module.vpc[each.value.vpc_key].private_subnets
  create_db_subnet_group = false

  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = each.value.tags
}






