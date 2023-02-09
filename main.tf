provider "aws" {
    region = var.region
}

## MAIN VARIABLES ##
variable region {}
variable env_prefix {}
# variable project_name {}
variable devops_team_ips {
    type = list(string)
}

variable vpc_cidr_blocks {}
variable subnet_cidr_blocks {}
variable avail_zone {}
variable ec2_instance_type {}
# variable public_key_location {}
variable private_key_location {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_blocks
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_blocks
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_default_route_table" "myapp-default-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name = "${var.env_prefix}-default-rtb"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_security_group" "myapp-default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id
    
    ingress {
        description = "Allow ssh from specific IP"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = var.devops_team_ips
    }
    ingress {
        description = "Allow all inbound traffic from port 8080"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "amazon-linux-img-latest" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami" {
  value = data.aws_ami.amazon-linux-img-latest.id
}

output "aws_ec2_public_ip" {
  value = aws_instance.myapp-ec2.public_ip
}

# resource "aws_key_pair" "ssh-key" {
#     key_name = "server-key"
#     public_key = file(var.public_key_location)
# }

resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.amazon-linux-img-latest.id
    instance_type = var.ec2_instance_type
    key_name = "server-key-pair"

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true

    # user_data = file("entry-script.sh")

    # Just don't use provisioners
    # connection {
    #     type = "ssh"
    #     host = self.public_ip
    #     user = "ec2-user"
    #     private_key = file(var.private_key_location)
    # }

    # provisioner "file" {
    #     source = "entry-script.sh"
    #     destination = "/home/ec2-user/entry-script.sh"
    # }

    # provisioner "remote-exec" {
    #     script = file("entry-script.sh")
    # }

    tags = {
        Name = "${var.env_prefix}-server-ec2"
    }
}