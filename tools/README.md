# 🛠️ Installation Tools

This directory contains PowerShell scripts to automatically download and install the required CLI tools for Databricks deployments on Windows systems.

## 📦 Available Scripts

| Script | Tool | Version Support | Admin Required |
|--------|------|----------------|----------------|
| [`install-terraform-windows.ps1`](install-terraform-windows.ps1) | Terraform | ✅ Specific versions | ❌ No (default location) |
| [`install-awscli-windows.ps1`](install-awscli-windows.ps1) | AWS CLI v2 | ❌ Latest only | ⚠️ UAC prompt |
| [`install-azurecli-windows.ps1`](install-azurecli-windows.ps1) | Azure CLI | ❌ Latest only | ⚠️ UAC prompt |
| [`install-gcp-cli-windows.ps1`](install-gcp-cli-windows.ps1) | Google Cloud CLI | ❌ Latest only | ⚠️ UAC prompt |

## 🚀 Quick Start

Run all installations with default settings:

```powershell
# Navigate to the tools directory
cd tools

# Install all tools (will prompt for admin elevation where needed)
.\install-terraform-windows.ps1
.\install-awscli-windows.ps1
.\install-azurecli-windows.ps1
.\install-gcp-cli-windows.ps1
```

## 📋 Prerequisites

- **PowerShell**: Windows PowerShell 5.1 or PowerShell Core 7.x
- **Internet Connection**: Required to download installers
- **Execution Policy**: Set to allow script execution:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## 🔧 Script Features

### Universal Features (All Scripts)
- ✅ **Latest Version Detection**: Automatically fetch the newest versions
- ✅ **Architecture Detection**: Support for both 32-bit and 64-bit systems
- ✅ **Existing Installation Check**: Detect and handle existing installations
- ✅ **Progress Feedback**: Visual progress indicators during download/installation
- ✅ **Error Handling**: Comprehensive error handling with helpful messages
- ✅ **PATH Management**: Automatic environment variable updates
- ✅ **Verification**: Post-installation testing and validation
- ✅ **Cleanup**: Automatic removal of temporary files

### Script-Specific Features

#### `install-terraform-windows.ps1`
- **Portable Installation**: No admin rights required (installs to user directory)
- **Custom Locations**: Support for custom installation paths
- **Version Selection**: Install specific Terraform versions
- **ZIP Extraction**: Uses .NET compression for compatibility

#### CLI Scripts (`install-*cli-windows.ps1`)
- **MSI/EXE Installers**: Use official distribution methods
- **Silent Installation**: Support for unattended installations
- **UAC Handling**: Automatic elevation prompts when needed
- **Installation Verification**: Multiple verification methods

## 🔒 Administrator Requirements

| Tool | Start Script | During Install | UAC Prompt |
|------|-------------|---------------|------------|
| **Terraform** | ❌ No | ❌ No* | ❌ No |
| **AWS CLI** | ❌ No | ✅ Yes | ✅ Yes |
| **Azure CLI** | ❌ No | ✅ Yes | ✅ Yes |
| **Google Cloud CLI** | ❌ No | ✅ Yes | ✅ Yes |

*Only requires admin if installing to Program Files directory.

## 📖 Usage Examples

### Basic Installation
```powershell
# Install with all defaults
.\install-terraform-windows.ps1
```

### Advanced Terraform Installation
```powershell
# Custom installation directory
.\install-terraform-windows.ps1 -InstallPath "C:\Tools\Terraform"

# Specific version
.\install-terraform-windows.ps1 -Version "1.6.0"

# Don't add to PATH
.\install-terraform-windows.ps1 -AddToPath:$false
```

### Silent CLI Installation
```powershell
# Unattended installation (good for automation)
.\install-awscli-windows.ps1 -Silent -SkipVerification
.\install-azurecli-windows.ps1 -Silent -SkipVerification
.\install-gcp-cli-windows.ps1 -Silent -SkipVerification
```

## 🔍 Post-Installation Verification

After running the scripts, verify installations:

```powershell
# Check versions
terraform --version
aws --version
az --version
gcloud --version

# Configure tools (as needed)
aws configure
az login
gcloud init
```

## 🆘 Troubleshooting

### Common Issues

1. **Execution Policy Error**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **PATH Not Updated**:
   ```powershell
   # Refresh current session
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
   ```

3. **Download Failures**:
   - Check internet connectivity
   - Verify corporate firewall settings
   - Ensure TLS 1.2 support

4. **Installation Failures**:
   - Try running PowerShell as Administrator
   - Check available disk space
   - Verify Windows version compatibility

### Getting Help

```powershell
# View detailed help for any script
Get-Help .\install-terraform-windows.ps1 -Detailed
Get-Help .\install-awscli-windows.ps1 -Full
```

## 📝 Script Parameters Reference

### Common Parameters (CLI Scripts)
- `-Silent`: Skip user prompts
- `-SkipVerification`: Skip post-installation verification
- `-Version`: Install specific version (limited support)

### Terraform-Specific Parameters
- `-InstallPath`: Custom installation directory
- `-AddToPath`: Add to PATH environment variable
- `-Version`: Specific Terraform version to install

## 🔄 Updates and Maintenance

These scripts always download the latest versions by default. To update installed tools:

```powershell
# Re-run scripts to get latest versions
.\install-terraform-windows.ps1
.\install-awscli-windows.ps1
.\install-azurecli-windows.ps1
.\install-gcp-cli-windows.ps1
```

Or use built-in update mechanisms:
```bash
# Update cloud CLI tools
az upgrade                    # Azure CLI
gcloud components update      # Google Cloud CLI
# AWS CLI updates via re-installation
```

---

**Note**: These scripts are designed for Windows systems only. For other operating systems, please refer to the official installation documentation for each tool.
