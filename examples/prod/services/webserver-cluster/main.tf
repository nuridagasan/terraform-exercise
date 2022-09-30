provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "version-control-tfstate-file"
  db_remote_state_key    = "prod/services/webserver-cluster/terraform.tfstate"

  instance_type    = "t2.micro"

  min_size         = 1
  desired_capacity = 2
  min_size         = 5 
}