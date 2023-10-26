 

## TO DO: create role with admin access > create trust policy to allow user to assume role > specify role_arn in terraform  

###########
#DATA
###########

data "aws_ssm_parameter" "amzn2_linux" {

    name = "/aws/services/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


###########
#RESOURCES
###########



#NETWORKING#


resource "aws_vpc" "app" {

    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
    tags = local.common_tags
}


resource "aws_internet_gateway" "app" {

    vpc_id = aws_vpc.app.id

}

resource "aws_subnet" "public_subnet1" {

    cidr_block = var.vpc_public_subnet1_cidr
    vpc_id = aws_vpc.app.id
    map_public_ip_on_launch = var.map_public_ip
}

# ROUTING $

resource "aws_route_table" "app" {

    vpc_id  = aws_vpc.app.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.app.id
    }
}

resource "aws_route_table_association" "app_subnet1" {

    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS
# Nginx security group 

resource "aws_security_group" "nginx_sg" {

    name = "nginx_sg"
    vpc_id = aws_vpc.app.id
    
    # HTTP access from anywhere
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]    
    }
    
    # outbound internet access
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"] 
    }
}

# INSTANCES #

resource "aws_instance" "nginx1" {

    ami = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
    instance_type = var.aws_instance_sizes["small"]
    subnet_id = aws_subnet.public_subnet1.id
    vpc_security_group_ids = [aws_security_group.nginx_sg.id]
    tags = local.common_tags
    
    user_data <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras install -y nginx
    sudo service nginx start
    sudo rm /usr/share/nginx/html/index.html
    echo "<html><head><title>Production Server</title></head><body>This is a prodServer</body></html>" > /usr/share/nginx/html/index.html
    EOF

}

