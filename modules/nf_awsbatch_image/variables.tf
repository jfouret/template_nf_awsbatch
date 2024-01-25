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

variable "base_ami" {
  description = "Base AMI to build the image"
  type = string
  default = "ami-080469cf8603dcf20"
}

variable "device_name" {
  description = "Device name that should match the root volume from the base ami"
  type = string
  default = "/dev/xvda"
}

variable "volume_size" {
  description = "Volume size that must be higher than the root volume from base ami"
  type = number
  default = 100
}

variable "timezone" {
  description = "Timezone"
  type = string
  default = "Europe/Paris"
}

variable "image_tests_enabled" {
  description = "Whether to enable or not tests"
  type = bool
  default = false
}