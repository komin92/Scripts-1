 #OAMPS csv Generator
 #Written by Mitchell Beare in 2018

 #Setup Variables

  #Determine csv Path
  $csv = "\\eqsun1877001\Data\Coredata\Common\IT\ICT\Generic_School_Purchase_Import.csv"


 #Function Declarations
  Function Get-DellWarrantyInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$False,Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [alias("SerialNumber")]
        [string[]]$GetServiceTag
    )
    Process {
        if ($ServiceTag) {
            if ($ServiceTag.Length -ne 7) {
                Write-Warning "The specified service tag wasn't entered correctly"
                break
            }
        }
    $WebProxy = New-WebServiceProxy -Uri "http://xserv.dell.com/services/AssetService.asmx?WSDL" -UseDefaultCredential
    $WebProxy.Url = "http://xserv.dell.com/services/AssetService.asmx"
    $WarrantyInformation = $WebProxy.GetAssetInformation(([guid]::NewGuid()).Guid, "Dell Warranty", $GetServiceTag)
    $WarrantyInformation | Select-Object -ExpandProperty Entitlements
    return $WarrantyInformation
    }
}
 
if ($ServiceTag) {
    if (($ComputerName) -OR ($ExportCSV) -OR ($ImportFile)) {
        Write-Warning "You can't combine the ServiceTag parameter with other parameters"
    }
    else {
        $WarrantyObject = Get-DellWarrantyInfo -GetServiceTag $ServiceTag | Select-Object @{Label="ServiceTag";Expression={$ServiceTag}},@{label="StartDate";Expression={$_.StartDate.ToString().SubString(0,10)}},@{label="EndDate";Expression={$_.EndDate.ToString().SubString(0,10)}},DaysLeft,EntitlementType
        $WarrantyObject[0,1] #Remove [0,1] to get everything
    }
}
 
if ($ComputerName) {
    if (($ServiceTag) -OR ($ExportCSV) -OR ($ImportFile)) {
        Write-Warning "You can't combine the ComputerName parameter with other parameters"
    }
    else {
        [string]$SerialNumber = (Get-WmiObject -Namespace "root\cimv2" -Class Win32_SystemEnclosure -ComputerName $ComputerName).SerialNumber
        $WarrantyObject = Get-DellWarrantyInfo -GetServiceTag $SerialNumber | Select-Object @{Label="ComputerName";Expression={$ComputerName}},@{label="StartDate";Expression={$_.StartDate.ToString().SubString(0,10)}},@{label="EndDate";Expression={$_.EndDate.ToString().SubString(0,10)}},DaysLeft,EntitlementType
        $WarrantyObject[0,1] #Remove [0,1] to get everything
    }
}
 
