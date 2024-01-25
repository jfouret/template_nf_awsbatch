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

module "awsbatch_user" {
  source = "./modules/nf_awsbatch_user"
  aws_region = "eu-west-3"
  prefix     = "nf_awsbatch"
}

module "awsbatch_image" {
  source = "./modules/nf_awsbatch_image"
  aws_region = "eu-west-3"
  prefix     = "nf_awsbatch"
}

module "awsbatch_network" {
  source = "./modules/nf_awsbatch_network"
  aws_region = "eu-west-3"
  prefix     = "nf_awsbatch"
  network_type = "private"
}

module "awsbatch_batch" {
  source = "./modules/nf_awsbatch_batch"
  aws_region = "eu-west-3"
  prefix     = "nf_awsbatch"
  ami_for_batch = module.awsbatch_image.image
  sg_ids = [module.awsbatch_network.sg_id]
  subnet_ids = module.awsbatch_network.subnet_ids_for_batch
}

output "subnets" {
  value = module.awsbatch_network.subnet_ids_for_batch
}

output "sg" {
  value = module.awsbatch_network.sg_id
}

output "image" {
  value = module.awsbatch_image.image
}
