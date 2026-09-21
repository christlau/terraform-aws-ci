# Dockerfile — Terraform AWS CI Image
# Base: amazonlinux:2023
# Includes: AWS CLI v2 + Terraform + unzip + git + jq
# Pre-baked providers: hashicorp/aws ~6.x, hashicorp/null ~3.x
# Architecture: linux/arm64 (Graviton runners, primary)
#
# Image: ghcr.io/christlau/terraform-aws-ci:<tf-version>
# To update Terraform version: bump the version tag below and push to main.

FROM hashicorp/terraform:1.16.2 AS terraform

FROM amazonlinux:2023

ARG AWS_CLI_VERSION=2.27.16

RUN yum install -y curl unzip git jq shadow-utils && yum clean all

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then AWS_ARCH="aarch64"; else AWS_ARCH="x86_64"; fi && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}-${AWS_CLI_VERSION}.zip" \
      -o /tmp/awscliv2.zip && \
    unzip -q /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/awscliv2.zip /tmp/aws

COPY --from=terraform /bin/terraform /usr/local/bin/terraform

# Pre-bake common Terraform providers so CI jobs skip the download step
ENV TF_PLUGIN_CACHE_DIR=/opt/terraform-provider-cache

RUN mkdir -p /opt/terraform-provider-cache /tmp/tf-prebake

RUN printf 'terraform {\n  required_providers {\n    aws = {\n      source  = "hashicorp/aws"\n      version = "~> 6.0"\n    }\n    null = {\n      source  = "hashicorp/null"\n      version = "~> 3.0"\n    }\n  }\n}\n' > /tmp/tf-prebake/versions.tf

RUN cd /tmp/tf-prebake && terraform init && rm -rf /tmp/tf-prebake

RUN terraform version && aws --version && git --version && jq --version

ENTRYPOINT [""]
