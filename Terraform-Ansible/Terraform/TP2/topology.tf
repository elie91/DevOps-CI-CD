resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

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
    TP   = "TP2"
  }
}

resource "aws_security_group_rule" "my_security_group_rule_out_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}


resource "aws_security_group_rule" "my_security_group_rule_out_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_security_group_rule" "my_security_group_rule_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my_security_group.id
}

resource "aws_instance" "web" {
  ami                         = "ami-02297540444991cc0"
  subnet_id                   = aws_subnet.my_subnet.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "elie.bismuth"
    User = "elie.bismuth"
    TP   = "TP2"
  }
}

output "instance_ip" {
  value = aws_instance.web.*.public_ip
}
