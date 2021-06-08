variable "ami" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

resource "aws_instance" "web" {
  ami                         = var.ami
  subnet_id                   = var.subnet_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = true
  tags                        = var.tags
}

output "aws_instance_output" {
  value = aws_instance.web.id
}
