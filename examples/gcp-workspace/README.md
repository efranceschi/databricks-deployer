# Deploying a Databricks Workspace in GCP

This example demonstrates how to deploy a Databricks workspace in Google Cloud Platform (GCP) using the `gcp-workspace` module. The example creates a complete Databricks workspace with the following components:

- GCP VPC Network (can use existing or create new)
- Subnets for Databricks workspace (primary, pods, and services)
- NAT Gateway for outbound connectivity
- Optional Private Service Connect (PSC) endpoints for Databricks services
- Databricks workspace with network configuration


## Requirements

- A GCP account with appropriate permissions to create resources
- A Databricks account with appropriate permissions to create workspaces
- A GCP service account with the following permissions:
  - Compute Admin (`roles/compute.admin`)
  - Kubernetes Engine Admin (`roles/container.admin`)
  - Service Account User (`roles/iam.serviceAccountUser`)
  - Project IAM Admin (`roles/resourcemanager.projectIamAdmin`)
- Terraform installed on your local machine

## Authentication

This example uses service account impersonation for authentication. You need to:

1. Create a service account with the required permissions
2. Grant your user account permission to impersonate the service account
3. Run `gcloud auth application-default login` and login with your Google account

Alternatively, you can use a service account key by modifying the provider configuration in `providers.tf`.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in the required variables:

```hcl
# General
prefix = "myproject"

# Databricks
databricks_account_id = "12345678-1234-1234-1234-123456789012"
databricks_client_id = "12345678-1234-1234-1234-123456789012"
databricks_client_secret = "your-client-secret"

# Google
google_project = "my-gcp-project"
google_region = "us-central1"
google_service_account = "sa-name@my-gcp-project.iam.gserviceaccount.com"

# Optional: Enable Private Service Connect
enable_psc = true
```

2. Initialize Terraform:

```bash
terraform init
```

3. Apply the Terraform configuration:

```bash
terraform apply
```

4. After successful deployment, you can access your Databricks workspace using the URL from the output.

## Customization

You can customize the deployment by modifying the variables in `terraform.tfvars`. See the `variables.tf` file for all available variables and their descriptions.

## Outputs

After successful deployment, the following outputs will be available:

- Workspace URL
- Workspace ID
- Network IDs
- VPC and subnet IDs
- PSC endpoint IDs (if enabled)