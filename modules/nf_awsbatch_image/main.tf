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
}

resource "aws_imagebuilder_component" "install_awscli" {
  name     = "${var.prefix}-install-awscli"
  version  = "1.0.0"
  platform = "Linux"

  data = <<EOF
{
  "schemaVersion": "1.0",
  "phases": [
    {
      "name": "build",
      "steps": [
        {
          "name": "InstallAWSCLI",
          "action": "ExecuteBash",
          "inputs": {
            "commands": [
              "yum install -y awscli bzip2 wget java-21-amazon-corretto-headless vim",
              "wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm",
              "yum install -y ./mount-s3.rpm",
              "rm ./mount-s3.rpm",
              "mount-s3 --version",
              "wget -qO- https://get.nextflow.io | bash",
              "mv nextflow /usr/local/bin/",
              "chmod o+rx /usr/local/bin/nextflow"
            ]
          }
        }
      ]
    }
  ]
}
EOF

  change_description = "Initial version"
}

resource "aws_iam_role" "imagebuilder_role" {
  name = "${var.prefix}-imagebuilder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "imagebuilder_instance_profile" {
  name = "${var.prefix}-imagebuilder-instance-profile"
  role = aws_iam_role.imagebuilder_role.name
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

resource "aws_iam_role_policy_attachment" "policy_attachment2" {
  role       = aws_iam_role.imagebuilder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Image recipe
resource "aws_imagebuilder_image_recipe" "ecs_ami_recipe" {
  name            = "${var.prefix}-ecs-ami-recipe"
  parent_image    = var.base_ami
  version         = "1.0.0"
  component {
    component_arn = aws_imagebuilder_component.install_awscli.arn
  }
  block_device_mapping {
    device_name = var.device_name
    ebs {
      delete_on_termination = true
      volume_size           = var.volume_size
      volume_type           = "gp3"
    }
  }
}

# Generate outputs for the following module
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key" {
  key_name = "${var.prefix}_create_ami_key"
  public_key = tls_private_key.key.public_key_openssh
}

# Infrastructure configuration
resource "aws_imagebuilder_infrastructure_configuration" "ecs_ami_infra" {
  instance_profile_name = aws_iam_instance_profile.imagebuilder_instance_profile.name
  name = "${var.prefix}-ecs-ami"
  instance_types = ["t3.medium"]
  key_pair = aws_key_pair.key.key_name
}

# Distribution configuration
resource "aws_imagebuilder_distribution_configuration" "ecs_ami_distribution" {
  name = "${var.prefix}-ecs-ami-distribution"

  distribution {
    region = var.aws_region

    ami_distribution_configuration {
      name = "${var.prefix}-ecs-ami-{{ imagebuilder:buildDate }}"
    }
  }
}

# Image pipeline
resource "aws_imagebuilder_image_pipeline" "ecs_ami_pipeline" {
  name                   = "${var.prefix}-ecs-ami-pipeline"
  image_recipe_arn       = aws_imagebuilder_image_recipe.ecs_ami_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.ecs_ami_infra.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.ecs_ami_distribution.arn
  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
  }
  status = "ENABLED"
}

resource "aws_imagebuilder_image" "image" {
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.ecs_ami_distribution.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.ecs_ami_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.ecs_ami_infra.arn
}
