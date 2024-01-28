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

resource "aws_iam_user" "user" {
  name = "${var.prefix}_user"
}

resource "aws_iam_group" "group" {
  name = "${var.prefix}_group"
}

resource "aws_iam_group_policy" "policy" {
  name  = "${var.prefix}_group_policy"
  group = aws_iam_group.group.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "batch:DescribeJobQueues",
          "batch:CancelJob",
          "batch:TagResource",
          "batch:SubmitJob",
          "batch:ListJobs",
          "batch:DescribeComputeEnvironments",
          "batch:TerminateJob",
          "batch:DescribeJobs",
          "batch:RegisterJobDefinition",
          "batch:DescribeJobDefinitions"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecs:DescribeTasks",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceAttribute",
          "ecs:DescribeContainerInstances",
          "ec2:DescribeInstanceStatus"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_membership" "membership" {
  name = "${var.prefix}_membership"
  users = [aws_iam_user.user.name]
  group = aws_iam_group.group.name
}

resource "aws_iam_access_key" "user_key" {
  user = aws_iam_user.user.name
}
