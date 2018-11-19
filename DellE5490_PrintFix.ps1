#Written by mbear0
<#
    The purpose of this script is to automate the process of repairing printers on Dell E5490 when the
    0x00000e3b error occurs.

#>
Stop-Service Spooler
$drivers = Get-PrinterDriver
ForEach ($driver in $drivers){
    Remove-PrinterDriver -Name $driver.name
}

Remove-ItemProperty -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows NT x86\Drivers\Version-3"
Remove-ItemProperty -Path "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows x64\Drivers\Version-3"
Start-Service Spooler