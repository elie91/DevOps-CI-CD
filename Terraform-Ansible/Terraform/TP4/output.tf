output "web" {
  value = aws_instance.web.public_ip
}

/* output "web_slave" {
  value = aws_instance.web_slave[*].public_ip
} */
