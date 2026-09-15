# terraform-aws-ci

Generic Docker image for Terraform + AWS CLI CI pipelines on ARM64 (Graviton) runners.

## Image

```
ghcr.io/christlau/terraform-aws-ci:<terraform-version>
ghcr.io/christlau/terraform-aws-ci:latest
```

## Contents

- Terraform (version pinned in Dockerfile)
- AWS CLI v2
- git, jq, unzip
- Pre-baked hashicorp/aws and hashicorp/null providers

## Usage in GitLab CI

```yaml
default:
  image:
    name: ghcr.io/christlau/terraform-aws-ci:1.16.2
    entrypoint: [""]
```

## Updating Terraform version

Change `FROM hashicorp/terraform:<version>` in `Dockerfile` and push to `main`.
GitHub Actions builds and pushes automatically.

## Architecture

`linux/arm64` — built for Graviton-based EKS runners.
