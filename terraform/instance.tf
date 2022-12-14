# data "aws_key_pair" "keypair" {
#   name = "1Password Personal SSH"
#   include_public_key = true
# }

resource "aws_instance" "instance" {
  ami = "ami-0db84aebfa8d17e23"
  instance_type = "t4g.small"
  key_name = "1Password Personal SSH"

  root_block_device {
    volume_size = 50
  }
}

resource "aws_eip" "instance_ip" {
  instance = aws_instance.instance.id
  vpc      = true
}

resource "aws_route53_record" "instance_dns" {
  zone_id = aws_route53_zone.zone.zone_id
  name = "matrix.aws.choam.me"
  type = "A"
  ttl = 30
  records = [aws_eip.instance_ip.public_ip]
}

# resource "aws_route53_record" "instance_dns6" {
#   zone_id = aws_route53_zone.zone.zone_id
#   name = "matrix.aws.choam.me"
#   type = "AAAA"
#   records = [aws_instance.instance.public_ip]
# }
