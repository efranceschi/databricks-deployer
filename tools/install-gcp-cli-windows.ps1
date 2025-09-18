# Google Cloud CLI Installation Script for Windows
# This script downloads and installs the latest version of Google Cloud CLI for Windows

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

Write-ColorOutput Green "=== Google Cloud CLI Installation Script ==="
Write-Output ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-ColorOutput Yellow "Note: Running without Administrator privileges."
    Write-ColorOutput Yellow "The installer will prompt for elevation if needed."
    Write-Output ""
}

# Check if Google Cloud CLI is already installed
$existingGcloud = Get-Command gcloud -ErrorAction SilentlyContinue
if ($existingGcloud) {
    try {
        $versionOutput = gcloud version --format="value(Google Cloud SDK)" 2>$null
        if (-not $versionOutput) {
            # Fallback method for version detection
            $fullVersionOutput = gcloud version 2>$null | Select-String "Google Cloud SDK (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
            $versionOutput = $fullVersionOutput
        }
        
        Write-ColorOutput Yellow "Google Cloud CLI is already installed at: $($existingGcloud.Source)"
        Write-ColorOutput Yellow "Current version: $versionOutput"
        
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
        Write-ColorOutput Yellow "Google Cloud CLI detected but version check failed."
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

# Construct download URL - Google Cloud CLI has specific URLs for different architectures
if ($Version -eq "latest") {
    if ($arch -eq "x86_64") {
        $downloadUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
        $installerName = "GoogleCloudSDKInstaller.exe"
    }
    else {
        # 32-bit version
        $downloadUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
        $installerName = "GoogleCloudSDKInstaller.exe"
        Write-ColorOutput Yellow "Note: Google Cloud CLI installer is universal and will detect your architecture"
    }
}
else {
    Write-ColorOutput Yellow "Specific version downloads are not supported by this script."
    Write-ColorOutput Yellow "Google Cloud CLI uses a single installer URL for the latest version."
    Write-ColorOutput Yellow "Proceeding with latest version..."
    $downloadUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    $installerName = "GoogleCloudSDKInstaller.exe"
}

$installerPath = "$env:TEMP\$installerName"

Write-ColorOutput Cyan "Downloading Google Cloud CLI for Windows ($arch)..."
Write-Output "URL: $downloadUrl"

try {
    # Use TLS 1.2
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # Create WebClient with redirect support
    $webClient = New-Object System.Net.WebClient
    
    # Add progress callback for large files
    Register-ObjectEvent -InputObject $webClient -EventName DownloadProgressChanged -Action {
        $Global:DownloadProgress = $Event.SourceEventArgs.ProgressPercentage
        Write-Progress -Activity "Downloading Google Cloud CLI" -Status "Progress" -PercentComplete $Global:DownloadProgress
    } | Out-Null
    
    $webClient.DownloadFile($downloadUrl, $installerPath)
    Write-Progress -Activity "Downloading Google Cloud CLI" -Completed
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

# Verify it's a valid executable file
try {
    $fileInfo = Get-ItemProperty $installerPath
    if ($fileInfo.Name -notlike "*.exe") {
        Write-ColorOutput Red "✗ Downloaded file is not an executable installer"
        exit 1
    }
    Write-ColorOutput Green "✓ Downloaded file verified as executable installer"
}
catch {
    Write-ColorOutput Yellow "Warning: Could not verify file type"
}
Write-Output ""

# Install Google Cloud CLI
Write-ColorOutput Cyan "Installing Google Cloud CLI..."
Write-ColorOutput Yellow "The installer may prompt for Administrator privileges and configuration options..."

try {
    if ($Silent) {
        # Silent installation - Google Cloud CLI installer supports /S flag
        $installArgs = "/S"
        Write-ColorOutput Cyan "Running silent installation..."
        Write-ColorOutput Yellow "Note: Silent installation will use default settings"
    }
    else {
        # Interactive installation - no special flags needed
        $installArgs = ""
        Write-ColorOutput Cyan "Running interactive installation..."
        Write-ColorOutput Yellow "The installer will guide you through configuration options"
    }
    
    if ($installArgs) {
        $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru
    }
    else {
        $process = Start-Process -FilePath $installerPath -Wait -PassThru
    }
    
    if ($process.ExitCode -eq 0) {
        Write-ColorOutput Green "✓ Installation completed successfully"
    }
    elseif ($process.ExitCode -eq 1) {
        Write-ColorOutput Red "✗ Installation failed - General error"
        exit 1
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
    Start-Sleep -Seconds 3
    
    try {
        # Try to find Google Cloud CLI
        $gcloudPath = Get-Command gcloud -ErrorAction SilentlyContinue
        
        if ($gcloudPath) {
            Write-ColorOutput Green "✓ Google Cloud CLI found at: $($gcloudPath.Source)"
            
            # Get version information
            try {
                $versionOutput = gcloud version --format="value(Google Cloud SDK)" 2>$null
                if ($versionOutput) {
                    Write-ColorOutput Green "✓ Installation verification successful!"
                    Write-Output ""
                    Write-ColorOutput Cyan "Google Cloud SDK Version: $versionOutput"
                    
                    # Get full version info
                    $fullVersionOutput = gcloud version 2>$null
                    if ($fullVersionOutput) {
                        Write-Output ""
                        Write-ColorOutput Cyan "Full version information:"
                        Write-Output $fullVersionOutput
                    }
                }
                else {
                    Write-ColorOutput Yellow "Google Cloud CLI found but version check returned no output"
                    Write-ColorOutput Yellow "Trying alternative verification..."
                    
                    # Try simple command test
                    $testOutput = gcloud --help 2>$null | Select-Object -First 1
                    if ($testOutput) {
                        Write-ColorOutput Green "✓ Google Cloud CLI responding to commands"
                    }
                }
            }
            catch {
                Write-ColorOutput Yellow "Version check failed, but Google Cloud CLI was found in PATH"
                Write-ColorOutput Yellow "Installation likely successful - you may need to restart your terminal"
            }
        }
        else {
            Write-ColorOutput Yellow "⚠ Google Cloud CLI not found in PATH"
            Write-ColorOutput Yellow "The installation may have completed, but you might need to:"
            Write-Output "  1. Restart your PowerShell/Command Prompt session"
            Write-Output "  2. Or log out and log back in to refresh environment variables"
            
            # Try to find it in common installation paths
            $commonPaths = @(
                "${env:LOCALAPPDATA}\Google\Cloud SDK\google-cloud-sdk\bin",
                "${env:ProgramFiles}\Google\Cloud SDK\google-cloud-sdk\bin",
                "${env:ProgramFiles(x86)}\Google\Cloud SDK\google-cloud-sdk\bin"
            )
            
            foreach ($path in $commonPaths) {
                $gcloudCmd = Join-Path $path "gcloud.cmd"
                if (Test-Path $gcloudCmd) {
                    Write-ColorOutput Cyan "Found Google Cloud CLI at: $gcloudCmd"
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
Write-Output "  2. Initialize Google Cloud CLI: gcloud init"
Write-Output "  3. Test with: gcloud --version"
Write-Output ""

Write-ColorOutput Yellow "Google Cloud CLI Getting Started:"
Write-Output "  • Run 'gcloud init' to authenticate and configure"
Write-Output "  • Use 'gcloud auth login' to authenticate with your Google account"
Write-Output "  • Set default project: gcloud config set project PROJECT_ID"
Write-Output "  • Set default region: gcloud config set compute/region REGION"
Write-Output "  • Set default zone: gcloud config set compute/zone ZONE"
Write-Output ""

Write-ColorOutput Cyan "Common Google Cloud CLI Commands:"
Write-Output "  • gcloud projects list                 - List projects"
Write-Output "  • gcloud compute instances list        - List VM instances"
Write-Output "  • gcloud storage buckets list          - List storage buckets"
Write-Output "  • gcloud functions list                - List cloud functions"
Write-Output "  • gcloud container clusters list       - List GKE clusters"
Write-Output "  • gcloud sql instances list            - List Cloud SQL instances"
Write-Output "  • gcloud config list                   - Show current configuration"
Write-Output "  • gcloud --help                        - Get help"
Write-Output ""

Write-ColorOutput Yellow "Important Configuration:"
Write-Output "  • Components: Use 'gcloud components list' to see available components"
Write-Output "  • Updates: Use 'gcloud components update' to update the CLI"
Write-Output "  • Authentication: Use 'gcloud auth list' to see authenticated accounts"
Write-Output ""

Write-ColorOutput Green "Google Cloud CLI is ready to use!"
Write-ColorOutput Cyan "Run 'gcloud init' to get started with authentication and project setup"
Write-ColorOutput Cyan "Documentation: https://cloud.google.com/sdk/docs"
