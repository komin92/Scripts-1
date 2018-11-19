#This script adds AD users into a group based on their current group membership.

$Creds = Get-Credentials
If (Test-Connection -ComputerName $RemoteComputers -Quiet){
     Invoke-Command -Credential $creds -ComputerName "$env:dc" -ScriptBlock {

$ErrorActionPreference = 'Inquire'
#Intialise Variables
$Finished = $False
[String]$SearchBase = "OU=$($env:SiteCode)_$($env:SiteName),OU=$($env:DistrictCode)_$($env:DistrictName),DC=$env:RegionName,DC=eq,DC=edu,DC=au"
[String]$ADFilter = "*$env:SiteCode*"
[String]$AddGroup = ""
[String]$TestGroup = ""

#Search AD to populate Grouplist
Write-Output "Searching Active Directory and getting all Groups for $env:SiteName `nThis may take a little while."
$GroupList = Get-ADGroup -SearchBase $SearchBase -Filter {Name -like $ADFilter } |`
                                                                  Select-Object Name
    #Prompt User for Serch Group.
    $TestGroup = $GroupList | Out-GridView -Title 'Selection Group' -PassThru
    $TestGroup = $TestGroup -replace ('.*\r|.*=|\}'), $null

    #Prompt User for Groups they are adding.
    $AddGroup = $GroupList | Out-GridView -Title 'Group to be added' -PassThru
    $AddGroup = $AddGroup -replace ('.*\r|.*=|\}'), $null

    $Users = Get-ADGroupMember $TestGroup | Select-Object name
    $i=0
    $Process = New-Object object[] $Users.Length
    ForEach ($User in $Users) {
        $Process[$i] = $Users[$i] | Out-String
        $i = $i + 1
    }
    $Process = $Process -replace '.*\n.*\n.*\(|\)|\n|\r|\s', $null
    $i = 0
    Foreach ($User in $Process) {
        if($Process[$i] -match '.1877' -and $AddGroup -match '.*WksLocalAdmin'){
            Write-Warning "$Process[$i] is a genric account and is not permitted LocalAdmin Group."
        }Else{
            if(Get-ADGroupMember -Identity $AddGroup | Where-Object Name -like "*$($Process[$i])*"){
                Write-Output "$($Process[$i]) Is Already a member of $AddGroup, Skipping."
                $i = $i + 1
            }Else{
                Try{
                Add-ADGroupMember -Identity $AddGroup -Members $($Process[$i])
                }Catch{
                    Write-Warning "Failed to Add $($Process[$i]) to $AddGroup"
                }
                $i = $i + 1
            }
        }
    }
    Pause
          }
}