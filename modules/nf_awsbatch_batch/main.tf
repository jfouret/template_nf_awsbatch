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

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Generate outputs for the following module
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key" {
  key_name = "${var.prefix}_batch_key"
  public_key = tls_private_key.key.public_key_openssh
}

// take 45 s to run
// prefix different from good practice on purpose

data "template_file" "cloud_init" {
  template = file("${path.module}/cloud_init.tpl")

  vars = {
    use_fusion = var.use_fusion
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = true
  
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
}

resource "aws_launch_template" "launch_template" {
  name = "${var.prefix}-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = var.volume_size
      volume_type           = "gp3"
      throughput            = var.volume_throughput
      iops                  = var.volume_iops
    }
  }
  user_data = data.template_cloudinit_config.config.rendered

}

resource "aws_batch_compute_environment" "nf_managed_ec2" {
  depends_on = [aws_iam_role_policy_attachment.aws_batch_service_role] # necessary to destroy related ressources
  compute_environment_name    = "${var.prefix}-managed-ec2-spot"
  compute_resources {
    instance_role = aws_iam_instance_profile.ecs_instance_role.arn
    instance_type = var.instance_type
    max_vcpus      = var.compute_resources_max_vcpus
    min_vcpus      = var.compute_resources_min_vcpus
    security_group_ids = var.sg_ids
    subnets        = var.subnet_ids
    type           = var.compute_resources_type
    spot_iam_fleet_role = aws_iam_role.spot_fleet_role.arn
    ec2_key_pair   = aws_key_pair.key.key_name
    bid_percentage = var.compute_resources_bid_percentage
    allocation_strategy = var.compute_resources_allocation_strategy
    ec2_configuration {
      image_type = "ECS_AL2023" # https://docs.aws.amazon.com/batch/latest/APIReference/API_Ec2Configuration.html
    }
    launch_template{
      launch_template_name = aws_launch_template.launch_template.name
    }
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
}

resource "aws_batch_job_queue" "nf_managed_queue" {
  depends_on = [aws_batch_compute_environment.nf_managed_ec2]
  name = "${var.prefix}-queue"
  state                 = "ENABLED"
  priority              = 1
  compute_environments = [
    aws_batch_compute_environment.nf_managed_ec2.arn
  ]
  lifecycle {
    replace_triggered_by = [
      aws_batch_compute_environment.nf_managed_ec2
    ]
  }
}

