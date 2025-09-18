# Terraform Installation Script for Windows
# This script downloads and installs the latest version of Terraform for Windows

param(
    [string]$InstallPath = "$env:LOCALAPPDATA\Terraform",
    [switch]$AddToPath = $true,
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

Write-ColorOutput Green "=== Terraform Installation Script ==="
Write-Output ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin -and $InstallPath.StartsWith($env:ProgramFiles)) {
    Write-ColorOutput Red "Warning: Installing to Program Files requires Administrator privileges."
    Write-ColorOutput Yellow "Consider running as Administrator or using default user location: $env:LOCALAPPDATA\Terraform"
    Write-Output ""
}

# Check if Terraform is already installed
$existingTerraform = Get-Command terraform -ErrorAction SilentlyContinue
if ($existingTerraform) {
    $currentVersion = terraform version | Select-String "Terraform v(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    Write-ColorOutput Yellow "Terraform is already installed at: $($existingTerraform.Source)"
    Write-ColorOutput Yellow "Current version: v$currentVersion"
    
    $continue = Read-Host "Do you want to continue with the installation? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-ColorOutput Green "Installation cancelled."
        exit 0
    }
    Write-Output ""
}

# Create installation directory
Write-ColorOutput Cyan "Creating installation directory: $InstallPath"
if (-not (Test-Path $InstallPath)) {
    try {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-ColorOutput Green "✓ Directory created successfully"
    }
    catch {
        Write-ColorOutput Red "✗ Failed to create directory: $_"
        exit 1
    }
}
else {
    Write-ColorOutput Green "✓ Directory already exists"
}
Write-Output ""

# Determine the latest version if not specified
if ($Version -eq "latest") {
    Write-ColorOutput Cyan "Fetching latest Terraform version..."
    try {
        $releasesUrl = "https://api.github.com/repos/hashicorp/terraform/releases/latest"
        $response = Invoke-RestMethod -Uri $releasesUrl -UseBasicParsing
        $Version = $response.tag_name.TrimStart('v')
        Write-ColorOutput Green "✓ Latest version: v$Version"
    }
    catch {
        Write-ColorOutput Red "✗ Failed to fetch latest version: $_"
        Write-ColorOutput Yellow "Falling back to version 1.9.5"
        $Version = "1.9.5"
    }
}
else {
    $Version = $Version.TrimStart('v')
}
Write-Output ""

# Determine architecture
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64" -or $env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    "amd64"
} else {
    "386"
}

# Construct download URL
$downloadUrl = "https://releases.hashicorp.com/terraform/$Version/terraform_${Version}_windows_${arch}.zip"
$zipPath = "$env:TEMP\terraform_${Version}_windows_${arch}.zip"

Write-ColorOutput Cyan "Downloading Terraform v$Version for Windows ($arch)..."
Write-Output "URL: $downloadUrl"

try {
    # Use TLS 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # Download with progress
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $zipPath)
    Write-ColorOutput Green "✓ Download completed"
}
catch {
    Write-ColorOutput Red "✗ Download failed: $_"
    Write-ColorOutput Yellow "Please check your internet connection and try again."
    exit 1
}
Write-Output ""

# Extract the zip file
Write-ColorOutput Cyan "Extracting Terraform..."
try {
    # Remove existing terraform.exe if it exists
    $terraformExe = Join-Path $InstallPath "terraform.exe"
    if (Test-Path $terraformExe) {
        Remove-Item $terraformExe -Force
    }
    
    # Extract using .NET classes (works on all Windows versions)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $InstallPath)
    Write-ColorOutput Green "✓ Extraction completed"
}
catch {
    Write-ColorOutput Red "✗ Extraction failed: $_"
    exit 1
}
Write-Output ""

# Clean up downloaded zip
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Add to PATH if requested
if ($AddToPath) {
    Write-ColorOutput Cyan "Adding Terraform to PATH..."
    
    # Get current user PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
    
    if ($currentPath -notlike "*$InstallPath*") {
        try {
            $newPath = if ($currentPath) { "$currentPath;$InstallPath" } else { $InstallPath }
            [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
            Write-ColorOutput Green "✓ Added to user PATH"
            Write-ColorOutput Yellow "Note: You may need to restart your PowerShell session for PATH changes to take effect"
        }
        catch {
            Write-ColorOutput Red "✗ Failed to add to PATH: $_"
            Write-ColorOutput Yellow "You can manually add '$InstallPath' to your PATH environment variable"
        }
    }
    else {
        Write-ColorOutput Green "✓ Already in PATH"
    }
}
Write-Output ""

# Verify installation
Write-ColorOutput Cyan "Verifying installation..."
try {
    # Temporarily add to current session PATH
    $env:Path = "$InstallPath;$env:Path"
    
    $terraformPath = Join-Path $InstallPath "terraform.exe"
    if (Test-Path $terraformPath) {
        $versionOutput = & $terraformPath version
        Write-ColorOutput Green "✓ Installation successful!"
        Write-ColorOutput Green "✓ Terraform installed at: $terraformPath"
        Write-Output ""
        Write-ColorOutput Cyan "Version information:"
        Write-Output $versionOutput
    }
    else {
        Write-ColorOutput Red "✗ terraform.exe not found at expected location"
        exit 1
    }
}
catch {
    Write-ColorOutput Red "✗ Verification failed: $_"
    exit 1
}

Write-Output ""
Write-ColorOutput Green "=== Installation Complete! ==="
Write-Output ""
Write-ColorOutput Cyan "Installation Details:"
Write-Output "  Location: $InstallPath"
Write-Output "  Version: v$Version"
Write-Output "  Architecture: $arch"
Write-Output ""

if ($AddToPath) {
    Write-ColorOutput Yellow "Important: If this is your first installation, you may need to:"
    Write-Output "  1. Restart your PowerShell/Command Prompt session"
    Write-Output "  2. Or run: `$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User')"
    Write-Output ""
}

Write-ColorOutput Green "You can now use 'terraform' commands!"
Write-ColorOutput Cyan "Try running: terraform --help"
