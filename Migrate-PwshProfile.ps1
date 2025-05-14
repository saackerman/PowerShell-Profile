<#
.SYNOPSIS
    Migrates PowerShell profiles from Windows PowerShell 5.1 to PowerShell 7 for all users.

.DESCRIPTION
    This function automates the migration of PowerShell profiles from Windows PowerShell 5.1 to PowerShell 7.
    It performs the following steps:
    - Checks if PowerShell 7 is installed.
    - Creates a backup of the existing profile.
    - Copies the profile to the new PowerShell 7 location.
    - Verifies the migration.

.PARAMETER BackupPath
    Specifies the directory where the backup of the existing profile will be stored.
    Default is "C:\Backup\PowerShellProfiles".

.EXAMPLE
    Move-PowerShellProfile -BackupPath "D:\ProfileBackup"

    Migrates the PowerShell profile and stores the backup in "D:\ProfileBackup".

.EXAMPLE
    Move-PowerShellProfile

    Uses the default backup path "C:\Backup\PowerShellProfiles".

.NOTES
    Author: Sean Ackerman
    Date:   YYYY-MM-DD
    Version: 1.0
    Requires: PowerShell 5.1 or later
#>

function Move-PowerShellProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupPath = "C:\Backup\PowerShellProfiles"
    )

    # Define profile locations
    <#
    AllUsersAllHosts       : C:\Program Files\PowerShell\7\profile.ps1
    AllUsersCurrentHost    : C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1
    CurrentUserAllHosts    : C:\Users\username\Documents\PowerShell\profile.ps1
    CurrentUserCurrentHost : C:\Users\username\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    #>
    $OldProfileWinPS = "C:\Program Files\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $NewProfilePS7 = "C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1"," C:\Program Files\PowerShell\7\profile.ps1"

    # Check if PowerShell 7 is installed
    if (!(Test-Path "C:\Program Files\PowerShell\7")) {
        Write-Error "PowerShell 7 is not installed. Please install it before running this function."
        return
    }

    # Create backup folder if it doesn't exist
    if (!(Test-Path $BackupPath)) {
        try {
            New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
            Write-Verbose "Backup folder created at $BackupPath"
        } catch {
            Write-Error "Failed to create backup folder: $_"
            return
        }
    }

    # Backup existing profile
    if (Test-Path $OldProfileWinPS) {
        try {
            Write-Verbose "Backing up existing profile..."
            Copy-Item -Path $OldProfileWinPS -Destination "$BackupPath\Microsoft.PowerShell_profile.ps1" -Force
            Write-Host "Backup completed successfully!" -ForegroundColor Green
        } catch {
            Write-Error "Failed to backup profile: $_"
            return
        }
    } else {
        Write-Warning "No existing profile found in Windows PowerShell."
    }

    # Migrate profile to PowerShell 7
    foreach ($newProfile in  $NewProfilePS7){
    if (Test-Path $OldProfileWinPS) {
        try {
            Write-Verbose "Migrating profile to PowerShell 7..."
            Copy-Item -Path $OldProfileWinPS -Destination $NewProfilePS7 -Force
            Write-Host "Migration completed successfully!" -ForegroundColor Green
        } catch {
            Write-Error "Failed to migrate profile: $_"
            return
        }
    } else {
        Write-Warning "No profile found to migrate."
        }
    }

    # Verify migration
     foreach ($newProfile in  $NewProfilePS7){
    if (Test-Path $NewProfilePS7) {
        Write-Host "Profile successfully migrated to PowerShell 7." -ForegroundColor Green
    } else {
        Write-Error "Migration failed. Please check permissions and paths."
    }
    }
}
