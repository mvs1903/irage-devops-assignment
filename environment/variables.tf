variable "vpcs" {
  type = map(object({
    name               = string
    cidr               = string
    availability_zones = list(string)
    public_subnets     = list(string)
    private_subnets    = list(string)
    tags               = map(string)
  }))
}
variable "security_groups" {
  type = map(object({
    name            = string
    description     = string
    vpc_key         = string
    ingress_rules   = list(string)
    ingress_cidr    = string
    egress_rules    = list(string)
    tags            = map(string)
  }))
}


variable "bastion_vm" {
  type = map(object({
    name               = string
    # ami_id             = string
    instance_type      = string
    key_name           = string
    my_ip              = string
    sg_key=string
    vpc_key            = string
    tags=map(string)
  }))
}

variable "rds_inst" {
  type = map(object({
    identifier              = string
    engine                  = string
    engine_version          = string
    family=string
    instance_class          = string
    allocated_storage       = number
    db_name                 = string
    port                    = number
    secret_name             = string
    sg_key=string
    vpc_key                 = string
    # bastion_key             = string
    tags=map(string)
  }))
}


