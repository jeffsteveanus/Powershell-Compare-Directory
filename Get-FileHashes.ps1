<#
.SYNOPSIS
    Calculates and optionally compares file hashes for all files in specified directories and subdirectories with verbose output.

.DESCRIPTION
    This script calculates the hash (default: SHA256) for every file within a given directory and its subdirectories.
    It can also compare the file hashes between two different directories to identify differences.
    Includes verbose output to provide more detailed information during execution.

.PARAMETER Directory
    The path to the directory containing the files to be hashed.

.PARAMETER Algorithm
    The hashing algorithm to use (e.g., SHA1, SHA256, MD5). Defaults to SHA256.

.PARAMETER CompareDirectory
    The path to a second directory to compare file hashes against.

.EXAMPLE
    .\Get-FileHashes.ps1 -Directory "C:\MyFiles" -Verbose

.EXAMPLE
    .\Get-FileHashes.ps1 -Directory "C:\MyFiles" -Algorithm MD5 -Verbose

.EXAMPLE
    .\Get-FileHashes.ps1 -Directory "C:\Source" -CompareDirectory "C:\Backup" -Verbose

.NOTES
    Requires PowerShell v3.0 or later for Get-FileHash cmdlet.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Directory,

    [Parameter(Position=1)]
    [ValidateSet("SHA1", "SHA256", "SHA384", "SHA512", "MD5")]
    [string]$Algorithm = "SHA256",

    [Parameter(Position=2)]
    [string]$CompareDirectory
)

# Function to calculate file hash
function Get-FileHashValue {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [string]$HashAlgorithm
    )
    Write-Verbose "Calculating $($HashAlgorithm) hash for '$FilePath'..."
    try {
        $hashObject = Get-FileHash -Path $FilePath -Algorithm $HashAlgorithm
        Write-Verbose "  Hash: $($hashObject.Hash)"
        return $hashObject.Hash
    }
    catch {
        Write-Error "Error calculating hash for '$FilePath': $($_.Exception.Message)"
        return $null
    }
}

# Process the main directory
Write-Host "Calculating $($Algorithm) hashes for files in '$Directory' and its subdirectories..."
Write-Verbose "Starting processing of directory: '$Directory'"
$FileHashes = @{}
Get-ChildItem -Path $Directory -Recurse -File | ForEach-Object {
    Write-Verbose "Found file: '$($_.FullName)'"
    $HashValue = Get-FileHashValue -FilePath $_.FullName -HashAlgorithm $Algorithm
    if ($HashValue) {
        $RelativePath = $_.FullName.Substring($Directory.Length).TrimStart('\')
        $FileHashes[$RelativePath] = $HashValue
        Write-Verbose "  Relative path: '$RelativePath', Hash: '$HashValue'"
    }
}

# Output the hashes for the first directory
Write-Host "`nHashes for '$Directory':"
foreach ($RelativePath in $FileHashes.Keys | Sort-Object) {
    Write-Host "$RelativePath : $($FileHashes[$RelativePath])"
}

# Compare with a second directory if provided
if ($CompareDirectory) {
    if (-not (Test-Path -Path $CompareDirectory -PathType Container)) {
        Write-Error "The compare directory '$CompareDirectory' does not exist."
        exit 1
    }

    Write-Host "`nCalculating $($Algorithm) hashes for files in '$CompareDirectory' and its subdirectories for comparison..."
    Write-Verbose "Starting processing of compare directory: '$CompareDirectory'"
    $CompareFileHashes = @{}
    Get-ChildItem -Path $CompareDirectory -Recurse -File | ForEach-Object {
        Write-Verbose "Found file in compare directory: '$($_.FullName)'"
        $HashValue = Get-FileHashValue -FilePath $_.FullName -HashAlgorithm $Algorithm
        if ($HashValue) {
            $RelativePath = $_.FullName.Substring($CompareDirectory.Length).TrimStart('\')
            $CompareFileHashes[$RelativePath] = $HashValue
            Write-Verbose "  Relative path: '$RelativePath', Hash: '$HashValue'"
        }
    }

    Write-Host "`nComparison between '$Directory' and '$CompareDirectory':"

    # Find files present in the first directory but not the second or with different hashes
    Write-Host "`nFiles present in '$Directory':"
    foreach ($RelativePath in $FileHashes.Keys | Sort-Object) {
        Write-Verbose "Checking file '$RelativePath' from '$Directory'..."
        if (-not $CompareFileHashes.ContainsKey($RelativePath)) {
            Write-Host "  [Missing in '$CompareDirectory'] '$RelativePath'"
            Write-Verbose "    '$RelativePath' not found in '$CompareDirectory'."
        } elseif ($FileHashes[$RelativePath] -ne $CompareFileHashes[$RelativePath]) {
            Write-Host "  [Hash Mismatch] '$RelativePath' - '$($FileHashes[$RelativePath])' vs '$($CompareFileHashes[$RelativePath])'"
            Write-Verbose "    Hash mismatch for '$RelativePath': '$($FileHashes[$RelativePath])' (in '$Directory') vs '$($CompareFileHashes[$RelativePath])' (in '$CompareDirectory')."
        } else {
            Write-Host "  [Match] '$RelativePath' - '$($FileHashes[$RelativePath])'"
            Write-Verbose "    Hashes match for '$RelativePath': '$($FileHashes[$RelativePath])'."
        }
    }

    # Find files present in the second directory but not the first
    Write-Host "`nFiles present only in '$CompareDirectory':"
    foreach ($RelativePath in $CompareFileHashes.Keys | Sort-Object) {
        Write-Verbose "Checking file '$RelativePath' from '$CompareDirectory'..."
        if (-not $FileHashes.ContainsKey($RelativePath)) {
            Write-Host "  '$RelativePath'"
            Write-Verbose "    '$RelativePath' not found in '$Directory'."
        }
    }
}