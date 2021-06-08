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

module "instance" {
  source                 = "./modules/my_instance_module"
  ami                    = "ami-02297540444991cc0"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  tags = {
    Name = "elie.bismuth"
    User = "elie.bismuth"
    TP   = "TP5"
  }
}

output "web_from_module" {
  value = module.instance.aws_instance_output
}

