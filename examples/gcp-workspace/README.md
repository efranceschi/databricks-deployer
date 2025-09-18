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
- Google Cloud CLI (gcloud) installed and configured

## Google Cloud CLI Setup

### Installation

**macOS:**
```bash
# Using Homebrew
brew install google-cloud-sdk

# Or download the installer
curl https://sdk.cloud.google.com | bash
```

**Windows:**
```powershell
# Download and run the installer from:
# https://cloud.google.com/sdk/docs/install-sdk#windows

# Or using Chocolatey
choco install gcloudsdk
```

**Linux:**
```bash
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-cli
```

### Initial Configuration

1. **Initialize gcloud:**
   ```bash
   gcloud init
   ```
   This will guide you through:
   - Logging into your Google account
   - Selecting a project
   - Setting a default compute region/zone

2. **Set your project (if not done during init):**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Enable required APIs:**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable iam.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

### Service Account Setup

1. **Create a service account:**
   ```bash
   gcloud iam service-accounts create databricks-terraform-sa \
       --description="Service account for Databricks Terraform deployment" \
       --display-name="Databricks Terraform SA"
   ```

2. **Grant required roles:**
   ```bash
   PROJECT_ID=$(gcloud config get-value project)
   SA_EMAIL="databricks-terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:${SA_EMAIL}" \
       --role="roles/compute.admin"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:${SA_EMAIL}" \
       --role="roles/container.admin"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:${SA_EMAIL}" \
       --role="roles/iam.serviceAccountUser"
   
   gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member="serviceAccount:${SA_EMAIL}" \
       --role="roles/resourcemanager.projectIamAdmin"
   ```

3. **Grant impersonation permissions to your user:**
   ```bash
   USER_EMAIL=$(gcloud config get-value account)
   
   gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
       --member="user:${USER_EMAIL}" \
       --role="roles/iam.serviceAccountTokenCreator"
   ```

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