# CI/CD Testing for System Setup Scripts

This directory contains GitHub Actions workflow configurations for testing various system setup scripts in a continuous integration environment.

## Available Workflows

### 1. Unified System Scripts CI/CD

The `system-scripts-ci.yml` workflow is a comprehensive testing pipeline that:
- Detects changes to specific script files
- Runs appropriate tests based on what files changed
- Generates combined test reports
- Optimizes CI resources by running only necessary tests

### 2. Windows RDP Setup Testing

The `test-windows-rdp.yml` workflow specifically tests the PowerShell RDP setup script whenever changes are made to it.

### 3. Unix GNOME Installation Testing

The `test-unix-gnome.yml` workflow tests the Unix GNOME installation script, verifying its compatibility with BSD systems and ensuring proper package paths are used.

### What the Windows RDP Workflow Tests

1. **Syntax Validation**: Checks that the PowerShell script has no syntax errors.
2. **TestMode Implementation**: Verifies that the script properly implements a TestMode parameter for CI/CD testing.
3. **Registry Path Validation**: Ensures that the script references the correct Windows registry paths.
4. **Function Call Verification**: Confirms that all defined functions are properly called in the main execution block.
5. **End-to-End Test Run**: Executes the script with the TestMode flag to simulate a complete run without making actual system changes.

### What the Unix GNOME Workflow Tests

1. **Syntax Validation**: Uses shellcheck and bash -n to verify shell script syntax.
2. **Package Path Verification**: Confirms that the script uses the correct x11/gnome paths for BSD systems.
3. **Error Handling**: Verifies that proper error handling is implemented.
4. **Command Existence Checks**: Ensures the script properly checks for required commands before using them.
5. **Test Mode Execution**: Runs the script with a test parameter that prevents system changes.

### Test Reports

After each workflow run, a test report is generated and saved as an artifact that can be downloaded from the GitHub Actions interface.

## Local Testing

### Testing the Windows RDP Script

You can test the Windows RDP script locally before pushing to GitHub by running:

```powershell
# Syntax check
powershell -Command "& { [System.Management.Automation.Language.Parser]::ParseFile('setup_rdp_windows.ps1', [ref]$null, [ref]$null) }"

# Test run with TestMode
powershell -ExecutionPolicy Bypass -File setup_rdp_windows.ps1 -TestMode
```

### Testing the Unix GNOME Script

You can test the Unix GNOME installation script locally before pushing:

```bash
# Syntax check
bash -n install_gnome_unix.sh
shellcheck install_gnome_unix.sh

# Test with modified script that supports test mode
./install_gnome_unix.sh --test --yes
```

## Test Mode Parameters

### Windows TestMode Parameter

The TestMode parameter allows the Windows RDP script to run in a simulation mode where:
- No actual system changes are made
- All operations are logged as if they were performed
- Appropriate success messages are displayed
- The script still performs validation checks

This enables safe testing in CI/CD environments without modifying the actual system configuration.

### Unix Test Mode

The Unix GNOME installation script's test mode:
- Simulates installation of packages without actually installing them
- Logs what actions would have been performed
- Skips the root privilege check
- Allows validation of script logic without system changes

## Adding More Tests

To extend the test coverage:

1. Add new test steps to the workflow YAML files
2. Enhance the scripts' test mode capabilities
3. Consider adding more validation checks for security best practices
4. Add workflows for other scripts in the repository

## Workflow Maintenance

When updating GitHub Actions workflows:
1. Verify all required actions exist and are up-to-date
2. Consider using actions/checkout@v4 (latest stable version)
3. Avoid unnecessary setup steps for tools that are pre-installed on runners
4. Test workflows with workflow_dispatch before relying on automated triggers
