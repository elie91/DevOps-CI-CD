locals {
  availability_zone = "${data.aws_region.current.name}${var.availability_zone_suffix}"
}
