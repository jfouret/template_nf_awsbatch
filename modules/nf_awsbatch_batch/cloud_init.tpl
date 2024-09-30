#cloud-config
runcmd:
  - echo "ECS_DISABLE_IMAGE_CLEANUP=true" >> /etc/ecs/ecs.config
  - yum install -y awscli wget ca-certificates curl-minimal tar bzip2
  %{ if ! use_fusion }- curl --silent -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  - bash Miniconda3-latest-Linux-x86_64.sh -b -p /awscli_venv/miniconda
  - /awscli_venv/miniconda/bin/conda install -y -c conda-forge awscli%{ endif }
