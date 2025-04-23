provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "frontend" {
  source           = "./modules/frontend"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  bastion_sg_id = module.sg.backend_sg_id
  nginx_sg_id = module.sg.nginx_sg_id
  
}

module "backend" {
  source           = "./modules/backend"
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  nginx_sg_id      = module.sg.nginx_sg_id
  backend_sg_id    = module.sg.backend_sg_id
  
}

module "database" {
  source          = "./modules/database"
  private_subnets = module.vpc.private_subnet_ids
  vpc_id          = module.vpc.vpc_id
  backend_sg_id   = module.backend.backend_sg_id
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

