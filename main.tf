resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name = "ec2-login"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "my-sg" {
    name = "my-sg"
    vpc_id = "vpc-00248bff5164100af"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}
resource "aws_instance" "instance_1a" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install apache2 -y
                sudo systemctl start apache2
                sudo rm -rf /var/www/html/index.html
                sudo echo '<!DOCTYPE html>
                <html>
                <head>
                  <title>terraform example</title>
                  <style>
                    body {
                      font-family: Arial, sans-serif;
                      text-align: center;
                      margin-top: 50px;
                    }
                    h1 {
                      color: blue;
                    }
                  </style>
                </head>
                <body>
                  <h1>Welcome to the web page of Harsha terraform</h1>
                </body>
                </html>' > /var/www/html/index.html
                EOF
    lifecycle {
      create_before_destroy = true
    }
    tags = {
      "Name" = "instance_blue" 
    }
}
resource "aws_instance" "instance_1b" {
    ami = "ami-084568db4383264d4"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install apache2 -y
                sudo systemctl start apache2
                sudo rm -rf /var/www/html/index.html
                sudo echo '<!DOCTYPE html>
                <html>
                <head>
                  <title>terraform example</title>
                  <style>
                    body {
                      font-family: Arial, sans-serif;
                      text-align: center;
                      margin-top: 50px;
                    }
                    h1 {
                      color: green;
                    }
                  </style>
                </head>
                <body>
                  <h1>Welcome to the web page of Harsha terraform</h1>
                </body>
                </html>' > /var/www/html/index.html
                EOF
    lifecycle {
      create_before_destroy = true
    }
    tags = {
      "Name" = "instance_green" 
    }
}
output "instance_1a_public_ip" {
    value = aws_instance.instance_1a.public_ip
  
}
output "instance_1b_public_ip" {
    value = aws_instance.instance_1b.public_ip
  
}

resource "local_sensitive_file" "pem_file" {
  filename = pathexpand("./instance_login.pem")
  file_permission = "600"
  directory_permission = "700"
  content = tls_private_key.ssh_key.private_key_pem
}
