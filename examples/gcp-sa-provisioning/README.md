# Provisioning a Google Service Account that can be used to deploy Databricks workspace on GCP
=========================

In this template, we show how to deploy a service account that can be used to deploy Databricks workspace on GCP.

In this template, we create a [Service Account](https://cloud.google.com/iam/docs/service-account-overview) with minimal permissions that allow to provision a workspace with both managed and user-provisioned VPC.


## Requirements

- Your user that you use to delegate from needs a set of permissions detailed [here](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/permissions.html#required-user-permissions-or-service-account-permissions-to-create-a-workspace)

- The built-in roles of Kubernetes Admin and Compute Storage Admin needs to be available

- Google Cloud CLI (gcloud) installed and configured

- you need to run `gcloud auth application-default login` and login with your google account

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
   gcloud services enable iam.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

4. **Authenticate for application default credentials:**
   ```bash
   gcloud auth application-default login
   ```
   This sets up credentials that Terraform can use automatically.

## Run as an SA 

You can do the same thing by provisioning a service account that will have the same permissions - and associate the key associated to it.


## Run the template

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`