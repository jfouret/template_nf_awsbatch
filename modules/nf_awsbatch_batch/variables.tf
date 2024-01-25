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

variable "prefix" {
  description = "The prefix for naming"
  type        = string
  default     = "nf_awsbatch"
}

variable "aws_region" {
  description = "aws region to use"
  type        = string
  default     = "eu-west-3"
}

variable "ami_for_batch" {
  description = "ami to be used from the nf_awsbatch_image module"
  type        = string
}

variable "instance_type" {
  description = "The instance types that can be launched."
  type = list(string)
  default = [
    "m5",
    "c5",
    "r5"
  ]
}

variable "compute_resources_bid_percentage" {
  description = "aws_batch_compute_environment.compute_resources.bid_percentage"
  type = number
  default = 100
}

variable "compute_resources_max_vcpus" {
  description = "aws_batch_compute_environment.compute_resources.max_vcpus"
  type = number
  default = 256
}

variable "compute_resources_min_vcpus" {
  description = "aws_batch_compute_environment.compute_resources.min_vcpus"
  type = number
  default = 0
}

variable "compute_resources_type" {
  description = "aws_batch_compute_environment.compute_resources.type"
  type = string
  default = "SPOT"
}

variable "compute_resources_allocation_strategy" {
  description = "aws_batch_compute_environment.compute_resources.allocation_strategy"
  type = string
  default = "SPOT_CAPACITY_OPTIMIZED"
}

variable "sg_ids" {
  description = "security groups"
  type = list(string)
}

variable "subnet_ids" {
  description = "subnet ids"
  type = list(string)
}