# AWS CLI Installation Script for Windows
# This script downloads and installs the latest version of AWS CLI for Windows

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

Write-ColorOutput Green "=== AWS CLI Installation Script ==="
Write-Output ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-ColorOutput Yellow "Note: Running without Administrator privileges."
    Write-ColorOutput Yellow "The installer will prompt for elevation if needed."
    Write-Output ""
}

# Check if AWS CLI is already installed
$existingAwsCli = Get-Command aws -ErrorAction SilentlyContinue
if ($existingAwsCli) {
    try {
        $currentVersion = aws --version 2>$null | Select-String "aws-cli/(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
        Write-ColorOutput Yellow "AWS CLI is already installed at: $($existingAwsCli.Source)"
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
        Write-ColorOutput Yellow "AWS CLI detected but version check failed."
    }
    Write-Output ""
}

# Determine architecture
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64" -or $env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    "x86_64"
} else {
    "x86"
}

Write-ColorOutput Cyan "Detected architecture: $arch"
Write-Output ""

# Construct download URL - AWS CLI uses fixed URLs for latest version
if ($Version -eq "latest") {
    if ($arch -eq "x86_64") {
        $downloadUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
        $installerName = "AWSCLIV2.msi"
    }
    else {
        # AWS CLI v2 only supports 64-bit, fall back to v1 for 32-bit
        Write-ColorOutput Yellow "AWS CLI v2 only supports 64-bit Windows."
        Write-ColorOutput Yellow "For 32-bit systems, please install manually from AWS documentation."
        exit 1
    }
}
else {
    Write-ColorOutput Yellow "Specific version downloads are not supported by this script."
    Write-ColorOutput Yellow "AWS CLI uses a single download URL for the latest version."
    Write-ColorOutput Yellow "Proceeding with latest version..."
    $downloadUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    $installerName = "AWSCLIV2.msi"
}

$installerPath = "$env:TEMP\$installerName"

Write-ColorOutput Cyan "Downloading AWS CLI v2 for Windows ($arch)..."
Write-Output "URL: $downloadUrl"

try {
    # Use TLS 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # Download with progress
    $webClient = New-Object System.Net.WebClient
    
    # Add progress callback for large files
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        $Global:DownloadProgress = $Event.SourceEventArgs.ProgressPercentage
        Write-Progress -Activity "Downloading AWS CLI" -Status "Progress" -PercentComplete $Global:DownloadProgress
    } | Out-Null
    
    $webClient.DownloadFile($downloadUrl, $installerPath)
    Write-Progress -Activity "Downloading AWS CLI" -Completed
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
Write-Output ""

# Install AWS CLI
Write-ColorOutput Cyan "Installing AWS CLI..."
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
    Start-Sleep -Seconds 2
    
    try {
        # Try to find AWS CLI
        $awsPath = Get-Command aws -ErrorAction SilentlyContinue
        
        if ($awsPath) {
            Write-ColorOutput Green "✓ AWS CLI found at: $($awsPath.Source)"
            
            # Get version information
            $versionOutput = & aws --version 2>$null
            if ($versionOutput) {
                Write-ColorOutput Green "✓ Installation verification successful!"
                Write-Output ""
                Write-ColorOutput Cyan "Version information:"
                Write-Output $versionOutput
                
                # Parse version for summary
                if ($versionOutput -match "aws-cli/(\d+\.\d+\.\d+)") {
                    $installedVersion = $matches[1]
                    Write-ColorOutput Green "✓ AWS CLI v$installedVersion installed successfully"
                }
            }
            else {
                Write-ColorOutput Yellow "AWS CLI found but version check returned no output"
                Write-ColorOutput Yellow "This may indicate a PATH issue or the need to restart your terminal"
            }
        }
        else {
            Write-ColorOutput Yellow "⚠ AWS CLI not found in PATH"
            Write-ColorOutput Yellow "The installation may have completed, but you might need to:"
            Write-Output "  1. Restart your PowerShell/Command Prompt session"
            Write-Output "  2. Or log out and log back in to refresh environment variables"
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
Write-Output "  2. Configure AWS CLI with: aws configure"
Write-Output "  3. Test with: aws --version"
Write-Output ""

Write-ColorOutput Yellow "AWS CLI Configuration:"
Write-Output "  • Run 'aws configure' to set up your AWS credentials"
Write-Output "  • You'll need your AWS Access Key ID and Secret Access Key"
Write-Output "  • Choose your default region (e.g., us-east-1, us-west-2)"
Write-Output "  • Select default output format (json, text, table, yaml)"
Write-Output ""

Write-ColorOutput Green "AWS CLI is ready to use!"
Write-ColorOutput Cyan "For help, run: aws help"
