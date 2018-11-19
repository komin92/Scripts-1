#Function Declarations
Function IsMember{ 
  Param([string]$GroupName, $User = $env:username, [string]$Type = 'User')
    # Function to check if $User is a member of security group $GroupName
    # Uses ADSI because most machines won't have the ActiveDirectory import module
    
    $returnVal = $False
    $strSiteOU = $env:SITEOU
    $strDistrictOU = $env:DISTRICTOU
    $strRegionCode = $env:REGIONCODE
    $strSearchBase = "LDAP://OU=$strSiteOU,OU=$strDistrictOU,DC=$strRegionCode,DC=eq,DC=edu,DC=au"
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
                LogItem -LogEntry "$env:USERNAME failed to test for group $GroupName"
            }
    } else {
        $returnVal = $False
    }
    
    return $returnVal
}#End IsMember
Function MapDrive{   
  param($Letter,$Path)  
  try{
        LogItem -LogEntry "$Letter has been mapped."
        $strLetter = $Letter + ':'
        net use $strLetter $Path /PERSISTENT:NO}Catch{
        LogItem -LogEntry "$Letter failed to map."}
}#End MapDrive
Function LogItem {
    Param ([string]$LogEntry)
    $script:LogFile = "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"
    Add-Content -Path "$LogFile" -Value "$LogEntry"
}#End LogItem
Function CreateLog{
  if (Test-Path -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"){
    Remove-Item -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt"
  }
  $TimeStamp = Get-Date -Format g
  Add-Content -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt" -Value "Started Powershell Script for $env:USERNAME at $TimeStamp"
}#End CreateLog
#Main - Execute code from here.
CreateLog

# Execute PaperCut
Invoke-Expression -Command '\\10.113.92.19\pcclient\win\pc-client-local-cache.exe --silent -- minimized --cache D:\PapercutClientCache'

# Map Drives for Everyone.

MapDrive -Letter "T" -Path "\\EQSUN1877002\Apps"
MapDrive -Letter "P" -Path "\\EQSUN1877001\Apps"
MapDrive -Letter "A" -Path "\\EQSUN1877002\CDApps$"

#Map Drives for Students
If(IsMember -GroupName '1877GG_UsrStudent' -User $env:USERNAME){
  MapDrive -Letter "S" -Path "\\EQSUN1877002\Data\Curriculum"
  MapDrive -Letter "M" -Path "\\EQSUN1877001\Menu$\Curriculum"
}

# Map Drives for Staff
If(IsMember -GroupName '1877GG_UsrStaff' -User $env:USERNAME){
  MapDrive -Letter 'Q' -Path '\\EQSUN1877001\Apps' -GroupName
}

#Map Drives for Teachers
If(IsMember -GroupName '1877GG_UsrTeachers' -User $env:USERNAME){
    MapDrive -Letter "T" -Letter "\\EQSUN1877001\Data\Coredata\Curriculum"
    MapDrive -Letter "U" -Letter "\\eqsun1877001\UsrHome$\Curriculum"
}

#Map Drives for Office Staff
if(IsMember -GroupName '1877GG_UsrOffice' -User $env:USERNAME){
  MapDrive -Letter 'O' -Path '\\EQSUN1877001\Data\Coredata\Office'
}

#Map Drives for Roaming Staff
If(IsMember -GroupName '5603GG_RoamingStaff' -User $env:USERNAME){
    MapDrive -Letter "G" -Path "\\equns1877001\Data"
    MapDrive -Letter "T" -Path "\\eqsun1877002\Data\Curriculum"
}

Add-Content -Path "$env:HOMEDRIVE\Logs\PowerShell-LogonLog.txt" -Value "Powershell Script completed at $TimeStamp"