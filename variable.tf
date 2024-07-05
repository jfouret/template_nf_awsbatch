variable "prefix" {
  description = "The prefix for naming"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default = "eu-west-3"
}

variable "max_cpus" {
  description = "Max number of CPUs"
  type        = number
  default     = 128
}

variable "new_tmp_bucket_for_env" {
  description = "The name of a bucket that will be created for tmp data"
  type        = string
}
