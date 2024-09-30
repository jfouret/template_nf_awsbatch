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

data "aws_subnet" "subnet" {
  id = var.subnet_id  # Replace var.subnet_id with your subnet ID or variable
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Security group allowing SSH access"
  vpc_id      = data.aws_subnet.subnet.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "role" {
  name = "${var.prefix}-session-role"

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

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Load the JSON policy document from a file
data "local_file" "custom_policy" {
  filename = "${path.module}/nf_policy.json"
}

# Create a new IAM policy using the loaded JSON document
resource "aws_iam_policy" "custom_policy" {
  name        = "${var.prefix}-custom-policy"
  description = "A custom policy for specific permissions"
  policy      = data.local_file.custom_policy.content
}

# Attach the newly created policy to the IAM role
resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.custom_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.prefix}-session_instance_profile"
  role = aws_iam_role.role.name
}

resource "random_uuid" "test" {
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.prefix}-${random_uuid.test.result}"
  public_key = var.public_key
}

resource "aws_s3_bucket" "nextflow_bucket" {
  bucket = var.env_bucket_name
  force_destroy = true
}

resource "aws_s3_object" "nextflow_workdir" {
  bucket = aws_s3_bucket.nextflow_bucket.bucket
  key    = "nextflow_env/" 
  content_type = "application/x-directory"
}

data "template_file" "cloud_init" {
  
  template = file("${path.module}/cloud_init.tpl")

  vars = {
    use_fusion = var.use_fusion
    aws_region = var.aws_region
    job_queue = var.job_queue
    tower_access_token = var.tower_access_token
    s3_bucket = aws_s3_bucket.nextflow_bucket.bucket
  }

}

resource "aws_instance" "batch_session" {
  depends_on = [aws_s3_object.nextflow_workdir]
  ami           = var.ami_id
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  instance_type = var.instance_type # Define this variable
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.deployer.key_name

  root_block_device {
    delete_on_termination = true
    volume_size           = var.volume_size
    volume_type           = "gp3"
    throughput            = var.volume_throughput
    iops                  = var.volume_iops
  }

  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  user_data = data.template_file.cloud_init.rendered
  user_data_replace_on_change = true
}

