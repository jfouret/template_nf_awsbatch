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

variable "network_type" {
  description = <<-EOT
  Type of network to create (public or private).
  In case of public, IP address will be attached to each instance.
  In case of private, NAT(s) is(are) created.
  EOT
  type        = string
  default = "public"
  validation {
    condition     = var.network_type == "public" || var.network_type == "private"
    error_message = "Network type must be either 'public' or 'private'."
  }
}

variable "cidr_string" {
  description = "CIDR string"
  type = string
  default = "10.0.0.0/16"
}

variable "only_one_nat" {
  description = <<-EOT
  If true, only one NAT Gateway will be created for all subnets. 
  If false, one NAT Gateway per Availability Zone will be created.
  EOT
  type        = bool
  default     = true
}

variable "aws_s3_gw_regions" {
  description = "List of AWS regions to build S3 gateways"
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-1", "us-west-2", "eu-central-1", "eu-central-2", "eu-west-1", "eu-west-2", "eu-west-1"]
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}
