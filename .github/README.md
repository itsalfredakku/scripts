# CI/CD Testing for Windows RDP Setup Script

This directory contains GitHub Actions workflow configurations for testing the Windows RDP setup scripts in a continuous integration environment.

## Workflow Overview

The `test-windows-rdp.yml` workflow automatically tests the PowerShell RDP setup script whenever changes are pushed to the repository or pull requests are created that modify the script.

### What the Workflow Tests

1. **Syntax Validation**: Checks that the PowerShell script has no syntax errors.
2. **TestMode Implementation**: Verifies that the script properly implements a TestMode parameter for CI/CD testing.
3. **Registry Path Validation**: Ensures that the script references the correct Windows registry paths.
4. **Function Call Verification**: Confirms that all defined functions are properly called in the main execution block.
5. **End-to-End Test Run**: Executes the script with the TestMode flag to simulate a complete run without making actual system changes.

### Test Reports

After each workflow run, a test report is generated and saved as an artifact that can be downloaded from the GitHub Actions interface.

## Local Testing

You can test the script locally before pushing to GitHub by running:

```powershell
# Syntax check
powershell -Command "& { [System.Management.Automation.Language.Parser]::ParseFile('setup_rdp_windows.ps1', [ref]$null, [ref]$null) }"

# Test run with TestMode
powershell -ExecutionPolicy Bypass -File setup_rdp_windows.ps1 -TestMode
```

## TestMode Parameter

The TestMode parameter allows the script to run in a simulation mode where:
- No actual system changes are made
- All operations are logged as if they were performed
- Appropriate success messages are displayed
- The script still performs validation checks

This enables safe testing in CI/CD environments without modifying the actual system configuration.

## Adding More Tests

To extend the test coverage:

1. Add new test steps to the workflow YAML file
2. Enhance the PowerShell script's TestMode capabilities
3. Consider adding more validation checks for security best practices
