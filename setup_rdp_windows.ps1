# ============================================================================
# Windows Remote Desktop Protocol (RDP) Setup Script
# ============================================================================
# This script automates the configuration of Remote Desktop Services on Windows.
# It enables RDP, configures firewall rules, and sets appropriate security settings.
# 
# Author: GitHub Copilot
# Date: May 26, 2025
# ============================================================================

# Ensure script is running with administrative privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrative privileges. Please run as Administrator."
    exit 1
}

# Function to log messages with timestamps
function Write-LogMessage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "SUCCESS" { "Green" }
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Function to check Windows version and edition
function Get-WindowsInfo {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $edition = $osInfo.Caption
    $version = [Version]$osInfo.Version
    
    Write-LogMessage "Detected Windows: $edition (Version $version)" -Level "INFO"
    
    # Check if Windows version supports RDP
    if ($version.Major -lt 6) {
        Write-LogMessage "This script requires Windows Vista/Server 2008 or later." -Level "ERROR"
        exit 1
    }
    
    # Check if it's a Home edition (which doesn't support RDP server)
    if ($edition -match "Home") {
        Write-LogMessage "Windows Home editions do not support hosting Remote Desktop Services." -Level "ERROR"
        Write-LogMessage "Consider upgrading to Windows Professional or Enterprise edition." -Level "INFO"
        exit 1
    }
    
    return $edition
}

# Function to enable Remote Desktop
function Enable-RemoteDesktop {
    Write-LogMessage "Enabling Remote Desktop..." -Level "INFO"
    
    try {
        if (-not $TestMode) {
            # Enable Remote Desktop
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force
            
            # Enable Network Level Authentication (NLA) for enhanced security
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1 -Force
            
            # Allow RDP through Windows Firewall
            Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
            
            Write-LogMessage "Remote Desktop has been enabled successfully." -Level "SUCCESS"
        } else {
            Write-LogMessage "Test Mode: Would enable Remote Desktop with the following settings:" -Level "INFO"
            Write-LogMessage "Test Mode: - Set fDenyTSConnections to 0" -Level "INFO"
            Write-LogMessage "Test Mode: - Set UserAuthentication to 1" -Level "INFO"
            Write-LogMessage "Test Mode: - Enable Windows Firewall rule for Remote Desktop" -Level "INFO"
        }
    }
    catch {
        Write-LogMessage "Failed to enable Remote Desktop: $_" -Level "ERROR"
        if (-not $TestMode) { exit 1 }
    }
}

# Function to configure RDP security settings
function Set-RDPSecurity {
    Write-LogMessage "Configuring RDP security settings..." -Level "INFO"
    
    try {
        if (-not $TestMode) {
            # Configure encryption level to high
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "MinEncryptionLevel" -Value 3 -Force
            
            # Set maximum number of connections (adjust as needed)
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "MaxConnectionCount" -Value 2 -Force
            
            # Disable drive redirection for security (comment this out if you need drive redirection)
            # Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services' -Name "fDisableCdm" -Value 1 -Force
            
            Write-LogMessage "RDP security settings have been configured." -Level "SUCCESS"
        } else {
            Write-LogMessage "Test Mode: Would configure RDP security with the following settings:" -Level "INFO"
            Write-LogMessage "Test Mode: - Set MinEncryptionLevel to 3 (High)" -Level "INFO"
            Write-LogMessage "Test Mode: - Set MaxConnectionCount to 2" -Level "INFO"
        }
    }
    catch {
        Write-LogMessage "Failed to configure RDP security settings: $_" -Level "WARNING"
    }
}

