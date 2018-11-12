<#
	.SYNOPSIS
		Windows Machine Inventory Using PowerShell.

	.DESCRIPTION
		This script is to document the Windows machine. This script will work only for Local Machine or remote if powershell remoting is enabled. Tested on server 2012 and higher.

	.EXAMPLE
		if your rdping to server then running...(use dont..) or in ps interactive session,  .\System_Inventory.PS1
        Prefered method, icm -ComputerName computername -FilePath .\get-inventoryV3.ps1

	.OUTPUTS
		HTML File OutPut ReportDate , General Information , BIOS Information etc.
#Set-ExecutionPolicy RemoteSigned -ErrorAction SilentlyContinue
    .
.todo
update to CIM instances instead of WMI
make module
code sign
#>
#smtp server change to your server, to, and from address. I like email to a sharepoint email enabled doc lib.
$smtp = "smtp.addy.com"
$to = "youneedoknow@derp.com"
$from = "server@info.com"

New-Item -ItemType directory -Path c:\inventory -ErrorAction SilentlyContinue
$inventory = Get-Item -Path C:\inventory
$UserName = (Get-Item  env:\username).Value 
$ComputerName = (Get-Item env:\Computername).Value
$filepath = (Get-ChildItem env:\userprofile).value

#css 
$a = "<style>"
$a = $a + "BODY{font-size:11pt;background-color:lightgrey;}"
$a = $a + "TH{background-color:black;color:white}"
$a = $a + "TD{background-color:#19aff0;color:black;}"
$a = $a + "</style>"

#ReportDate
$ReportDate = Get-Date | Select -Property DateTime
$date = $ReportDate.DateTime

#General Information
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem | Select Model , Manufacturer , Description , PrimaryOwnerName , SystemType | ConvertTo-Html -Fragment
$baseboard = Get-WmiObject Win32_BaseBoard  |  Select Name,Manufacturer,Product,SerialNumber | ConvertTo-Html -Fragment

#Boot Configuration
$BootConfiguration = Get-WmiObject -Class Win32_BootConfiguration |Select Name , ConfigurationPath   | ConvertTo-Html -Fragment

#BIOS Information
$BIOS = Get-WmiObject -Class Win32_BIOS | Select Manufacturer, SerialNumber , Version  | ConvertTo-Html -Fragment

#Operating System Information
$OS = Get-WmiObject -Class Win32_OperatingSystem | Select Caption , OSArchitecture , OSLanguage  | ConvertTo-Html -Fragment
#$OS = Get-CimInstance -ClassName win32_operatingsystem | select Caption , OSArchitecture , OSLanguage, LastBootUpTime, InstallDate  

#Time Zone Information
$TimeZone = Get-WmiObject -Class Win32_TimeZone | Select Caption , StandardName | ConvertTo-Html -Fragment

#Logical Disk Information
$Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter DriveType=3 | Select DeviceID , @{Name=”size(GB)”;Expression={“{0:N1}” -f($_.size/1gb)}}, @{Name=”freespace(GB)”;Expression={“{0:N1}” -f($_.freespace/1gb)}} | ConvertTo-Html -Fragment

#CPU Information
$SystemProcessor = Get-WmiObject -Class Win32_Processor  | Select SystemName , Name , deviceid, numberofcores, MaxClockSpeed , Manufacturer , status | ConvertTo-Html -Fragment

#Memory Information
#$PhysicalMemory = Get-WmiObject -Class Win32_Computersystem | Select -Property Tag , SerialNumber , PartNumber , Manufacturer , DeviceLocator , @{Name="Capacity(GB)";Expression={"{0:N1}" -f ($_.Capacity/1GB)}}  
$PhysicalMemory = Get-WmiObject -Class Win32_Computersystem | Select Tag, @{Name='Capacity(GB)';Expression={"{0:N0}" -f ($_.TotalPhysicalMemory/1GB)}} | ConvertTo-Html -Fragment

#Nic Information
$ipinfo=Get-WmiObject Win32_NetworkAdapterConfiguration | Select @{Name='IpAddress';Expression={$_.IpAddress -join '; '}},MACAddress,@{Name='IPSubnet';Expression={$_.IPSubnet -join '; '}},@{Name='DefaultIPGateway';Expression={$_.DefaultIPGateway -join ';'}},Caption | Where-Object {$_.IPaddress -notlike ""} | ConvertTo-Html -Fragment

#Volume
$volume = Get-WmiObject Win32_Volume -Filter "DriveType='3'" | ForEach {
    New-Object PSObject -Property @{
        Name = $_.Name
        Label = $_.Label
        FreeSpace_GB = ([Math]::Round($_.FreeSpace /1GB,2))
        TotalSize_GB = ([Math]::Round($_.Capacity /1GB,2))
    }
} | ConvertTo-Html -Fragment

#$Software = Get-WmiObject -Class Win32_Product | Select Name , Vendor , Version , Caption   
<#
Removed items belows Add them back s needed

<font color = blue><H4><B>BIOS Information</B></H4></font>$BIOS
<font color = blue><H4><B>Report Executed On </B></H4></font>$ReportDate
<font color = blue><H4><B>Disk Information</B></H4></font>$Disk #depreciated using win32_volume to get mount points.
#>

#<#
$emailbody=ConvertTo-Html -head $a -Body "<font color = blue><H4><B>Inventory Report for $ComputerName on $ReportDate by $UserName</B></H4></font>
<font color = blue><H4><B>General Information</B></H4></font>$ComputerSystem
<font color = blue><H4><B>General Information</B></H4></font>$baseboard
<font color = blue><H4><B>Operating System Information</B></H4></font>$OS
<font color = blue><H4><B>Processor Information</B></H4></font>$SystemProcessor
<font color = blue><H4><B>Memory Information</B></H4></font>$PhysicalMemory
<font color = blue><H4><B>Volumes</B></H4></font>$volume  
<font color = blue><H4><B>Network Information</B></H4></font>$ipinfo
<font color = blue><H4><B>Time Zone Information</B></H4></font>$TimeZone" #| Out-File $FilePath\$ComputerName.html
#>#

#<font color = blue><H4><B>Software Inventory</B></H4></font>$Software" -CssUri  "$filepath\style.CSS" -Title "Server Inventory" | Out-File "$FilePath\$ComputerName.html"

##############raw text if required NOT Complete#############
<#
$emailBody += "Person who ran: $UserName on device : $ComputerName report save local at $filepath `n"
$emailBody += " Report ran on: $Date `n" 
$emailBody += " Device information: $ComputerSystem.model , $com and $baseboard `n" 
$emailBody += " Boot Configuration: $BootConfiguration `n" 
$emailBody += " Bios: $BIOS `n" 
$emailBody += " Operating System : $OS `n" 
$emailBody += " CPU: $SystemProcessor  `n"
$emailBody += " RAM: $PhysicalMemory  `n" 
$emailBody += " Volume(s): $volume `n" 
$emailBody += " NIC : $ipinfo  `n" 
$emailBody += " TimeZone : $TimeZone `n"  
#>



#Send-MailMessage -To $to -From $from -Subject "$ComputerName" -Attachments "$FilePath\$ComputerName.html" -SmtpServer $smtp
Send-MailMessage -To $to -From $from -Subject "$ComputerName Inventory Report" -BodyAsHtml $emailbody -SmtpServer $smtp
#Invoke-Item -Path "$FilePath\$ComputerName.html"
#Move-Item -Path "$FilePath\$ComputerName.html" -Destination "$inventory"