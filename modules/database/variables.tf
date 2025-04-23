variable "private_subnets" {
  description = "Private subnets for RDS subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID of the backend tier allowed to access RDS"
  type        = string
}


