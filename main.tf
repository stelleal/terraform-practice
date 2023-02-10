resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    env_prefix = var.env_prefix
    subnet_cidr_blocks = var.subnet_cidr_blocks
    avail_zone = var.avail_zone
    vpc_id = aws_vpc.myapp-vpc.id
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-webserver" {
    source = "./modules/webserver"
    env_prefix = var.env_prefix
    devops_team_ips = var.devops_team_ips
    subnet_id = module.myapp-subnet.subnet.id
    vpc_id = aws_vpc.myapp-vpc.id
    avail_zone = var.avail_zone
    ec2_instance_type = var.ec2_instance_type
}