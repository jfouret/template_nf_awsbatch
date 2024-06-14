/*
   Copyright 2024 Julien FOURET

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

terraform {
  backend "s3" {
    region = "eu-west-3"
    bucket = "tfstate.test-awsbatch"
    key    = "terraform.tfstate"
  }
}

provider "tls" {
}

module "awsbatch_network" {
  source = "./modules/nf_awsbatch_network"
  aws_region = "eu-west-3"
  prefix     = var.prefix
  network_type = "private"
}

module "awsbatch_batch" {
  source = "./modules/nf_awsbatch_batch"
  aws_region = "eu-west-3"
  prefix     = var.prefix
  sg_ids = [module.awsbatch_network.sg_id]
  compute_resources_max_vcpus = 192
  subnet_ids = module.awsbatch_network.subnet_ids_for_batch
}

output "subnets" {
  value = module.awsbatch_network.subnet_ids_for_batch
}

output "sg" {
  value = module.awsbatch_network.sg_id
}

resource "tls_private_key" "rsa-4096-example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "private_key" {
  content = tls_private_key.example.private_key_pem
  filename          = "./generated_key.pem"
  file_permission   = "0600"
}

resource "local_sensitive_file" "private_key_batch" {
  content = module.awsbatch_batch.private_key_pem
  filename          = "generated_key_for_batch.pem"
  file_permission   = "0600"
}

module "awsbatch_session" {
  source = "./modules/nf_awsbatch_session"
  aws_region = "eu-west-3"
  prefix     = var.prefix
  subnet_id = module.awsbatch_network.public_subnet_ids[0]
  public_key = tls_private_key.example.public_key_openssh
  job_queue = module.awsbatch_batch.job_queue_name
  env_bucket_name = var.new_tmp_bucket_for_env
}

output "public_ip" {
  value = module.awsbatch_session.ip
}
