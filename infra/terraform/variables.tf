variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_a_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  default = "10.0.2.0/24"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_ami" {
  description = "AMI for EC2 instances"
  default     = "ami-020cba7c55df1f615" # Ubuntu
}

variable "instance_type" {
  default = "t2.micro"
}
