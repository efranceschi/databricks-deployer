# AWS Databricks Workspace Example

This example demonstrates how to deploy a Databricks workspace in AWS using the `aws-workspace` module.

## Prerequisites

- Terraform 1.0.0 or later
- AWS CLI 2.0 or later
- AWS account with appropriate permissions
- Databricks account with appropriate permissions

## AWS Authentication Setup

### 1. Install AWS CLI

**macOS (using Homebrew):**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Download and run the AWS CLI MSI installer from the [official AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### 2. Configure AWS Credentials

Choose one of the following authentication methods:

#### Option A: AWS CLI Configure (Recommended for Development)

```bash
aws configure
```

You'll be prompted to enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-west-2`)
- Default output format (e.g., `json`)

#### Option B: Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-west-2"
```

#### Option C: AWS Profiles (Recommended for Multiple Accounts)

```bash
# Configure a named profile
aws configure --profile databricks-dev

# Use the profile with Terraform
export AWS_PROFILE=databricks-dev
```

#### Option D: IAM Roles (Recommended for Production/CI/CD)

For EC2 instances or CI/CD pipelines, use IAM roles:

```bash
# Assume a role
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT-ID:role/DatabricksDeploymentRole --role-session-name terraform-session

# Export the temporary credentials
export AWS_ACCESS_KEY_ID="temporary-access-key"
export AWS_SECRET_ACCESS_KEY="temporary-secret-key"
export AWS_SESSION_TOKEN="temporary-session-token"
```

### 3. Verify AWS Authentication

```bash
# Test AWS CLI connectivity
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "XXX",
#     "Account": "NNNNNNNNN",
#     "Arn": "arn:aws:iam::NNNNNNNNN:user/User"
# }
```

### 4. Required AWS Permissions

Ensure your AWS user/role has the following permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:GetRole",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "sts:AssumeRole"
            ],
            "Resource": "*"
        }
    ]
}
```

### 5. Terraform AWS Provider Configuration

The AWS provider will automatically use your configured credentials. You can also specify the region explicitly:

```hcl
# In your terraform configuration
provider "aws" {
  region = var.aws_region
  # profile = "databricks-dev"  # Optional: specify profile
}
```

### 6. Authentication Best Practices

#### For Development:
- Use AWS CLI profiles to manage multiple accounts
- Never hardcode credentials in Terraform files
- Use `aws configure` for local development

#### For Production/CI/CD:
- Use IAM roles instead of access keys
- Implement least privilege access
- Use AWS STS for temporary credentials
- Consider AWS SSO for centralized access management

#### Security Recommendations:
- Enable MFA on your AWS account
- Rotate access keys regularly
- Use AWS CloudTrail for audit logging
- Store sensitive variables in AWS Secrets Manager or Parameter Store

### 7. Troubleshooting Authentication Issues

#### Common Issues and Solutions:

**"Unable to locate credentials" error:**
```bash
# Check if credentials are configured
aws configure list

# Verify credentials work
aws sts get-caller-identity
```

**"Access Denied" errors:**
```bash
# Check your current identity
aws sts get-caller-identity

# Verify you have the required permissions
aws iam simulate-principal-policy --policy-source-arn $(aws sts get-caller-identity --query Arn --output text) --action-names ec2:DescribeVpcs
```

**Region-related issues:**
```bash
# Check your default region
aws configure get region

# Set region for current session
export AWS_DEFAULT_REGION=us-west-2
```

**Profile issues:**
```bash
# List available profiles
aws configure list-profiles

# Test specific profile
aws sts get-caller-identity --profile your-profile-name
```

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in the required variables:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific values.

3. Initialize Terraform:

```bash
terraform init
```

4. Plan the deployment:

```bash
terraform plan
```

5. Apply the configuration:

```bash
terraform apply
```

## Configuration Options

This example supports various configuration options through variables:

### General
- `prefix`: Project prefix for naming resources

### Databricks
- `databricks_account_id`: Your Databricks Account ID
- `databricks_client_id`: Client ID for the service principal
- `databricks_client_secret`: Client Secret for the service principal
- `workspace_name`: The Databricks workspace name (optional)
- `pricing_tier`: Pricing tier for the workspace (default: PREMIUM)

### AWS
- `aws_region`: AWS region for deployment

### Network
- `create_vpc`: Whether to create a new VPC (default: true)
- Various network resource names (optional if creating new resources)

### Private Link
- `enable_private_link`: Enable AWS PrivateLink for Databricks workspace (default: false)

### Tags
- `tags`: Map of tags to apply to resources

### Availability Zones
- `availability_zones`: List of availability zones to deploy subnets in (optional)

## Outputs

- `workspace_url`: The URL of the Databricks workspace
- `workspace_id`: The ID of the Databricks workspace
- `vpc_id`: The ID of the VPC
- `private_subnet_ids`: The IDs of the private subnets
- `public_subnet_ids`: The IDs of the public subnets
- `security_group_id`: The ID of the security group