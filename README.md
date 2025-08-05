# RVT Infrastructure

Production-ready AWS infrastructure for scalable web applications with automated CI/CD deployment using GitHub Actions and Terraform.

## Deployment

### Automated Deployment (Recommended)

Infrastructure is automatically deployed via GitHub Actions:

- **Pull Requests**: Terraform plan validation runs automatically
- **Main Branch**: Full deployment with plan → apply workflow  
- **Manual Triggers**: Deploy or destroy via GitHub Actions UI

### Pipeline Features

- **Automated Terraform plan validation** on every PR
- **Zero-downtime deployments** with approval gates
- **State management** via S3 backend  
- **AWS IAM roles** with OIDC (no long-lived credentials)
- **Multi-environment support** (dev/prod configurations)

### Prerequisites

- AWS Account with appropriate IAM roles configured
- GitHub repository with required secrets and variables
- S3 bucket for Terraform state (retrieved from Parameter Store)

## Infrastructure Components

This deploys a complete production-ready stack:

- **CloudFront CDN** with HTTPS termination
- **Application Load Balancer** with health checks
- **ECS Fargate** cluster with auto-scaling (1-5 tasks)
- **PostgreSQL RDS** with Multi-AZ and automated backups
- **VPC** with 3-tier network architecture across 2 AZs
- **ECR** repository for container images
- **Secrets Manager** for secure credential storage
- **CloudWatch** logging and monitoring

## Configuration

### Environment Variables

Configure environments via `configuration/{env}/terraform.tfvars`:

```hcl
project_name = "hello-app"
environment  = "dev"
aws_region   = "eu-north-1"
vpc_cidr     = "10.0.0.0/16"
```

### GitHub Actions Setup

Required repository secrets:
- `AWS_IAM_ROLE_ARN_GH_RUNNER`: OIDC role ARN for GitHub Actions

Required repository variables:
- `AWS_REGION`: Target AWS region