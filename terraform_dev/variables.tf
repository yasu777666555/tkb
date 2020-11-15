variable "prefix" {
  description = "prefix"
  type        = string
  default     = "dev-"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.0.0.0/16"
}

variable "public_subnets" {
  default = {
    subnets = {
      subnet1 = {
        availability_zone = "ap-northeast-1a"
        cidr              = "192.0.1.0/24"
      }
      subnet2 = {
        availability_zone = "ap-northeast-1c"
        cidr              = "192.0.2.0/24"
      }
    }
  }
}

variable "private_subnets" {
  default = {
    subnets = {
      subnet1 = {
        availability_zone = "ap-northeast-1c"
        cidr              = "192.0.3.0/24"
      }
    }
  }
}

variable "bastion" {
  default = {
    instance = {
      ami           = "ami-0cfa3caed4b487e77"
      instance_type = "t2.micro"
      key_name      = "aws_key"
    }
  }
}

variable "teetotaller" {
  default = {
    instance = {
      ami           = "ami-0cfa3caed4b487e77"
      instance_type = "t2.micro"
      key_name      = "aws_key"
    }
  }
}

variable "route53_zone" {
  default = "takebaya.com"
}

variable "domain_name" {
  description = "subdomain part"
  default     = "dev"
}
