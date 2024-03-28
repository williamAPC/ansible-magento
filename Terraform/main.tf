# initiate the provider with credentials
provider "aws" {
  region                   = var.region
  shared_credentials_files = ["credentials"]
  profile                  = "terusertest"
}

# create the VPC
resource "aws_vpc" "ansible_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ansible VPC"
  }
}

# create the internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ansible_vpc.id
}

# Creatin an elastic IP to associate with the Nat Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

# Create the Nat gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "Nat GW"
  }
}

# Create the public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ansible_vpc.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public RT"
  }
}


# # Create the private route table
# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.ansible_vpc.id
#   route {
#     cidr_block     = var.all_cidr
#     nat_gateway_id = aws_nat_gateway.nat_gw.id
#   }
#   tags = {
#     Name = "Private RT"
#   }
# }

# Create the public subnet1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.ansible_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = var.availability_zoneA
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet 1"
  }
}

# # Create the public subnet2
# resource "aws_subnet" "public_subnet2" {
#   vpc_id                  = aws_vpc.ansible_vpc.id
#   cidr_block              = var.public_subnet2_cidr
#   availability_zone       = var.availability_zoneB
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "Public subnet 2"
#   }
# }

# # Create the private subnet
# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.ansible_vpc.id
#   cidr_block        = var.private_subnet_cidr
#   availability_zone = var.availability_zoneB

#   tags = {
#     Name = "Private subnet"
#   }
# }

# association public RT with public subnet1
resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

# # association public RT with public subnet2
# resource "aws_route_table_association" "public_association2" {
#   subnet_id      = aws_subnet.public_subnet2.id
#   route_table_id = aws_route_table.public_rt.id
# }

# # association private RT with private subnet
# resource "aws_route_table_association" "private_association" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private_rt.id
# }


# # create Jenkins security group

# resource "aws_security_group" "magento_sg" {
#   name        = "magento SG"
#   description = "Allow ports 80 and 22"
#   vpc_id      = aws_vpc.ansible_vpc.id


#   ingress {
#     description = "magento"
#     from_port   = var.jenkins_port
#     to_port     = var.jenkins_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "ssh"
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "Wodpress SG"
#   }
# }

# create Mysql security group

resource "aws_security_group" "mysql_sg" {
  name        = "MySQL SG"
  description = "Allow ports 22 and 3306"
  vpc_id      = aws_vpc.ansible_vpc.id


  ingress {
    description = "ssh"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "MySQL"
    from_port   = var.mysql_port
    to_port     = var.mysql_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL SG"
  }
}


# create Magento security group

resource "aws_security_group" "magento_sg" {
  name        = "Magento SG"
  description = "Allow ports 22 80 443"
  vpc_id      = aws_vpc.ansible_vpc.id

  ingress {
    description = "ssh"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Magento"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application Magento"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Application Magento SG"
  }
}

# # create Ansible security group

# resource "aws_security_group" "ansible_sg" {
#   name        = "Ansible SG"
#   description = "Allow port 8080 and 22"
#   vpc_id      = aws_vpc.ansible_vpc.id


#   ingress {
#     description = "Ansible"
#     from_port   = var.jenkins_port
#     to_port     = var.jenkins_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "ssh"
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "Ansible SG"
#   }

# }


# # create LoadBalancer security group

# resource "aws_security_group" "lb_sg" {
#   name        = "LoadBalancer SG"
#   description = "Allow ports 80"
#   vpc_id      = aws_vpc.ansible_vpc.id


#   ingress {
#     description = "LoadBalancer"
#     from_port   = var.http_port
#     to_port     = var.http_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "LoadBalancer SG"
#   }
# }


# # Create Network ACLs
# resource "aws_network_acl" "nacl" {
#   vpc_id = aws_vpc.ansible_vpc.id
#   # subnet_ids = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id, aws_subnet.private_subnet.id]

#   egress {
#     protocol   = "tcp"
#     rule_no    = "100"
#     action     = "allow"
#     cidr_block = var.vpc_cidr
#     from_port  = 0
#     to_port    = 0
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "100"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.http_port
#     to_port    = var.http_port
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "101"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.https_port
#     to_port    = var.https_port
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "102"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.ssh_port
#     to_port    = var.ssh_port
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "103"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.jenkins_port
#     to_port    = var.jenkins_port
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "104"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.sonarqube_port
#     to_port    = var.sonarqube_port
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = "105"
#     action     = "allow"
#     cidr_block = var.all_cidr
#     from_port  = var.grafana_port
#     to_port    = var.grafana_port
#   }

