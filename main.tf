provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket  = "tfstatebucketdd23"
    key     = "tfstate/terraform.tfstate"
    region  = "us-east-1"
    dynamodb_table = "terraform_state"
  }
}

module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  access_ip     = var.access_ip
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

module "ec2_asg" {
  source         = "./ec2_asg"
  public_sg      = module.vpc.public_sg
  private_sg     = module.vpc.private_sg
  private_subnet = module.vpc.private_subnet
  public_subnet  = module.vpc.public_subnet
  elb            = module.elb.elb
  alb_tg         = module.elb.alb_tg
  key_name       = "webappkey"
}

module "elb" {
  source        = "./elb"
  public_subnet = module.vpc.public_subnet
  vpc_id        = module.vpc.vpc_id
  web_sg        = module.vpc.web_sg
  database_asg  = module.ec2_asg.database_asg
}

module "s3" {
  source        = "./s3"
}