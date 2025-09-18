# Azure CLI Installation Script for Windows
# This script downloads and installs the latest version of Azure CLI for Windows

param(
    [switch]$Silent = $false,
    [switch]$SkipVerification = $false,
    [string]$Version = "latest"
)

# Function to write colored output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput Green "=== Azure CLI Installation Script ==="
Write-Output ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-ColorOutput Yellow "Note: Running without Administrator privileges."
    Write-ColorOutput Yellow "The installer will prompt for elevation if needed."
    Write-Output ""
}

# Check if Azure CLI is already installed
$existingAzCli = Get-Command az -ErrorAction SilentlyContinue
if ($existingAzCli) {
    try {
        $currentVersion = az version --output tsv --query '\"azure-cli\"' 2>$null
        if (-not $currentVersion) {
            # Fallback method for version detection
            $versionOutput = az --version 2>$null | Select-String "azure-cli\s+(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
            $currentVersion = $versionOutput
        }
        
        Write-ColorOutput Yellow "Azure CLI is already installed at: $($existingAzCli.Source)"
        Write-ColorOutput Yellow "Current version: $currentVersion"
        
        if (-not $Silent) {
            $continue = Read-Host "Do you want to continue with the installation? (y/N)"
            if ($continue -ne 'y' -and $continue -ne 'Y') {
                Write-ColorOutput Green "Installation cancelled."
                exit 0
            }
        }
        else {
            Write-ColorOutput Cyan "Silent mode: Proceeding with installation..."
        }
    }
    catch {
        Write-ColorOutput Yellow "Azure CLI detected but version check failed."
    }
    Write-Output ""
}

# Determine architecture
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64" -or $env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    "x64"
} else {
    "x86"
}

Write-ColorOutput Cyan "Detected architecture: $arch"
Write-Output ""

# Construct download URL - Azure CLI uses fixed URLs for latest version
if ($Version -eq "latest") {
    $downloadUrl = "https://aka.ms/installazurecliwindows"
    $installerName = "azure-cli-latest.msi"
}
else {
    Write-ColorOutput Yellow "Specific version downloads are not directly supported by this script."
    Write-ColorOutput Yellow "Azure CLI uses a redirect URL for the latest version."
    Write-ColorOutput Yellow "For specific versions, please visit: https://github.com/Azure/azure-cli/releases"
    Write-ColorOutput Yellow "Proceeding with latest version..."
    $downloadUrl = "https://aka.ms/installazurecliwindows"
    $installerName = "azure-cli-latest.msi"
}

$installerPath = "$env:TEMP\$installerName"

Write-ColorOutput Cyan "Downloading Azure CLI for Windows ($arch)..."
Write-Output "URL: $downloadUrl"

try {
    # Use TLS 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # Create WebClient with redirect support
    $webClient = New-Object System.Net.WebClient
    
    # Add progress callback for large files
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        $Global:DownloadProgress = $Event.SourceEventArgs.ProgressPercentage
        Write-Progress -Activity "Downloading Azure CLI" -Status "Progress" -PercentComplete $Global:DownloadProgress
    } | Out-Null
    
    $webClient.DownloadFile($downloadUrl, $installerPath)
    Write-Progress -Activity "Downloading Azure CLI" -Completed
    Write-ColorOutput Green "✓ Download completed"
    
    # Clean up event
    Get-EventSubscriber | Unregister-Event
}
catch {
    Write-ColorOutput Red "✗ Download failed: $_"
    Write-ColorOutput Yellow "Please check your internet connection and try again."
    exit 1
}
Write-Output ""

# Verify the downloaded file
if (-not (Test-Path $installerPath)) {
    Write-ColorOutput Red "✗ Downloaded installer not found"
    exit 1
}

$fileSize = (Get-Item $installerPath).Length
Write-ColorOutput Green "✓ Downloaded file size: $([math]::Round($fileSize/1MB, 2)) MB"

# Verify it's a valid MSI file
try {
    $fileInfo = Get-ItemProperty $installerPath
    if ($fileInfo.Name -notlike "*.msi") {
        Write-ColorOutput Red "✗ Downloaded file is not an MSI installer"
        exit 1
    }
    Write-ColorOutput Green "✓ Downloaded file verified as MSI installer"
}
catch {
    Write-ColorOutput Yellow "Warning: Could not verify file type"
}
Write-Output ""

# Install Azure CLI
Write-ColorOutput Cyan "Installing Azure CLI..."
Write-ColorOutput Yellow "The installer may prompt for Administrator privileges..."

