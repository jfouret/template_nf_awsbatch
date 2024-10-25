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

variable "tower_access_token" {
  description = "The token from the seqera plateform to use wave"
  type        = string
  default     = ""
}

variable "use_fusion" {
  description = "Flag to determine whether to use fusion or not"
  type        = bool
  default     = false
}

variable "batch_instance_type" {
  description = "list of instance types for AWS Batch"
  type = list(string)
  default = [
    "r5a.4xlarge", "r5a.8xlarge",
    "r5.4xlarge", "r5.8xlarge" ,
    "m5a.4xlarge", "m5a.8xlarge",
    "m5.4xlarge", "m5.8xlarge"
  ]
}

variable "session_instance_type" {
  description = "Instance type to use for the session (c5n good for network)"
  type        = string
  default     = "c5n.xlarge"
}

variable "batch_volume_iops" {
  description = "IOPS for block storage for Batch instances"
  type        = number
  default     = 6000
}

variable "batch_volume_throughput" {
  description = "Throughput (MB/s) for block storage for Batch instances"
  type        = number
  default     = 500
}

variable "batch_volume_size" {
  description = "Volume size  for Batch instances that must be higher than the root volume from base ami"
  type = number
  default = 1000
}

variable "session_volume_iops" {
  description = "IOPS for block storage for Session instance"
  type        = number
  default     = 3000
}

variable "session_volume_throughput" {
  description = "Throughput (MB/s) for block storage for Session instance"
  type        = number
  default     = 125
}

variable "session_volume_size" {
  description = "Volume size  for Session instance that must be higher than the root volume from base ami"
  type = number
  default = 100
}


