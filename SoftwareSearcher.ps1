#Variable Declarations
$userexit = $false


#Function declarations
Function Get-Information{
    [string]$script:workstation = Read-Host 'Input Computer name with correct formatting'
    [string]$script:softname = Read-Host 'Input Name of software you are searching for'
}#End Get-Information
Function Search-SoftwareRegistry{

    Param([string]$softname)

    $32bitregistry = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $64bitregistry = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

    Write-Verbose 'Searching 32 bit Registry.'
    $output = Get-ItemProperty $32bitregistry | Select-Object DisplayName, Version | Where-Object DisplayName -Like "*$softname*" | Format-Table -AutoSize
    if ($output -eq $null){
    Write-Verbose 'Software not found in 32 bit registry trying 64 bit.'
        $output = Get-ItemProperty $64bitregistry | Select-Object DisplayName, Version | Where-Object DisplayName -Like "*$softname*" | Format-Table -AutoSize
    }elseif($output -eq $null){
        Write-Output "No software #softname was found in either registry"
    }
    $output
}#End Search-SoftwareRegistry


#Main
While($userexit -ne $true){ 
    
    Get-Information
    if(Test-Connection $workstation -Count 1 -Quiet){
        Invoke-Command -ComputerName $workstation {Search-SoftwareRegistry $softname}
    }Else{
        Write-Output "Failed to connect to $workstation"
    }
    $temp = Read-Host "Would you like another search? `n Y/N"
    if($temp -eq 'n'){
        $userexit = $true
    }elseif($temp -eq 'n'){
        $userexit = $true
    }
}