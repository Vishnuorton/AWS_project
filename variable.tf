//declaring all our variables type and default values 

variable "region" {
  type = string
  default = "ap-south-1"
  description = "region for provision the resources"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  description = "instance type "
}

variable "vpc-cidr-block" {
  type = string
  default = "10.0.0.0/16"
  description = "cidrblock for vpc"
}


variable "production-cidr-block" {
  type = string
  default = "10.0.1.0/24"
  description = "cidrblock for vpc"
}

variable "DR-cidr-block" {
  type = string
  default = "10.0.2.0/24"
  description = "cidrblock for vpc"
}

variable "production_AZ" {
  type = string
  default = "ap-south-1a"
  description = "availabilty zone for production instance"
}

variable "DR_AZ" {
  type = string
  default = "ap-south-1b"
  description = "availabilty zone for DR instance"
}

variable "bucket_name" {
  type = string
  description = "bucket name"
}

variable "db_instance_type" {
  type = string
  default = "db.t2.micro"
  description = "instance type for your mysql db"
}

variable "db_username" {
  type = string
  default = "prod"
  description = "database username"
}

variable "db_password" {
  type = string
  default = "prod12345"
  description = "database password"
}