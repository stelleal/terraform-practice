module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = "my-vpc"
  cidr = var.vpc_cidr_blocks

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_blocks]
  public_subnet_tags = {
    Name = "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

module "myapp-webserver" {
    source = "./modules/webserver"
    vpc_id = module.vpc.vpc_id
    env_prefix = var.env_prefix
    devops_team_ips = var.devops_team_ips
    subnet_id = module.vpc.public_subnets[0]
    avail_zone = var.avail_zone
    ec2_instance_type = var.ec2_instance_type
}