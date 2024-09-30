#cloud-config
write_files:
- path: /home/ec2-user/nextflow.config
  content: |
    process.executor = 'awsbatch'
    process.queue = '${job_queue}'
    aws.region = '${aws_region}'
    %{ if use_fusion }wave {
        enabled = true
    }%{ if tower_access_token != "" }
    tower {
        accessToken = '${tower_access_token}'
    }%{ endif }
    fusion {
        enabled = true
    }%{ else }wave {
        enabled = false
    }
    fusion {
        enabled = false
    }
    aws.batch.cliPath = '/awscli_venv/miniconda/bin/aws'
    aws.batch.maxParallelTransfers = 16
    aws.batch.maxTransferAttempts = 5%{ endif }
    workDir = 's3://${s3_bucket}/nextflow_env/'
runcmd:
- yum install -y awscli bzip2 wget java-21-amazon-corretto-headless vim
- wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
- yum install -y ./mount-s3.rpm
- rm ./mount-s3.rpm
- wget -qO- https://get.nextflow.io | bash
- mv nextflow /usr/local/bin/
- chmod o+rx /usr/local/bin/nextflow
- chown ec2-user:ec2-user -R /home/ec2-user
