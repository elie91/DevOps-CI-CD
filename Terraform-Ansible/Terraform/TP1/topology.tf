# Création d'une instance
resource "aws_instance" "web" {
  ami           = "ami-0e3f7a235a05f8e99"
  instance_type = "t2.micro"

  tags = {
    Name      = "elie.bismuth"
    Formation = "terraform"
    TP        = "TP1"
  }
}
