# File Hash Calculator and Comparator

A PowerShell script to calculate and optionally compare file hashes for all files in specified directories and subdirectories. This script supports multiple hashing algorithms and provides verbose output for detailed execution information.

## Features

- Calculate file hashes (default: `SHA256`) for all files in a directory and its subdirectories.
- Compare file hashes between two directories to identify differences.
- Supports multiple hashing algorithms: `SHA1`, `SHA256`, `SHA384`, `SHA512`, and `MD5`.
- Verbose output for detailed processing information.
- Outputs missing files, hash mismatches, and matching files during comparison.

## Requirements

- **PowerShell v3.0 or later** (for the `Get-FileHash` cmdlet).

## Parameters

| Parameter           | Description                                                                                     | Default   |
|---------------------|-------------------------------------------------------------------------------------------------|-----------|
| `-Directory`        | The path to the directory containing the files to be hashed.                                    | Mandatory |
| `-Algorithm`        | The hashing algorithm to use (`SHA1`, `SHA256`, `SHA384`, `SHA512`, `MD5`).                     | `SHA256`  |
| `-CompareDirectory` | The path to a second directory to compare file hashes against.                                  | Optional  |

## Usage

### Calculate File Hashes

To calculate file hashes for all files in a directory:

```powershell
.\Get-FileHashes.ps1 -Directory "C:\MyFiles" -Verbose
```

### Specify a Hashing Algorithm

To use a different hashing algorithm (e.g., MD5):

```powershell
.\Get-FileHashes.ps1 -Directory "C:\MyFiles" -Algorithm MD5 -Verbose
```

### Compare File Hashes Between Two Directories

To compare file hashes between two directories:

```powershell
.\Get-FileHashes.ps1 -Directory "C:\Source" -CompareDirectory "C:\Backup" -Verbose
```

## Output

### Hashes for a Single Directory

- Lists all files and their calculated hashes.

### Comparison Between Two Directories

- Identifies files missing in either directory.
- Highlights files with hash mismatches.
- Lists files with matching hashes.

## Notes

- Ensure the directories specified exist and contain files to process.
- The script will output errors for files it cannot process (e.g., due to permissions).

## License

This script is provided "as-is" without warranty of any kind. Feel free to modify and use it as needed.
