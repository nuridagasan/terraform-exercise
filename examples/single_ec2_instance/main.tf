/*
* Author: Nuri Dagasan
* Date: 19/09/2022 17:13
* Note: Create a single EC2 instance with a security group
*/

# Set the cloud provider and the region
provider "aws" {
  region = "us-east-2"
}

# Create a EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  # Give a reference to security group
  vpc_security_group_ids = [aws_security_group.web_server.id]

  # Exucute shell script for first boot
  # EOF, hdc syntax, allows to create multiline strings
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # If the user_data parameter changes, terraform terminates the
  # original instance and create a new one. Since user_data is only 
  # executed during boot process, a new instance is required
  user_data_replace_on_change = true

  tags = {
    Name = "ubuntu-web-server"
  }

}

# Create a security group to allow inbound TCP traffic on port 8080
# outbound any IP
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

# Get public IP of web server instance
output "public_ip" {
  value = aws_instance.web_server.public_ip
  description = "The public IP address of the web server"
}
