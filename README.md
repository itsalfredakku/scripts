# Desktop Environment and Remote Desktop Setup Scripts

This repository contains a collection of scripts to automate the setup of desktop environments and remote desktop services across different operating systems, including Linux, Unix-like systems (BSD), and Windows.

## Table of Contents

- [Overview](#overview)
- [Linux Scripts](#linux-scripts)
  - [install_gnome_linux.sh](#install_gnome_linuxsh)
  - [setup_xrdp_linux.sh](#setup_xrdp_linuxsh)
- [Unix Scripts](#unix-scripts)
  - [install_gnome_unix.sh](#install_gnome_unixsh)
  - [setup_xrdp_unix.sh](#setup_xrdp_unixsh)
- [Windows Scripts](#windows-scripts)
  - [setup_rdp_windows.ps1](#setup_rdp_windowsps1)
- [Requirements](#requirements)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Overview

These scripts aim to simplify the process of setting up desktop environments and remote desktop services across various operating systems. They handle the installation of necessary packages, configuration of services, and setup of security settings.

## Linux Scripts

### install_gnome_linux.sh

A script to install GNOME desktop environment on various Linux distributions.

**Features:**
- Automatic distribution detection
- Supports minimal or full GNOME installation
- Works with apt, yum, dnf, pacman, and zypper package managers

**Usage:**
```bash
./install_gnome_linux.sh [--minimal]
```

### setup_xrdp_linux.sh

Configures XRDP for remote desktop access on Linux systems.

**Features:**
- Automatic distribution and desktop environment detection
- Installs and configures XRDP for various desktop environments (GNOME, KDE, XFCE, etc.)
- Sets up appropriate firewall rules
- Configures system services for auto-start

**Usage:**
```bash
./setup_xrdp_linux.sh [--no-restart] [--port PORT] [--ssl]
```

## Unix Scripts

### install_gnome_unix.sh

Installs GNOME desktop environment on Unix-like systems such as FreeBSD, OpenBSD, and NetBSD.

**Features:**
- Automatic system detection
- Supports minimal or full GNOME installation
- Works with pkg, pkg_add, pkgin, and other Unix package managers
- Updated to use correct x11/gnome paths for newer package systems

**Usage:**
```bash
./install_gnome_unix.sh [--minimal]
```

### setup_xrdp_unix.sh

Sets up XRDP remote desktop service on Unix-like systems.

**Features:**
- Cross-platform support for FreeBSD, OpenBSD, NetBSD, and other Unix-like systems
- Automatically detects and uses appropriate package managers
- Configures XRDP with desktop-specific settings
- Sets up firewall rules and auto-start options

**Usage:**
```bash
./setup_xrdp_unix.sh [--no-restart] [--port PORT]
```

## Windows Scripts

### setup_rdp_windows.ps1

Configures Remote Desktop Protocol (RDP) services on Windows systems.

**Features:**
- Enables RDP and configures appropriate security settings
- Configures Windows Firewall rules
- Supports custom RDP port configuration
- Adds specified users to Remote Desktop Users group
- Option to toggle Network Level Authentication (NLA)

**Usage:**
```powershell
# Run as Administrator
.\setup_rdp_windows.ps1 [-Port <port_number>] [-Users <user1>,<user2>,...] [-DisableNLA]
```

## Requirements

- Linux/Unix scripts require root/sudo privileges
- Windows script requires Administrator privileges
- Bash shell for Linux/Unix scripts
- PowerShell 5.0+ for Windows script

## Usage

1. Clone or download this repository
2. Make the scripts executable (Linux/Unix):
   ```bash
   chmod +x *.sh
   ```
3. Run the desired script with appropriate permissions

## Troubleshooting

### Common Issues

- **Script fails to detect operating system**: Run with `--debug` flag to see detection logic
- **Package installation fails**: Check internet connectivity and repository availability
- **Remote desktop service doesn't start**: Check system logs with `journalctl -u xrdp` (Linux) or Event Viewer (Windows)
- **Connection refused**: Verify firewall settings and service status

### Logs

- Linux/Unix scripts log to `/var/log/xrdp-setup.log`
- Windows script outputs directly to console with color-coded messages

## CI/CD Testing

This repository includes GitHub Actions workflows for automated testing of the scripts.

### Windows RDP Script Testing

The Windows RDP setup script includes a TestMode parameter designed specifically for CI/CD testing:

```powershell
.\setup_rdp_windows.ps1 -TestMode
```

When run with TestMode, the script:
- Simulates all operations without making actual system changes
- Performs validation checks on paths and configurations
- Reports what actions would be taken in a non-test environment

### GitHub Actions Workflows

Multiple GitHub Actions workflows are set up for testing:

1. **Individual Script Workflows**:
   - Windows RDP setup testing
   - Unix GNOME installation testing

2. **Unified CI/CD Workflow**:
   - Tests all scripts in the repository
   - Detects changes and runs only relevant tests
   - Generates combined test reports

For more information on the CI/CD setup, see the [.github/README.md](.github/README.md) file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Before submitting, ensure that:
- Scripts pass all CI/CD tests
- Any new features include appropriate TestMode implementations
- Documentation is updated to reflect changes

## License

This project is licensed under the MIT License - see the LICENSE file for details.