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
    $strSearchBase = "LDAP://OU=$strSiteOU,OU=$strDistrictOU,DC=$($test.Variables.Details.RegionCode.Trim()),DC=eq,DC=edu,DC=au"
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
    $script:LogFile = "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"
    Add-Content -Path "$LogFile" -Value "$LogEntry"
}#End Write-Log
Function CreateLog{
  if (Test-Path -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"){
    Remove-Item -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"
  }
  $TimeStamp = Get-Date -Format g
  Add-Content -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt" -Value "Started Powershell Script for $env:USERNAME at $TimeStamp"
}#End CreateLog
Function Execute-Papercut{
    If([String]::IsNullOrEmpty($test.Variables.Papercut.Address)){
        Write-Log "No Papercut Server Configured, Skipping."
    }Else{
        Try{
            Invoke-Expression -Command "\\$($test.Variables.Papercut.Address.Trim())\pcclient\win\pc-client-local-cache.exe --silent -- minimized --cache D:\PapercutClientCache"
        }Catch{
            Write-Log "An error occured connecting to \\$($test.Variables.Papercut.Address.Trim())\pcclient\win\pc-client-local-cache.exe"
        }
    }
}#End Execute-Papercut
Function Map-Drives{
    if([string]::IsNullOrEmpty($XmlDocument.Variables.Mappings)){
        Write-Log "Failed to find Drive configuration. `nPlease check $PSScriptRoot\LogonConfiguration.xml to ensure Drive mappings are configured correctly."
    }Else{
        ForEach ($drive in $test.Variables.Mappings.Drive){
            $letter = $drive.Letter
            $path = $drive.Path
            $group = $drive.Group
            if(isMember -GroupName $group -User $env:USERNAME){
                MapDrive -Path $path -Letter $letter
            }
        }
    }
}#End Map-Drives
Function Check-Errors{
        [cmdletbinding()] 
    Param ( 
        [parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
        [string[]]$Computername=$Env:Computername, 
        [parameter()] 
        [Alias('RunAs')]        
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    ) 
    Begin { 
        If ($PSBoundParameters.ContainsKey('Debug')) {
            $DebugPreference = 'Continue'
        }
        $PSBoundParameters.GetEnumerator() | ForEach {
            Write-Debug $_
        }
        $queryhash = @{
            NameSpace = 'root\wmi'
            Class = 'MSStorageDriver_FailurePredictStatus' 
            Filter = "PredictFailure='True'" 
            ErrorAction = 'Stop'
        } 
        $BadDriveHash = @{
            DiskDrive = 'win32_diskdrive' 
            ErrorAction = 'Stop' 
        } 
    } 
    Process { 
        ForEach ($Computer in $Computername) { 
            $queryhash['Computername'] = $Computer 
            $BadDriveHash['Computername'] = $Computer 
            If ($PSBoundParameters['Credential']) { 
                $queryhash['Credential'] = $Credential 
                $BadDriveHash['Credential'] = $Credential 
            }              
            [regex]$regex = "(?<DriveName>\w+\\[A-Za-z0-9_]*)\w+" 
            Try { 
                Write-Verbose "[$($Computer)] Checking for failed drives" 
                $FailingDrives = Get-WMIObject @queryhash
                If ($FailingDrives) {
                    Write-Verbose "Found drives that may fail; gathering more information."
                    $FailingDrives | ForEach { 
                        $drive = $regex.Matches($_.InstanceName) | ForEach {
                            $_.Groups['DriveName'].value
                        } 
                        $BadDrive = Get-WMIObject @BadDriveHash | Where {
                            $_.PNPDeviceID -like "$drive*"
                        } 
                        If ($BadDrive) { 
                            Write-Warning "$($BadDriveHash['Computername']): $($BadDrive.Model) may fail!" 
                            New-Object PSObject -Property @{ 
                                DriveName = $BadDrive.Model 
                                FailureImminent  = $_.PredictFailure 
                                Reason = $_.Reason 
                                MediaType = $BadDrive.MediaType 
                                SerialNumber = $BadDrive.SerialNumber 
                                InterFace = $BadDrive.InterfaceType 
                                Partitions = $BadDrive.Partitions 
                                Size = $BadDrive.Size 
                                Computer = $BadDriveHash['Computername'] 
                            } 
                        } 
                    } 
                }
            } Catch { 
                Write-Warning "$($Error[0])" 
            } 
        } 
    } 
}#End Check-Errors

#Main - Execute code from here.
CreateLog
Load-Config
Map-Drives
Execute-Papercut
Check-Errors
Add-Content -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt" -Value "Powershell Script completed at $TimeStamp"