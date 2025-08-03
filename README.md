# RVT Infrastructure

AWS infrastructure setup for a scalable web application using Terraform. This project provisions a highly available, multi-tier architecture on AWS.

## Architecture Overview

This infrastructure creates:
- **VPC** with public and private subnets across 2 availability zones
- **Application Load Balancer** for distributing traffic
- **NAT Gateways** (one per AZ) for high availability
- **Security groups** with least-privilege access
- **Database subnets** isolated from application tier

## Prerequisites

- [Terraform](https://terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS credentials with appropriate permissions

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd rvt-infra
   ```

2. **Configure backend** (optional)
   ```bash
   # Update backend.tf with your S3 bucket and DynamoDB table
   terraform init -backend-config="bucket=your-terraform-state-bucket"
   ```

3. **Plan the deployment**
   ```bash
   cd implementation
   terraform init
   terraform plan
   ```

4. **Deploy the infrastructure**
   ```bash
   terraform apply
   ```

5. **Get outputs**
   ```bash
   terraform output
   ```

## Configuration

### Variables

Key variables you can customize in `variables.tf`:

| Variable       | Description                   | Default       |
|----------------|-------------------------------|---------------|
| `project_name` | Name prefix for all resources | `hello-app`   |
| `environment`  | Environment name              | `dev`         |
| `aws_region`   | AWS region                    | `eu-north-1`  |
| `vpc_cidr`     | VPC CIDR block                | `10.0.0.0/16` |
| `app_port`     | Application port              | `4000`        |

### Backend Configuration

For production use, configure remote state:

```bash
terraform init -backend-config="bucket=your-state-bucket" \
               -backend-config="key=rvt-infra/terraform.tfstate" \
               -backend-config="region=eu-north-1"
```

## Project Structure

```
implementation/
├── alb.tf          # Application Load Balancer configuration
├── backend.tf      # Terraform backend configuration
├── data.tf         # Data sources
├── locals.tf       # Local values
├── networking.tf   # VPC, subnets, routing
├── variables.tf    # Input variables
└── versions.tf     # Provider versions
```

## Outputs

After deployment, you'll get:
- ALB DNS name for accessing your application
- VPC and subnet IDs for application deployment
- Security group IDs

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: Ensure no critical data will be lost before destroying resources.