# Function to set RDP port (optional)
function Set-RDPPort {
    param (
        [int]$Port = 3389  # Default RDP port
    )
    
    if ($Port -ne 3389) {
        Write-LogMessage "Changing RDP port to $Port..." -Level "INFO"
        
        try {
            if (-not $TestMode) {
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "PortNumber" -Value $Port -Force
                
                # Update firewall rule for the new port
                $existingRule = Get-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)" -ErrorAction SilentlyContinue
                
                if ($existingRule) {
                    Set-NetFirewallRule -DisplayName "Remote Desktop - User Mode (TCP-In)" -LocalPort $Port
                }
                else {
                    New-NetFirewallRule -DisplayName "Remote Desktop - Custom Port" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow
                }
                
                Write-LogMessage "RDP port has been changed to $Port. A system restart is required for this change to take effect." -Level "SUCCESS"
            } else {
                Write-LogMessage "Test Mode: Would change RDP port to $Port with the following actions:" -Level "INFO"
                Write-LogMessage "Test Mode: - Set PortNumber registry value to $Port" -Level "INFO"
                Write-LogMessage "Test Mode: - Update or create firewall rule for port $Port" -Level "INFO"
            }
        }
        catch {
            Write-LogMessage "Failed to change RDP port: $_" -Level "ERROR"
        }
    }
}

# Function to restart the RDP service
function Restart-RDPService {
    Write-LogMessage "Restarting Remote Desktop services..." -Level "INFO"
    
    try {
        if (-not $TestMode) {
            Restart-Service -Name "TermService" -Force
            Write-LogMessage "Remote Desktop services restarted successfully." -Level "SUCCESS"
        } else {
            Write-LogMessage "Test Mode: Would restart the TermService service" -Level "INFO"
        }
    }
    catch {
        Write-LogMessage "Failed to restart Remote Desktop services: $_" -Level "ERROR"
    }
}

# Function to add users to Remote Desktop Users group
function Add-RDPUsers {
    param (
        [string[]]$Users
    )
    
    if ($Users.Count -gt 0) {
        Write-LogMessage "Adding users to the Remote Desktop Users group..." -Level "INFO"
        
        foreach ($user in $Users) {
            try {
                if (-not $TestMode) {
                    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $user -ErrorAction Stop
                    Write-LogMessage "Added user '$user' to Remote Desktop Users group." -Level "SUCCESS"
                } else {
                    Write-LogMessage "Test Mode: Would add user '$user' to Remote Desktop Users group" -Level "INFO"
                }
            }
            catch {
                Write-LogMessage "Failed to add user '$user' to Remote Desktop Users group: $_" -Level "ERROR"
            }
        }
    }
}

# Parse command line arguments
param (
    [int]$Port = 3389,
    [string[]]$Users = @(),
    [switch]$DisableNLA = $false,
    [switch]$TestMode = $false
)

# Main execution block
Write-LogMessage "Starting Windows RDP setup script" -Level "INFO"

# Check if running in test mode
if ($TestMode) {
    Write-LogMessage "Running in TEST MODE - No actual system changes will be made" -Level "WARNING"
}

# Get Windows information
if (-not $TestMode) {
    $windowsEdition = Get-WindowsInfo
} else {
    Write-LogMessage "Test Mode: Skipping Windows version check" -Level "INFO"
    $windowsEdition = "Windows Test Environment"
}

# Enable Remote Desktop
Enable-RemoteDesktop

# If NLA is to be disabled (less secure, but more compatible with older clients)
if ($DisableNLA) {
    Write-LogMessage "Disabling Network Level Authentication (not recommended)..." -Level "WARNING"
    if (-not $TestMode) {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -Force
    } else {
        Write-LogMessage "Test Mode: Would disable Network Level Authentication by setting UserAuthentication to 0" -Level "INFO"
    }
}

# Configure RDP security
Set-RDPSecurity

# Set custom RDP port if specified
Set-RDPPort -Port $Port

# Add users to Remote Desktop Users group
Add-RDPUsers -Users $Users

# Restart the RDP service
Restart-RDPService

Write-LogMessage "RDP setup complete. Your system is now configured for remote desktop connections." -Level "SUCCESS"
Write-LogMessage "For the changes to take full effect, it's recommended to restart the computer." -Level "INFO"