#   tags = {
#     Name = "Main NetworkACL"
#   }
# }

# # Create the ECR repository
# resource "aws_ecr_repository" "ecr-repo" {
#   name                 = "dock_repo"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# # Create S3 bucket for storing terraform state
# resource "aws_s3_bucket" "guitests3bucket" {
#   bucket = "guitests3bucket"
#   acl = "private"
#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "Terraform state bucket"
#   }
# }

# data "aws_ami" "amazon-linux-2" {
#   most_recent = true

#   filter {
#     name   = "owner-alias"
#     values = ["amazon"]
#   }

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm*"]
#   }
# }



# Configure the S3 backend
terraform {
  backend "s3" {
    bucket                   = "guitests3bucket"
    key                      = "examAnsible/terraform.tfstate"
    region                   = "eu-west-3"
    shared_credentials_files = ["credentials"]
    profile                  = "terusertest"
  }
}

# Creating the magento instance
resource "aws_instance" "Magento" {
  ami                    = var.ubuntu_ami
  instance_type          = var.micro_instance
  availability_zone      = var.availability_zoneA
  subnet_id              = aws_subnet.public_subnet1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.magento_sg.id]
  # user_data              = file("magento_install.sh")

  tags = {
    Name = "Magento"
  }
}

# Creating the MySQL instance
resource "aws_instance" "Mysql" {
  ami                    = var.ubuntu_ami
  instance_type          = var.micro_instance
  availability_zone      = var.availability_zoneA
  subnet_id              = aws_subnet.public_subnet1.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

  tags = {
    Name = "MySQL"
  }
}

# # Creating the Ansible instance
# resource "aws_instance" "Ansible" {
#   ami                    = var.linux2_ami
#   instance_type          = var.micro_instance
#   availability_zone      = var.availability_zoneA
#   subnet_id              = aws_subnet.public_subnet1.id
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
#   user_data              = file("ansible_install.sh")

#   tags = {
#     Name = "Ansible"
#   }
# }

# # Creating the SonarQube instance
# resource "aws_instance" "Grafana" {
#   ami                    = data.aws_ami.amazon-linux-2.id
#   instance_type          = var.small_instance
#   availability_zone      = var.availability_zoneA
#   subnet_id              = aws_subnet.public_subnet1.id
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.grafana_sg.id]
#   user_data              = file("grafana_install.sh")

#   tags = {
#     Name = "Grafana"
#   }
# }

# # Creating the Launch configuration
# resource "aws_launch_configuration" "app-launch-config" {
#   name            = "app-launch-config"
#   image_id        = var.linux2_ami
#   instance_type   = var.micro_instance
#   key_name        = var.key_name
#   security_groups = [aws_security_group.app_sg.id]

# }



# data "template_file" "install_docker" {
#   template = file("application.sh")
# }


# # Creating the Launch template
# resource "aws_launch_template" "app-launch-temp" {
#   name                   = "app-launch-template"
#   image_id               = data.aws_ami.amazon-linux-2.id
#   instance_type          = var.micro_instance
#   key_name               = var.key_name
#   vpc_security_group_ids = [aws_security_group.app_sg.id]
#   user_data              = base64encode(data.template_file.install_docker.rendered)

# }

# resource "aws_autoscaling_group" "app-asg" {
#   name              = "app-asg"
#   max_size          = 2
#   min_size          = 1
#   desired_capacity  = 2
#   health_check_type = "EC2"


#   launch_template {
#     id      = aws_launch_template.app-launch-temp.id
#     version = "$Latest"
#   }

#   vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
#   target_group_arns   = [aws_lb_target_group.app-target-group.arn]

# }

# resource "aws_lb_target_group" "app-target-group" {
#   name        = "app-taget-group"
#   port        = "80"
#   target_type = "instance"
#   protocol    = "HTTP"
#   vpc_id      = aws_vpc.ansible_vpc.id

# }

# resource "aws_autoscaling_attachment" "autoscaling-attachment" {
#   autoscaling_group_name = aws_autoscaling_group.app-asg.id
#   lb_target_group_arn    = aws_lb_target_group.app-target-group.arn

# }

# resource "aws_lb" "app-lb" {
#   name               = "app-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.lb_sg.id]
#   subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
# }

# resource "aws_lb_listener" "app-listener" {
#   load_balancer_arn = aws_lb.app-lb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app-target-group.arn
#   }
# }