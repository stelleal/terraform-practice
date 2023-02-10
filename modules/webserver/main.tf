resource "aws_default_security_group" "myapp-default-sg" {
    vpc_id = var.vpc_id
    
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

resource "aws_instance" "myapp-ec2" {
    ami = data.aws_ami.amazon-linux-img-latest.id
    instance_type = var.ec2_instance_type
    key_name = "server-key-pair"

    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_default_security_group.myapp-default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true

    # Executes the script on the EC2 instance when it is created - only once
    user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server-ec2"
    }
}