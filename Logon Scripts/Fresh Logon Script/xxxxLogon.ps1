#Function Declarations
Function Load-Config{
    if(Test-Path "$PSScriptRoot\LogonConfiguration.xml"){
        try{
        [xml]$Script:XmlDocument = Get-Content -Path "$PSScriptRoot\LogonConfiguration.xml"
        Write-Log "Successfully loading Site Configuration from $PSScriptRoot\LogonConfiguration.xml"
        }Catch{
            $wshell = New-Object -ComObject Wscript.shell
            $wshell.Popup("An error occured during logon `nPlease contact IT and report the issue.",0,"Done",0x1)
            Write-Log "Warning Failed to load config some functions may fail."
        }
        }Else{
            $wshell = New-Object -ComObject Wscript.shell
            $wshell.Popup("An error occured during logon `nPlease contact IT and report the issue.",0,"Done",0x1)
            Write-Log "Failed to find Configuration file.`nPlease check $PSScriptRoot\LogonConfiguration.xml"
        }
}#End LoadConfig
Function IsMember{
  Param([string]$GroupName, $User = $env:username, [string]$Type = 'User')
    # Function to check if $User is a member of security group $GroupName
    # Uses ADSI because most machines won't have the ActiveDirectory import module
    
    $returnVal = $False
    $strSiteOU = $env:SITEOU
    $strDistrictOU = $env:DISTRICTOU
    $strRegionCode = $env:REGIONCODE
    $strSearchBase = "LDAP://OU=$strSiteOU,OU=$strDistrictOU,DC=$env:REGIONCODE,DC=eq,DC=edu,DC=au"
  # $Type can be used to specify Computer as our object 
    $strFilter = "(&(objectCategory=$Type)(samAccountName=$User))"
 
    $objSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList ($strSearchBase)
    $objSearcher.Filter = $strFilter
 
    $objPath = $objSearcher.FindOne()
    $objUser = $objPath.GetDirectoryEntry()
    $DN = $objUser.distinguishedName
    
    $strGrpFilter = "(&(objectCategory=group)(name=$GroupName))"
    $objGrpSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList ($strSearchBase)
    $objGrpSearcher.Filter = $strGrpFilter
    
    $objGrpPath = $objGrpSearcher.FindOne()
    
    If (!($objGrpPath -eq $Null)){
        $objGrp = $objGrpPath.GetDirectoryEntry()
        
        $grpDN = $objGrp.distinguishedName
        $ADVal = [ADSI]"LDAP://$DN"
        
        if ($ADVal.memberOf.Value -eq $grpDN){
                $returnVal = $True
            } else {
                $returnVal = $False
                Write-Log -LogEntry "$env:USERNAME failed to test for group $GroupName"
            }
    } else {
        $returnVal = $False
        Write-Log -LogEntry "$env:USERNAME failed to test for group $GroupName"
    }
    return $returnVal
}#End IsMember
Function MapDrive{   
  param($Letter,$Path)  
  try{
        Write-Log -LogEntry "$Letter has been mapped."
        $strLetter = $Letter + ':'
        net use $strLetter $Path /PERSISTENT:NO}Catch{
        Write-Log -LogEntry "$Letter failed to map."}
}#End MapDrive
Function Write-Log {
    Param ([string]$LogEntry)
    $script:LogFile = "C:\Logs\PowerShell-LogonLog.txt"
    $timestamp = Get-Date -Format g
    Add-Content -Path "$LogFile" -Value "$timestamp     $LogEntry"
}#End Write-Log
Function CreateLog{
  if (Test-Path -Path "C:\Logs\PowerShell-LogonLog.txt"){
    Remove-Item -Path "C:\Logs\PowerShell-LogonLog.txt"
    Write-Log "Logon for user $env:USERNAME started."
  }Else{
  Write-Log "Logon for user $env:USERNAME started."
  }
}#End CreateLog
Function Execute-Papercut{
    
    If([String]::IsNullOrEmpty($XmlDocument.Variables.Papercut.Address)){
        Write-Log "No Papercut Server Configured, Skipping."
    }Else{
        Invoke-Expression -Command "\\$($XmlDocument.Variables.Papercut.Address.Trim())\pcclient\win\pc-client-local-cache.exe --silent --minimized --cache D:\PaperCutClientCache"
        Write-Log "Successfully Launched Papercut"
    }
}#End Execute-Papercut
Function Map-Drives{
    if([string]::IsNullOrEmpty($XmlDocument.Variables.Mappings)){
        Write-Log "Failed to find Drive configuration. `nPlease check $PSScriptRoot\LogonConfiguration.xml to ensure Drive mappings are configured correctly."
    }Else{
        ForEach ($drive in $XmlDocument.Variables.Mappings.Drive){
            $letter = $drive.Letter.Trim()
            $path = $drive.Path.Trim()
            $group = $drive.Group.Trim()
            if(isMember -GroupName $group -User $env:USERNAME){
                MapDrive -Path $path -Letter $letter
            }
        }
    }
}#End Map-Drives
Function Check-Errors{}#End Check-Errors
#Main - Execute code from here.
CreateLog
Load-Config
Map-Drives
Execute-Papercut
Write-Log "Logon Script completed."