provider "aws" {
  region = "ap-south-1"  # Replace with your desired region
}

resource "aws_instance" "kong_instance" {
  ami           = "ami-03f4878755434977f"  # Replace with a suitable AMI ID
  instance_type = "t3.medium"  # Choose an appropriate instance type
  key_name      = "davinder-xs.pem"  # Replace with your key pair
  subnet_id    = "subnet-05f780e3d3fccea74"
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo usermod -aG docker ubuntu
              docker pull kong:latest
              docker run -d --name kong \
                --network=host \
                -e "KONG_DATABASE=off" \
                -e "KONG_DECLARATIVE_CONFIG=/etc/kong/kong.yml" \
                -v /path/to/your/kong.yml:/etc/kong/kong.yml \
                kong:latest
              EOF

  tags = {
    Name = "kong-instance"
  }
}

resource "aws_security_group" "kong_security_group" {
  name        = "kong-security-group"
  description = "Allow incoming traffic on port 8000 and 8001"

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8001
    to_port   = 8001
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_network_interface_sg_attachment" "kong_sg_attachment" {
#  security_group_id    = aws_security_group.kong_security_group.id
#  network_interface_id = aws_instance.kong_instance.network_interface_ids[0]
#}