if (($ImportFile)) {
    if (($ServiceTag) -OR ($ComputerName)) {
        Write-Warning "You can't combine the ImportFile parameter with ServiceTag or ComputerName"
    }
    else {
        if (!(Test-Path -Path $ImportFile)) {
            Write-Warning "File not found"
            break
        }
        elseif (!$ImportFile.EndsWith(".txt")) {
            Write-Warning "You can only specify a .txt file"
            break
        }
        else {
            if (!$ExportCSV) {
                $GetServiceTagFromFile = Get-Content -Path $ImportFile
                foreach ($ServiceTags in $GetServiceTagFromFile) {
                    $WarrantyObject = Get-DellWarrantyInfo -GetServiceTag $ServiceTags | Select-Object @{Label="ServiceTag";Expression={$ServiceTags}},@{label="StartDate";Expression={$_.StartDate.ToString().SubString(0,10)}},@{label="EndDate";Expression={$_.EndDate.ToString().SubString(0,10)}},DaysLeft,EntitlementType
                    $WarrantyObject[0,1] #Remove [0,1] to get everything
                }
            }
            elseif ($ExportCSV) {
                $GetServiceTagFromFile = Get-Content -Path $ImportFile
                $ExportPath = Read-Host "Enter a path to export the results"
                $ExportFileName = "WarrantyInfo.csv"
                foreach ($ServiceTags in $GetServiceTagFromFile) {
                    $WarrantyObject = Get-DellWarrantyInfo -GetServiceTag $ServiceTags | Select-Object @{Label="ServiceTag";Expression={$ServiceTags}},@{label="StartDate";Expression={$_.StartDate.ToString().SubString(0,10)}},@{label="EndDate";Expression={$_.EndDate.ToString().SubString(0,10)}},DaysLeft,EntitlementType
                    if (!(Test-Path -Path $ExportPath)) {
                        Write-Warning "Path not found"
                        break
                    }
                    else {
                        $FullExportPath = Join-Path -Path $ExportPath -ChildPath $ExportFileName
                        $WarrantyObject[0,1] | Export-Csv -Path $FullExportPath -Delimiter "," -NoTypeInformation -Append #Remove [0,1] to get everything
                    }
                }
            (Get-Content $FullExportPath) | ForEach-Object { $_ -replace '"', "" } | Out-File $FullExportPath
            Write-Output "File successfully exported to $FullExportPath"
            }
        }
    }
}
  #Collect information
  Write-Output "Please fill in comp info, if unkown leave blank `n"

 #Intialise object
  $csvrow = New-Object PSObject

  $csvrow | Add-Member -MemberType NoteProperty -Name "Site Code" -Value (Read-Host -Prompt 'Please Enter Site Code')
  $csvrow | Add-Member -MemberType NoteProperty -Name "Site Name" -value (Read-Host -Prompt 'Please Enter School Long Name')
  try{
    $make = (Get-Ciminstance -Class Win32_ComputerSystem).Manufacturer
  }Catch{
    $make = (Get-Ciminstance -Class Win32_ComputerSystemProduct).Vendor
   }
  $csvrow | Add-Member -MemberType NoteProperty -Name "Make" -value $make
    try{
    $model = (Get-Ciminstance -Class Win32_ComputerSystem).Model
  }Catch{
    $model = (Get-Ciminstance -Class Win32_ComputerSystemProduct).Name
  }
  $csvrow | Add-Member -MemberType NoteProperty -Name "Model Number" -Value $model
  $csvrow | Add-Member -MemberType NoteProperty -Name "UUID (36 Characters)" -Value ((Get-Ciminstance -Class Win32_ComputerSystemProduct).UUID)
  if($make -eq 'Acer'){
    $SNID = (Get-Ciminstance -Class Win32_bios).SerialNumber
  }else{
    $SNID = ' '
  }
  $csvrow | Add-Member -MemberType NoteProperty -Name "SNID" -Value $SNID
  if($make -ne 'Acer'){
  $serial = (Get-Ciminstance -Class Win32_bios).SerialNumber
  }
  $csvrow | Add-Member -MemberType NoteProperty -Name "Serial Number" -Value $serial

  if($make -eq 'Dell'){
    $warrantystart = (Get-DellWarrantyInfo -GetServiceTag $serial).StartDate
    $csvrow | Add-Member -MemberType NoteProperty -Name "Warranty Start Date" -Value $warrantystart
  }Else{
  $warrantystart = Read-Host 'Please Enter Warranty Start Date'
  $csvrow | Add-Member -MemberType NoteProperty -Name "Warranty Start Date" -Value $warrantystart
  }

  if($make -eq 'Dell'){
    $warrantyend = (Get-DellWarrantyInfo -GetServiceTag $serial).EndDate
    $csvrow | Add-Member -MemberType NoteProperty -Name "Warranty End Date" -value $warrantyend
  }Else{
    $warrantyend = Read-Host -Prompt 'Enter Warranty End Date'
    $csvrow | Add-Member -MemberType NoteProperty -Name "Warranty End Date" -value $warrantyend
  }

  $mac = (Get-Ciminstance -Class win32_networkadapter -Filter "adaptertype='Ethernet 802.3'" | Where-Object Description -Like '*Ethernet*').macaddress
  $csvrow | Add-Member -MemberType NoteProperty -Name "Mac Address (12 characters)" -Value $mac

  $wmac = (Get-Ciminstance -Class win32_networkadapter | Where-Object {$_.Description -NotLike '*virtual*' -and $_.Description -NotLike "*Ethernet*"}).macaddress

  $csvrow | Add-Member -MemberType NoteProperty -Name "Funding Type" -value (Read-Host -Prompt 'Please Enter Funding Code')

  $csvrow | Add-Member -MemberType NoteProperty -Name "Acquisition Cost" -value (Read-Host -Prompt 'Please Enter acquisition cost')

  $type = (Get-Ciminstance -Class win32_computersystem).PCSystemType
  if ($type -eq 2){
    $type = 'Laptop'
  }Else{
    $type = 'Desktop'
  }
  $csvrow | Add-Member -MemberType NoteProperty -Name "Device Type" -Value $type

  $user = Read-Host -Prompt 'USer Type, Staff or Student or both'
  if([string]::IsNullOrEmpty($user)){
    $user =  'both'
  }
  $csvrow | Add-Member -MemberType NoteProperty -Name "User Type" -Value $user

  $exist = Read-Host 'Is this an existing machine? Y/N'
  if($exist -eq 'y' -or $exist -eq 'Y'){
    $assetid = Read-Host 'Please Enter Asset Number'
    $csvrow | Add-Member -MemberType NoteProperty -Name "Asset ID" -Value $assetid
  }
  #Export data to CSV file
  $csvrow | Export-Csv -Path $csv -Append -NoTypeInformation

  #Pause and allow user chance to check console. 
  Pause
