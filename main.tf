terraform {
  required_providers{
    aws = {
        source = "aws"
        version = "~> 5.0"
        }
    }

    backend "s3" {
        bucket         = "demo-eks-state-bucket-kliu"
        key            = "terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "eks-state-locks"
        encrypt        = true         
    }
}
provider "aws"{
    region = "us-east-1"   
}

module "eks"{
    source = "./modules/eks"
    cluster_name = var.cluster_name
    node_groups = var.node_groups
    subnet_ids = module.vpc.private_subnet_id
    cluster_version = var.cluster_version
    vpc_id = module.vpc.vpc_id
}

module "vpc"{
    source = "./modules/vpc"
    cluster_name = var.cluster_name
    availability_zones = var.availability_zones
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
}