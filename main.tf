/*
* Author: Nuri Dagasan
* Date: 19/09/2022 17:13
* Note: Create EC2 instance with ASG
*/

# Set the cloud provider and the region.
provider "aws" {
  region = "us-east-2"
}

# Create an ASG launch configuration
resource "aws_launch_configuration" "web_server" {
  image_id        = "ami-0fb653ca2d3203ac1"
  instance_type   = "t2.micro"

  # Give a reference to security group.
  security_groups = [aws_security_group.web_server.id]

  # Exucute shell script for first boot
  # EOF, hdc syntax, allows to create multiline strings
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

# Create an ASG.
resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = aws_launch_configuration.web_server.name
  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value               = "web-server-asg"
    propagate_at_launch = true
  }
}

# Create a security group to allow inbound TCP traffic on port 8080
# outbound any IP.
resource "aws_security_group" "web_server" {
  name = "web-server-sg"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# Create a variable for DRY principle
variable "server_port" {
  description = "The server port will use for HTTP requests"
  type = number
  default = 8080
}

# Read information about the default VPC from AWS
data "aws_vpc" "default" {
  default = true
}

# Look up the subnets within that VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}