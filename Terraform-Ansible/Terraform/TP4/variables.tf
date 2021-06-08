variable "user" {
  type = string
}

variable "tp" {
  type = string
}

variable "subnet_cidr_block" {
  type = string
}

variable "availability_zone_suffix" {
  type = string
}

variable "number_of_instances" {
  type = number
}

variable "ingress_ports" {
  type = list(string)
}