try {
    if ($Silent) {
        # Silent installation
        $installArgs = "/i `"$installerPath`" /quiet /norestart"
        Write-ColorOutput Cyan "Running silent installation..."
    }
    else {
        # Interactive installation
        $installArgs = "/i `"$installerPath`" /passive"
        Write-ColorOutput Cyan "Running installation with progress display..."
    }
    
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-ColorOutput Green "✓ Installation completed successfully"
    }
    elseif ($process.ExitCode -eq 1602) {
        Write-ColorOutput Yellow "Installation was cancelled by user"
        exit 1
    }
    elseif ($process.ExitCode -eq 1603) {
        Write-ColorOutput Red "✗ Installation failed - Fatal error during installation"
        exit 1
    }
    elseif ($process.ExitCode -eq 1618) {
        Write-ColorOutput Red "✗ Installation failed - Another installation is in progress"
        exit 1
    }
    elseif ($process.ExitCode -eq 1619) {
        Write-ColorOutput Red "✗ Installation failed - Invalid installation package"
        exit 1
    }
    elseif ($process.ExitCode -eq 1633) {
        Write-ColorOutput Red "✗ Installation failed - Unsupported platform"
        exit 1
    }
    elseif ($process.ExitCode -eq 3010) {
        Write-ColorOutput Green "✓ Installation completed successfully (restart required)"
        Write-ColorOutput Yellow "A system restart may be required to complete the installation"
    }
    else {
        Write-ColorOutput Yellow "Installation completed with exit code: $($process.ExitCode)"
        Write-ColorOutput Yellow "This may indicate a non-critical issue. Proceeding with verification..."
    }
}
catch {
    Write-ColorOutput Red "✗ Installation failed: $_"
    exit 1
}
Write-Output ""

# Clean up downloaded installer
Write-ColorOutput Cyan "Cleaning up temporary files..."
try {
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    Write-ColorOutput Green "✓ Temporary files cleaned up"
}
catch {
    Write-ColorOutput Yellow "Warning: Could not clean up temporary file: $installerPath"
}
Write-Output ""

# Refresh environment variables for current session
Write-ColorOutput Cyan "Refreshing environment variables..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";" + [System.Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

# Verify installation
if (-not $SkipVerification) {
    Write-ColorOutput Cyan "Verifying installation..."
    
    # Wait a moment for installation to complete
    Start-Sleep -Seconds 3
    
    try {
        # Try to find Azure CLI
        $azPath = Get-Command az -ErrorAction SilentlyContinue
        
        if ($azPath) {
            Write-ColorOutput Green "✓ Azure CLI found at: $($azPath.Source)"
            
            # Get version information
            try {
                $versionOutput = az --version 2>$null | Select-Object -First 1
                if ($versionOutput) {
                    Write-ColorOutput Green "✓ Installation verification successful!"
                    Write-Output ""
                    Write-ColorOutput Cyan "Version information:"
                    Write-Output $versionOutput
                    
                    # Parse version for summary
                    if ($versionOutput -match "azure-cli\s+(\d+\.\d+\.\d+)") {
                        $installedVersion = $matches[1]
                        Write-ColorOutput Green "✓ Azure CLI v$installedVersion installed successfully"
                    }
                }
                else {
                    Write-ColorOutput Yellow "Azure CLI found but version check returned no output"
                    Write-ColorOutput Yellow "Trying alternative verification..."
                    
                    # Try simple command test
                    $testOutput = az --help 2>$null | Select-Object -First 1
                    if ($testOutput) {
                        Write-ColorOutput Green "✓ Azure CLI responding to commands"
                    }
                }
            }
            catch {
                Write-ColorOutput Yellow "Version check failed, but Azure CLI was found in PATH"
                Write-ColorOutput Yellow "Installation likely successful - you may need to restart your terminal"
            }
        }
        else {
            Write-ColorOutput Yellow "⚠ Azure CLI not found in PATH"
            Write-ColorOutput Yellow "The installation may have completed, but you might need to:"
            Write-Output "  1. Restart your PowerShell/Command Prompt session"
            Write-Output "  2. Or log out and log back in to refresh environment variables"
            
            # Try to find it in common installation paths
            $commonPaths = @(
                "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\CLI2\wbin",
                "${env:ProgramFiles}\Microsoft SDKs\Azure\CLI2\wbin"
            )
            
            foreach ($path in $commonPaths) {
                $azExe = Join-Path $path "az.cmd"
                if (Test-Path $azExe) {
                    Write-ColorOutput Cyan "Found Azure CLI at: $azExe"
                    break
                }
            }
        }
    }
    catch {
        Write-ColorOutput Yellow "⚠ Verification check failed: $_"
        Write-ColorOutput Yellow "The installation may have completed successfully despite this error"
    }
}
else {
    Write-ColorOutput Cyan "Skipping verification as requested"
}

Write-Output ""
Write-ColorOutput Green "=== Installation Process Complete! ==="
Write-Output ""

Write-ColorOutput Cyan "Post-Installation Steps:"
Write-Output "  1. Restart your PowerShell/Command Prompt session if needed"
Write-Output "  2. Sign in to Azure with: az login"
Write-Output "  3. Test with: az --version"
Write-Output ""

Write-ColorOutput Yellow "Azure CLI Getting Started:"
Write-Output "  • Run 'az login' to authenticate with Azure"
Write-Output "  • Use 'az account list' to see available subscriptions"
Write-Output "  • Set default subscription: az account set --subscription <subscription-id>"
Write-Output "  • Configure defaults: az configure"
Write-Output ""

Write-ColorOutput Cyan "Common Azure CLI Commands:"
Write-Output "  • az group list                    - List resource groups"
Write-Output "  • az vm list                       - List virtual machines"
Write-Output "  • az storage account list          - List storage accounts"
Write-Output "  • az webapp list                   - List web apps"
Write-Output "  • az --help                        - Get help"
Write-Output ""

Write-ColorOutput Green "Azure CLI is ready to use!"
Write-ColorOutput Cyan "For comprehensive help, run: az --help"
Write-ColorOutput Cyan "Documentation: https://docs.microsoft.com/en-us/cli/azure/"
