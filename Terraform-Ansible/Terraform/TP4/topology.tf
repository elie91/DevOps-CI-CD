resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = local.availability_zone

  tags = {
    Name = "elie.bismuth"
    User = "elie.bismuth"
    TP   = "TP2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.r.id
}

resource "aws_security_group" "my_security_group" {
  name_prefix = "elie.bismuth"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "elie.bismuth"
    User = "elie.bismuth"
    TP   = var.tp
  }

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}


resource "aws_instance" "web" {
  ami                         = "ami-02297540444991cc0"
  subnet_id                   = aws_subnet.my_subnet.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.id
  tags = {
    Name = "elie.bismuth"
    User = "elie.bismuth"
    TP   = "TP2"
  }
}

/* resource "aws_instance" "web_slave" {
  ami                         = "ami-02297540444991cc0"
  subnet_id                   = aws_subnet.my_subnet.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true
  count                       = var.number_of_instances
  depends_on = [
    aws_instance.web
  ]
  tags = {
    Name = "elie.bismuth"
    User = "${var.user}-slave"
    TP   = "TP2"
  }
} */

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

