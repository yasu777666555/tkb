provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# VPC Settings
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${var.prefix}tkb_dev"
  }
}

resource "aws_subnet" "public_subnets" {
   count = length(var.public_subnets.subnets)
   cidr_block = values(var.public_subnets.subnets)[count.index].cidr
   availability_zone = values(var.public_subnets.subnets)[count.index].availability_zone
   vpc_id            = aws_vpc.vpc.id

   tags = {
     Name = "${var.prefix}tkb_public_subnet${count.index}"
   }
}

resource "aws_subnet" "private_subnets" {
   count = length(var.private_subnets.subnets)
   cidr_block = values(var.private_subnets.subnets)[count.index].cidr
   availability_zone = values(var.private_subnets.subnets)[count.index].availability_zone
   vpc_id            = aws_vpc.vpc.id

   tags = {
     Name = "${var.prefix}tkb_private_subnet${count.index}"
   }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}tkb_internet_gw"
  }
}

resource "aws_route_table" "public_subnet_routes" {
  count = length(var.public_subnets.subnets)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}tkb_public_subnet_route${count.index}"
  }
}

resource "aws_route_table" "private_subnet_routes" {
  count = length(var.private_subnets.subnets)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}tkb_private_subnet_route${count.index}"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets.subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_subnet_routes[count.index].id
}

resource "aws_route_table_association" "private" {
count = length(var.private_subnets.subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_subnet_routes[count.index].id
}

resource "aws_route" "public" {
  count = length(var.public_subnets.subnets)
  route_table_id         = aws_route_table.public_subnet_routes[count.index].id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "private" {
  count = length(var.private_subnets.subnets)
  route_table_id         = aws_route_table.private_subnet_routes[count.index].id
  nat_gateway_id         = aws_nat_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

# Security Group Settings
resource "aws_security_group" "allow_ssh" {
  name        = "${var.prefix}allow_ssh"
  description = "allow ssh from anywhere"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}allow_ssh"
  }
}

resource "aws_security_group" "allow_https_from_anywhere" {
  name        = "${var.prefix}allow_https_from_anywhere"
  description = "allow https from internet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTPS from public subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}allow_https"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "${var.prefix}allow_http"
  description = "allow http from public subnet"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from public subnet"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [
      aws_security_group.allow_ssh.id,
      aws_security_group.allow_https_from_anywhere.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}allow_http_from_lb"
  }

  depends_on = [
    aws_security_group.allow_ssh,
    aws_security_group.allow_https_from_anywhere
  ]
}

resource "aws_security_group" "allow_ssh_from_bastion" {
  name        = "${var.prefix}allow_ssh_from_bastion"
  description = "allow ssh from bastion"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}allow_ssh_from_bastion"
  }
}

# EC2
resource "aws_instance" "bastion" {
  ami                    = var.bastion.instance.ami
  instance_type          = var.bastion.instance.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  key_name               = var.bastion.instance.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "${var.prefix}tkb_bastion"
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.bastion.id
}

resource "aws_instance" "teetotaller" {
  ami                    = var.teetotaller.instance.ami
  instance_type          = var.teetotaller.instance.instance_type
  subnet_id              = aws_subnet.private_subnets[0].id
  key_name               = var.teetotaller.instance.key_name
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh_from_bastion.id]

  tags = {
    Name = "${var.prefix}teetotaller"
  }
}

# Application LoadBalancer
#locals {
#    public_subnet_ids = tolist(aws_subnet.public_subnets.*.id)
#}

resource "aws_lb" "lb" {
  name               = "${var.prefix}external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_https_from_anywhere.id]
  subnets = tolist(aws_subnet.public_subnets.*.id)

  tags = {
    Name = "${var.prefix}teetotaller_lb"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.prefix}external-lb-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval = 30
    path     = "/sample"
    port     = 8000
    protocol = "HTTP"
    timeout  = 5
    matcher  = 301
  }
}

resource "aws_lb_target_group_attachment" "tg" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.teetotaller.id
  port             = 8000
}

resource "aws_lb_listener" "external_lb" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.www.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

data "aws_route53_zone" "selected" {
  name = var.route53_zone
}

resource "aws_acm_certificate" "www" {
  domain_name       = "${var.domain_name}.${data.aws_route53_zone.selected.name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "www" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "www" {
  certificate_arn         = aws_acm_certificate.www.arn
  validation_record_fqdns = [for record in aws_route53_record.www : record.fqdn]
}

resource "aws_route53_record" "external_lb" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.domain_name}.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
