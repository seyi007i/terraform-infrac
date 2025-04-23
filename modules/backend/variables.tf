variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "nginx_sg_id" {}
variable "backend_sg_id" {
  type = string
}
