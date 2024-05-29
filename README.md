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

## Inspiration sources

I have followed the following ressources to elaborate this template:

- [Seqera Labs Nextflow and AWS Batch Integration Part 1](https://seqera.io/blog/nextflow-and-aws-batch-inside-the-integration-part-1-of-3/)
- [Seqera Labs Nextflow and AWS Batch Integration Part 2](https://seqera.io/blog/nextflow-and-aws-batch-inside-the-integration-part-2-of-3/)
- [STAPH-B Public Health Bacterial Bioinformatics Portal](https://staphb.org/resources/2020-04-29-nextflow_batch.html)
- [AWS Open Data Genomics Workflows](https://docs.opendata.aws/genomics-workflows/orchestration/nextflow/nextflow-overview.html)

Of note, with the introduction of wave and fusion some things have changed, therefore the use of image is less necessary. In addition I tried to use more of role-defined permission rather than using acess key or secret.

## Repository Contents

### Module: `nf_awsbatch_network`

Establishes a VPC with both public and private subnets across availability zones.

- **Options**
  1. Private subnets in AWS Batch with a NAT Gateway per availability zone.
  2. Private subnets with a single NAT Gateway (default).
  3. Public subnets without NAT, assigning public IPs to each instance.
- **Pricing considerations**
  - NAT Gateway uptime and data transfer processing fees.
  - Cross-zone data transfer costs when using a single NAT.
  - Elastic IPv4 charges for NATs or instances in public subnet scenarios.

For more details : https://aws.amazon.com/vpc/pricing/

### Module: `nf_awsbatch_batch`

Configures the AWS Batch infrastructure, tailored for optimal performance with typical Nextflow use cases.

### Module: `nf_awsbatch_session`

Facilitates setting up a session with an EC2 instance for launching Nextflow runs. This module includes:

- Creation of an S3 bucket for storing Nextflow intermediate files.
- Provisioning an instance in the same region as AWS Batch for efficient interaction with the S3 bucket.
- A basic Nextflow configuration file for AWS Batch.
- Installation of `awscli` and `mount-s3`, with instance roles permitting S3 access.

### Template `main.tf`

Serves as an example showcasing the integration of all modules.

Output of the instance IP and provision of `generated_key.pem` for secure to the batch session.

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

> **Note:** These permissions are broad and should be refined for production environments. The setup includes a Nextflow-specific user with more restricted permissions.

3. Manually create a S3 bucket `tfstate.test-awsbatch` in the appropriate region. 

> **Note:** Bucket name and region are configurable in `main.tf`.

### Quick start

Run the following commands to initialize and apply the Terraform configuration:

```
terraform init
terraform apply
```


### Run a nextflow pipeline

On the aws EC2 session

```

nextflow -c ~/nextflow.config nexomis/primary --input_dir s3://bucket_name/RunID --output_dir s3://bucket_name/RunID_DIR

```
