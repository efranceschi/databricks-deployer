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
└── examples/                  # Example implementations
    ├── aws-workspace/         # AWS workspace deployment example
    ├── azure-workspace/       # Azure workspace deployment example
    ├── gcp-workspace/         # GCP workspace deployment example
    └── gcp-sa-provisioning/   # GCP service account example
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