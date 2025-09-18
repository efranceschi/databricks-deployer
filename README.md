# Databricks Deployer

A comprehensive Terraform project for deploying Databricks workspaces across multiple cloud providers (AWS, Azure, and GCP) in a very simple way.

This project is not intended to implement best security practices, but rather to deploy Databricks in a simplified way.

For best practice implementations, see:
- [Databricks Security Best Practices](https://www.databricks.com/trust/security-features/best-practices)
- [Security Best Practices for Databricks Data Intelligence Platform](https://www.databricks.com/blog/security-best-practices-databricks-data-intelligence-platform)
- [Databricks Security Reference Architecture](https://github.com/databricks/terraform-databricks-sra)
- [Data Exfiltration Protection with Databricks on AWS](https://www.databricks.com/blog/2021/02/02/data-exfiltration-protection-with-databricks-on-aws.html)
- [Data Exfiltration Protection with Databricks on Azure](https://www.databricks.com/blog/data-exfiltration-protection-with-azure-databricks)
- [Data Exfiltration Protection with Databricks on GCP](https://www.databricks.com/blog/databricks-gcp-practitioners-guide-data-exfiltration-protection)

## ⚠️ Disclaimer

**Important Notice**: This project is provided as-is for educational and reference purposes. While these Terraform modules follow industry best practices, they are intended as starting points for your own infrastructure deployments.

**Before using in production**:
- Thoroughly review all configurations and adapt them to your specific requirements
- Test extensively in non-production environments
- Ensure compliance with your organization's security policies and standards
- Validate that the configurations meet your specific networking and security requirements
- Consider engaging with Databricks and your cloud provider's professional services for production deployments

**Liability**: The authors and contributors of this project are not responsible for any issues, costs, or damages that may arise from the use of these templates. Use at your own risk and discretion.

**Support**: This is a community-driven project. While we strive to maintain and improve these modules, there is no guarantee of support or maintenance. For production workloads, consider using officially supported deployment methods from Databricks.

---

## 🏗️ Project Structure

```
databricks-deployer/
├── modules/                    # Reusable Terraform modules
│   ├── aws-workspace/         # AWS Databricks workspace module
│   ├── azure-workspace/       # Azure Databricks workspace module
│   ├── gcp-workspace/         # GCP Databricks workspace module
│   └── gcp-sa-provisioning/   # GCP service account provisioning
├── examples/                  # Example implementations
│   ├── aws-workspace/         # AWS workspace deployment example
│   ├── azure-workspace/       # Azure workspace deployment example
│   ├── gcp-workspace/         # GCP workspace deployment example
│   └── gcp-sa-provisioning/   # GCP service account example
└── tools/                     # Installation and utility scripts
    ├── install-terraform-windows.ps1  # Terraform installer for Windows
    ├── install-awscli-windows.ps1     # AWS CLI installer for Windows
    ├── install-azurecli-windows.ps1   # Azure CLI installer for Windows
    └── install-gcp-cli-windows.ps1    # Google Cloud CLI installer for Windows
```

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- Cloud provider CLI tools:
  - AWS CLI (for AWS deployments)
  - Azure CLI (for Azure deployments)
  - gcloud CLI (for GCP deployments)
- Databricks account with appropriate permissions
- Cloud provider account with sufficient permissions

## 🛠️ Installation Scripts

This project includes PowerShell scripts for Windows users to automatically download and install the required CLI tools. These scripts provide a convenient way to set up your development environment.

### Available Scripts

| Script | Tool | Description |
|--------|------|-------------|
| `tools/install-terraform-windows.ps1` | Terraform | Infrastructure as Code tool |
| `tools/install-awscli-windows.ps1` | AWS CLI v2 | AWS command-line interface |
| `tools/install-azurecli-windows.ps1` | Azure CLI | Azure command-line interface |
| `tools/install-gcp-cli-windows.ps1` | Google Cloud CLI | Google Cloud command-line interface |

### Usage

#### Basic Installation (Recommended)

```powershell
# Install Terraform
.\tools\install-terraform-windows.ps1

# Install AWS CLI
.\tools\install-awscli-windows.ps1

# Install Azure CLI
.\tools\install-azurecli-windows.ps1

# Install Google Cloud CLI
.\tools\install-gcp-cli-windows.ps1
```

#### Advanced Usage

##### Terraform Installation Options

```powershell
# Install to custom directory
.\tools\install-terraform-windows.ps1 -InstallPath "C:\Tools\Terraform"

# Install specific version
.\tools\install-terraform-windows.ps1 -Version "1.5.0"

# Install without adding to PATH
.\tools\install-terraform-windows.ps1 -AddToPath:$false

# Combined options
.\tools\install-terraform-windows.ps1 -InstallPath "C:\Tools\Terraform" -Version "1.6.0"
```

##### Cloud CLI Installation Options

```powershell
# Silent installation (no user prompts)
.\tools\install-awscli-windows.ps1 -Silent
.\tools\install-azurecli-windows.ps1 -Silent
.\tools\install-gcp-cli-windows.ps1 -Silent

# Skip installation verification
.\tools\install-awscli-windows.ps1 -SkipVerification
.\tools\install-azurecli-windows.ps1 -SkipVerification
.\tools\install-gcp-cli-windows.ps1 -SkipVerification

# Combined options for unattended installation
.\tools\install-awscli-windows.ps1 -Silent -SkipVerification
```

### Script Parameters

#### Common Parameters (All CLI Scripts)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Silent` | Switch | `$false` | Run installation without user prompts |
| `-SkipVerification` | Switch | `$false` | Skip post-installation verification |
| `-Version` | String | `"latest"` | Install specific version (limited support) |

#### Terraform-Specific Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-InstallPath` | String | `$env:LOCALAPPDATA\Terraform` | Installation directory |
| `-AddToPath` | Switch | `$true` | Add to user PATH environment variable |
| `-Version` | String | `"latest"` | Terraform version to install |

### Features

#### All Installation Scripts Include:

- ✅ **Automatic Downloads**: Download latest versions from official sources
- ✅ **Architecture Detection**: Automatically detect 32-bit vs 64-bit systems
- ✅ **Existing Installation Check**: Detect and handle existing installations
- ✅ **Progress Indicators**: Visual feedback during download and installation
- ✅ **Error Handling**: Comprehensive error handling with helpful messages
- ✅ **PATH Management**: Automatic PATH environment variable updates
- ✅ **Installation Verification**: Post-installation testing and validation
- ✅ **Colored Output**: Enhanced readability with color-coded messages
- ✅ **Cleanup**: Automatic removal of temporary installation files

#### Tool-Specific Features:

**Terraform Script**:
- Downloads from HashiCorp releases with version selection
- Zip file extraction to custom directories
- GitHub API integration for latest version detection
- Portable installation (no administrator rights required by default)

**AWS CLI Script**:
- MSI installer with UAC elevation handling
- 64-bit requirement detection
- Comprehensive MSI error code handling
- Post-installation configuration guidance

**Azure CLI Script**:
- Microsoft's official installer with redirect URL handling
- Cross-architecture support (32-bit and 64-bit)
- MSI installer with progress display options
- Integration guidance for Azure authentication

**Google Cloud CLI Script**:
- Universal installer with automatic architecture detection
- Interactive and silent installation modes
- Component management guidance
- Comprehensive setup instructions for GCP projects

### Prerequisites for Installation Scripts

- **PowerShell**: Windows PowerShell 5.1 or PowerShell Core 7.x
- **Internet Connection**: Required to download installers
- **Execution Policy**: May need to allow script execution:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Post-Installation Configuration

After running the installation scripts, you'll need to configure each tool:

#### Terraform
```bash
terraform --version  # Verify installation
```

#### AWS CLI
```bash
aws --version        # Verify installation
aws configure        # Configure credentials
```

#### Azure CLI
```bash
az --version         # Verify installation
az login            # Authenticate with Azure
az account list     # List available subscriptions
```

#### Google Cloud CLI
```bash
gcloud --version    # Verify installation
gcloud init         # Initialize and authenticate
gcloud auth login   # Authenticate with Google Cloud
```

### Troubleshooting

#### Common Issues

1. **PowerShell Execution Policy**:
   ```powershell
   # If you get execution policy errors:
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **PATH Not Updated**:
   ```powershell
   # Refresh environment variables in current session:
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
   
   # Or restart your PowerShell/Command Prompt session
   ```

3. **Administrator Privileges**:
   - CLI installers may prompt for elevation (this is normal)
   - For Terraform, use default user directory to avoid admin requirements

4. **Download Issues**:
   - Ensure internet connectivity
   - Check if corporate firewall is blocking downloads
   - Verify TLS 1.2 support in your environment

#### Getting Help

Each script provides built-in help and detailed error messages. For additional help:

```powershell
# View script parameters
Get-Help .\tools\install-terraform-windows.ps1 -Detailed
Get-Help .\tools\install-awscli-windows.ps1 -Detailed
```

### Basic Usage

1. **Choose your cloud provider** and navigate to the corresponding example:
   ```bash
   cd examples/aws-workspace     # For AWS
   cd examples/azure-workspace   # For Azure
   cd examples/gcp-workspace     # For GCP
   ```

2. **Configure your variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Deploy the infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 📦 Modules

### AWS Workspace Module

**Location**: `modules/aws-workspace/`

**Features**:
- VPC with public and private subnets
- Security groups and NACLs
- NAT gateways and Internet gateway
- Optional PrivateLink endpoints
- Databricks workspace with MWS configuration

**Key Resources**:
- `databricks_mws_workspaces`
- `databricks_mws_networks`
- `databricks_mws_private_access_settings`
- AWS VPC and networking components

### Azure Workspace Module

**Location**: `modules/azure-workspace/`

**Features**:
- Azure Virtual Network (VNet) with subnets
- Network Security Groups (NSG)
- Route tables and NAT Gateway
- Optional Private Link endpoints
- Databricks workspace with custom network parameters

**Key Resources**:
- `azurerm_databricks_workspace`
- `databricks_mws_private_access_settings`
- Azure VNet and networking components

### GCP Workspace Module

**Location**: `modules/gcp-workspace/`

**Features**:
- GCP VPC network with multiple subnets
- Cloud Router and NAT Gateway
- Optional Private Service Connect (PSC) endpoints
- Databricks workspace with network configuration

**Key Resources**:
- `databricks_mws_workspaces`
- `databricks_mws_networks`
- `databricks_mws_private_access_settings`
- GCP VPC and networking components

### GCP Service Account Provisioning

**Location**: `modules/gcp-sa-provisioning/`

**Features**:
- Service account creation for Databricks
- IAM role assignments
- Key management

## 🌐 Cloud Provider Differences

| Feature | AWS | Azure | GCP |
|---------|-----|-------|-----|
| **Workspace Resource** | `databricks_mws_workspaces` | `azurerm_databricks_workspace` | `databricks_mws_workspaces` |
| **Network Configuration** | `databricks_mws_networks` | Custom parameters in workspace | `databricks_mws_networks` |
| **Private Connectivity** | VPC Endpoints | Private Link | Private Service Connect |
| **Subnets Required** | 2 (public/private) | 2 (public/private) | 3 (primary/pods/services) |
| **NAT Gateway** | AWS NAT Gateway | Azure NAT Gateway | Cloud NAT |

## 🔧 Configuration

### Common Variables

All modules support these common configuration patterns:

- **Naming**: `prefix` variable for consistent resource naming
- **Networking**: Options for new or existing network infrastructure
- **Private Connectivity**: Optional private endpoints/links
- **Databricks Configuration**: Account ID, credentials, workspace settings

### Environment-Specific Variables

Each cloud provider has specific variables:

**AWS**:
- `aws_region`
- `availability_zones`
- `enable_private_link`

**Azure**:
- `location`
- `resource_group_name`
- `enable_private_link`

**GCP**:
- `project_id`
- `region`
- `enable_private_service_connect`

## 🔒 Security Best Practices

### Network Security
- All modules create isolated network environments
- Private subnets for compute resources
- Security groups/NSGs with minimal required access
- Optional private connectivity to Databricks services

### Access Control
- Service principal/service account authentication
- Least privilege IAM policies
- Encrypted storage and transit

### Secrets Management
- Use cloud provider secret managers
- Avoid hardcoding credentials in Terraform files
- Use environment variables or external secret stores

## 📚 Examples

Each example in the `examples/` directory provides:

- Complete working configuration
- `terraform.tfvars.example` with all required variables
- Provider configuration
- Output definitions
- Detailed README with deployment instructions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Guidelines

- Follow Terraform best practices
- Use consistent naming conventions
- Document all variables and outputs
- Test across all supported cloud providers
- Update README files for any changes

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:

1. Check the module-specific README files
2. Review the examples for your cloud provider
3. Open an issue in the repository
4. Consult the [Databricks Terraform Provider documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs)

## 🔄 Version Compatibility

| Component | Version |
|-----------|----------|
| Terraform | >= 1.0.0 |
| Databricks Provider | >= 1.0.0 |
| AWS Provider | >= 3.0.0 |
| Azure Provider | >= 3.0.0 |
| Google Provider | >= 4.0.0 |

---

**Note**: This project provides infrastructure-as-code templates for Databricks workspace deployment. Always review and test configurations in non-production environments before applying to production workloads.