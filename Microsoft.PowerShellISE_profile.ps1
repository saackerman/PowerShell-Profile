$Shell = $Host.UI.RawUI

$Shell.WindowTitle ="$env:USERDNSDOMAIN $env:USERPROFILE"

<#$Shell.WindowSize.width=70

#$Shell.$size.height=25

$Shell.WindowSize = $size

$size = $Shell.BufferSize

$size.width=70

$size.height=5000

$Shell.BufferSize = $size

#>

<#

$psise.Options.ScriptPaneBackgroundColor = "#797979"

$psise.Options.ScriptPaneBackgroundColor = "#a9a9a9"

$psise.Options.ScriptPaneBackgroundColor = "#232323"

#>

$DefaultScriptpath = "c:\scripts"

    if(!($DefaultScriptpath)){

    New-Item -ItemType Directory -Path $DefaultScriptpath}

    Set-Location -Path $DefaultScriptpath

 

 

function global:prompt {

    $Success = $?

      

 

    

    Write-Host -Object "$($env:COMPUTERNAME)" -NoNewline -ForegroundColor Yellow

    ## Time calculation

    $LastExecutionTimeSpan = if (@(Get-History).Count -gt 0) {

        Get-History | Select-Object -Last 1 | ForEach-Object {

            New-TimeSpan -Start $_.StartExecutionTime -End $_.EndExecutionTime

        }#endif

    }

    else {

        New-TimeSpan

    }

    $LastExecutionShortTime = if ($LastExecutionTimeSpan.Days -gt 0) {

        "$($LastExecutionTimeSpan.Days + [Math]::Round($LastExecutionTimeSpan.Hours / 24, 2)) d"

    }#endif

    elseif ($LastExecutionTimeSpan.Hours -gt 0) {

        "$($LastExecutionTimeSpan.Hours + [Math]::Round($LastExecutionTimeSpan.Minutes / 60, 2)) h"

    }#endif

    elseif ($LastExecutionTimeSpan.Minutes -gt 0) {

        "$($LastExecutionTimeSpan.Minutes + [Math]::Round($LastExecutionTimeSpan.Seconds / 60, 2)) m"

    }#endif

    elseif ($LastExecutionTimeSpan.Seconds -gt 0) {

        "$($LastExecutionTimeSpan.Seconds + [Math]::Round($LastExecutionTimeSpan.Milliseconds / 1000, 2)) s"

    }#endif

    elseif ($LastExecutionTimeSpan.Milliseconds -gt 0) {

        "$([Math]::Round($LastExecutionTimeSpan.TotalMilliseconds, 2)) ms"

    }#endif

    else {

        "0 s"

    }#endif

    if ($Success) {

        Write-Host -Object "[$LastExecutionShortTime] " -NoNewline -ForegroundColor Green

    }

    else {

        Write-Host -Object "! [$LastExecutionShortTime] " -NoNewline -ForegroundColor Red

    }

    <#

    ## History ID

    $HistoryId = $MyInvocation.HistoryId

    # Uncomment below for leading zeros

    # $HistoryId = '{0:d4}' -f $MyInvocation.HistoryId

    Write-Host -Object "$HistoryId`: " -NoNewline -ForegroundColor Cyan

    #>

 

    ## User

    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    #Write-Host -Object "$($env:USERNAME) ($(if ($IsAdmin){ 'A' } else { 'U' })) " -NoNewline -ForegroundColor DarkRed

    if ($IsAdmin){

       

        Write-Host -Object "$($env:USERNAME)" -NoNewline -ForegroundColor Yellow -BackgroundColor Red

    }

    else {

      

       Write-Host -Object "$($env:USERNAME)" -NoNewline -ForegroundColor Blue -BackgroundColor Green

    }

 

    ## Path

    $Drive = $pwd.Drive.Name

    $Pwds = $pwd -split "\\" | Where-Object { -Not [String]::IsNullOrEmpty($_) }

    $PwdPath = if ($Pwds.Count -gt 3) {

        $ParentFolder = Split-Path -Path (Split-Path -Path $pwd -Parent) -Leaf

        $CurrentFolder = Split-Path -Path $pwd -Leaf

        "..\$ParentFolder\$CurrentFolder"

    }

    elseif ($Pwds.Count -eq 3) {

        $ParentFolder = Split-Path -Path (Split-Path -Path $pwd -Parent) -Leaf

        $CurrentFolder = Split-Path -Path $pwd -Leaf

        "$ParentFolder\$CurrentFolder"

    }

    elseif ($Pwds.Count -eq 2) {

        Split-Path -Path $pwd -Leaf

    }

    else { "" }

    Write-Host -Object "$Drive`:\$PwdPath" -NoNewline -ForegroundColor Magenta

    return "> "

}

Clear-host 