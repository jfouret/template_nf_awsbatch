# Terraform Template for Nextflow AWS Batch

## License

```
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
```

## Introduction 

Nextflow is a robust workflow system for defining and running complex processing pipelines with multiple steps. It excels in scalability and reproducibility and is compatible with various computing environments. This project provides a Terraform template to efficiently set up an AWS Batch environment optimized for Nextflow.

Our goal is to define modular Terraform configurations for effortless deployment of an AWS Batch environment tailored for Nextflow use. This repository contains various modules for flexibility, along with a comprehensive template illustrating their combined application.

## Sources of inspiration

I have followed the following ressources to elaborate this template:

- [Seqera Labs Nextflow and AWS Batch Integration Part 1](https://seqera.io/blog/nextflow-and-aws-batch-inside-the-integration-part-1-of-3/)
- [Seqera Labs Nextflow and AWS Batch Integration Part 2](https://seqera.io/blog/nextflow-and-aws-batch-inside-the-integration-part-2-of-3/)
- [STAPH-B Public Health Bacterial Bioinformatics Portal](https://staphb.org/resources/2020-04-29-nextflow_batch.html)
- [AWS Open Data Genomics Workflows](https://docs.opendata.aws/genomics-workflows/orchestration/nextflow/nextflow-overview.html)

## Repository Contents

### Module: `nf_awsbatch_user`

Creates a restricted user for Nextflow's interaction with AWS Batch, enhancing security.

> **current limitation:** The user currently has broad access to S3 resources. Future versions may restrict access via variables.

### Module: `nf_awsbatch_image`

Generates the required Amazon Machine Image (AMI) for AWS Batch.

> **NOTE:**  The build of the image takes approximately 15min. You can customize the root disk size for batch instances.

### Module: `nf_awsbatch_network`

Establishes a VPC with both public and private subnets across availability zones.

- **Options**
  1. Private subnets in AWS Batch with a NAT Gateway per availability zone.
  2. Private subnets with a single NAT Gateway (default).
  3. Public subnets without NAT, assigning public IPs to each instance.
- **Pricing considerations**
    - NAT GW uptime 
    - NAT GW Data Tranfer processing pricing
    - Intra-Region Data Transfer between Availability Zones when using a single NAT.
    - Elastic IPv4 pricing for both NATs or instances in case of public subnets

For more details : https://aws.amazon.com/vpc/pricing/

### Module: `nf_awsbatch_batch`

Configures the AWS Batch infrastructure for Nextflow. Defaults to the optimal setup for typical use cases.

### Template `main.tf`

Serves as an example showcasing the integration of all modules.

## Usage

### Prerequisite:

1. Install terraform

2. Setup AWS credentials

```
export AWS_DEFAULT_REGION="eu-west-3"
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
Alternatively, you can store those in `.aws/credentials.sh` and run `source .aws/credentials.sh`

**Required AWS Managed policies**:

- AmazonEC2FullAccess
- AmazonECS_FullAccess
- AmazonS3FullAccess
- AWSBatchFullAccess
- AWSImageBuilderFullAccess
- IAMFullAccess

> **Note:** These permissions are extensive and should be refined for production use. A user with reduced permissions is created for Nextflow interaction.

3. Manually create a S3 bucket `tfstate.test-awsbatch` in the appropriate region. 

> **Note:** Bucket name and region are configurable in `main.tf`.

### Quick start

Run the following commands to initialize and apply the Terraform configuration:

```
terraform init
terraform apply
```
