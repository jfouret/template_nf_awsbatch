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

resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

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

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
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

resource "aws_instance" "batch_session" {
  depends_on = [aws_s3_object.nextflow_workdir]
  ami           = var.ami_id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  instance_type = var.instance_type # Define this variable
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  user_data = <<-EOF
    #cloud-config
    write_files:
    - path: /home/ec2-user/nextflow.config
      content: |
        process.executor = 'awsbatch'
        process.queue = '${var.job_queue}'
        aws.region = '${var.aws_region}'
        aws.batch.cliPath = '/usr/local/bin/aws'
        workDir = 's3://${aws_s3_bucket.nextflow_bucket.bucket}/nextflow_env/'
        aws {
            accessKey = '${var.aws_accessKey}'
            secretKey = '${var.aws_secretKey}'
        }
  EOF
}

