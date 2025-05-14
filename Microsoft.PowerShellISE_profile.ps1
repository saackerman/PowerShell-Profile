<#
.SYNOPSIS
    Enhanced migration script for PowerShell profiles from Windows PowerShell 5.1 to PowerShell 7 for all users.

.DESCRIPTION
    This function automates the migration of PowerShell profiles from Windows PowerShell 5.1 to PowerShell 7.
    Enhancements include:
    - Dynamic detection of user-specific paths.
    - Improved error handling.
    - Logging for better traceability.
    - Support for specifying migration scope (AllHosts, CurrentHost, or Both).
    - Validation for prerequisites and parameters.

.PARAMETER BackupPath
    Specifies the directory where the backup of the existing profile will be stored.
    Default is "C:\Backup\PowerShellProfiles".

.PARAMETER MigrationScope
    Specifies whether to migrate profiles for "AllHosts", "CurrentHost", or "Both".
    Default is "AllHosts".

.EXAMPLE
    Move-PowerShellProfile -BackupPath "D:\ProfileBackup" -MigrationScope "Both"

    Migrates both "AllHosts" and "CurrentHost" profiles and stores the backup in "D:\ProfileBackup".

.EXAMPLE
    Move-PowerShellProfile

    Uses the default backup path "C:\Backup\PowerShellProfiles" and migrates all profiles.

.NOTES
    Author: Sean Ackerman
    Date:   YYYY-MM-DD
    Version: 2.1
    Requires: PowerShell 5.1 or later
#>

function Move-PowerShellProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupPath = "C:\Backup\PowerShellProfiles",

        [Parameter(Mandatory = $false)]
        [ValidateSet("AllHosts", "CurrentHost", "Both")]
        [string]$MigrationScope = "AllHosts"
    )

    # Dynamic detection of user-specific paths
    $UserProfileDir = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell"
    $OldProfileWinPS_AllHosts = Join-Path -Path $UserProfileDir -ChildPath "profile.ps1"
    $OldProfileWinPS_CurrentHost = Join-Path -Path $UserProfileDir -ChildPath "Microsoft.PowerShell_profile.ps1"

    $NewProfilesPS7_AllHosts = Join-Path -Path $PSHOME -ChildPath "profile.ps1"
    $NewProfilesPS7_CurrentHost = Join-Path -Path $PSHOME -ChildPath "Microsoft.PowerShell_profile.ps1"

    # Check if PowerShell 7 is installed
    if (!(Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Error "PowerShell 7 is not installed or not found in PATH. Please install PowerShell 7."
        return
    }

    # Validate and create the backup folder
    if (!(Test-Path $BackupPath -PathType Container)) {
        try {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            Write-Verbose "Backup folder created at $BackupPath"
        } catch {
            Write-Error "Failed to create backup folder: $_"
            return
        }
    }

    # Backup and migrate profiles based on MigrationScope
    switch ($MigrationScope) {
        "AllHosts" {
            BackupAndMigrateProfile -OldProfile $OldProfileWinPS_AllHosts -NewProfile $NewProfilesPS7_AllHosts -BackupPath $BackupPath
        }
        "CurrentHost" {
            BackupAndMigrateProfile -OldProfile $OldProfileWinPS_CurrentHost -NewProfile $NewProfilesPS7_CurrentHost -BackupPath $BackupPath
        }
        "Both" {
            BackupAndMigrateProfile -OldProfile $OldProfileWinPS_AllHosts -NewProfile $NewProfilesPS7_AllHosts -BackupPath $BackupPath
            BackupAndMigrateProfile -OldProfile $OldProfileWinPS_CurrentHost -NewProfile $NewProfilesPS7_CurrentHost -BackupPath $BackupPath
        }
    }

    # Logging
    $LogFile = Join-Path -Path $BackupPath -ChildPath "MigrationLog.txt"
    try {
        $LogMessage = "[$(Get-Date)] Migration completed for scope: $MigrationScope."
        Write-Output $LogMessage | Out-File -FilePath $LogFile -Append
        Write-Host "Migration details logged to $LogFile" -ForegroundColor Yellow
    } catch {
        Write-Warning "Failed to write migration log: $_"
    }
}

function BackupAndMigrateProfile {
    param (
        [string]$OldProfile,
        [string]$NewProfile,
        [string]$BackupPath
    )

    # Backup existing profile
    if (Test-Path $OldProfile) {
        try {
            Write-Verbose "Backing up profile $OldProfile..."
            $BackupFilePath = Join-Path -Path $BackupPath -ChildPath (Split-Path -Leaf $OldProfile)
            Copy-Item -Path $OldProfile -Destination $BackupFilePath -Force
            Write-Host "Backup of $OldProfile completed successfully!" -ForegroundColor Green
        } catch {
            Write-Error "Failed to backup profile $OldProfile: $_"
            return
        }
    } else {
        Write-Warning "No existing profile found at $OldProfile."
    }

    # Migrate profile to PowerShell 7
    if (Test-Path $OldProfile) {
        try {
            Write-Verbose "Migrating profile $OldProfile to $NewProfile..."
            Copy-Item -Path $OldProfile -Destination $NewProfile -Force
            Write-Host "Migration of $OldProfile to $NewProfile completed successfully!" -ForegroundColor Green
        } catch {
            Write-Error "Failed to migrate profile $OldProfile to $NewProfile: $_"
            return
        }
    } else {
        Write-Warning "No profile at $OldProfile to migrate."
    }
}
