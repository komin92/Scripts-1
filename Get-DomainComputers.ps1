Function Get-DomainComputer {
    [CmdletBinding()]
    PARAM(
        [Parameter(ValueFromPipelineByPropertyName=$true,
					ValueFromPipeline=$true)]
		[Alias("Computer")]
        [String[]]$ComputerName,
        
		[Alias("ResultLimit","Limit")]
		[int]$SizeLimit='100',
		
		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[Alias("Domain")]
        [String]$DomainDN="LDAP://OU=$siteou,OU=$districtou,DC=$regionou,DC=eq,DC=edu,DC=au",
	
		[Alias("RunAs")]
		[System.Management.Automation.Credential()]
		$Credential = [System.Management.Automation.PSCredential]::Empty

	)#PARAM
    PROCESS{
		IF ($ComputerName){
			Write-Verbose -Message "One or more ComputerName specified"
            FOREACH ($item in $ComputerName){
				TRY{
					# Building the basic search object with some parameters
                    Write-Verbose -Message "COMPUTERNAME: $item"
					$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcher
					$Searcher.Filter = "(&(objectCategory=Computer)(name=$item))"
                    $Searcher.SizeLimit = $SizeLimit
					$Searcher.SearchRoot = $DomainDN
				
				    # Specify a different domain to query
                    IF ($PSBoundParameters['DomainDN']){
                        IF ($DomainDN -notlike "LDAP://*") {$DomainDN = "LDAP://$DomainDN"}#IF
                        Write-Verbose -Message "Different Domain specified: $DomainDN"
					    $Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])
				
				    # Alternate Credentials
				    IF ($PSBoundParameters['Credential']) {
					    Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					    $Domain = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN,$($Credential.UserName),$($Credential.GetNetworkCredential().password) -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCred
					    $Searcher.SearchRoot = $Domain}#IF ($PSBoundParameters['Credential'])

					# Querying the Active Directory
					Write-Verbose -Message "Starting the ADSI Search..."
	                FOREACH ($Computer in $($Searcher.FindAll())){
                        Write-Verbose -Message "$($Computer.properties.name)"
	                    New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutput -Property @{
	                        "Name" = $($Computer.properties.name)
	                        "DNShostName"    = $($Computer.properties.dnshostname)
	                        "Description" = $($Computer.properties.description)
                            "OperatingSystem"=$($Computer.Properties.operatingsystem)
                            "WhenCreated" = $($Computer.properties.whencreated)
                            "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
	                }#FOREACH $Computer

					Write-Verbose -Message "ADSI Search completed"
	            }#TRY
				CATCH{ 
					Write-Warning -Message ('{0}: {1}' -f $item, $_.Exception.Message)
					IF ($ErrProcessNewObjectSearcher){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
					IF ($ErrProcessNewObjectCred){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}
					IF ($ErrProcessNewObjectOutput){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
				}#CATCH
            }#FOREACH $item
			

		}#IF $ComputerName
		
		ELSE {
			Write-Verbose -Message "No ComputerName specified"
            TRY{
				# Building the basic search object with some parameters
                Write-Verbose -Message "List All object"
				$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectSearcherALL
				$Searcher.Filter = "(objectCategory=Computer)"
                $Searcher.SizeLimit = $SizeLimit
				
				# Specify a different domain to query
                IF ($PSBoundParameters['DomainDN']){
                    $DomainDN = "LDAP://$DomainDN"
                    Write-Verbose -Message "Different Domain specified: $DomainDN"
					$Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['DomainDN'])
				
				# Alternate Credentials
				IF ($PSBoundParameters['Credential']) {
					Write-Verbose -Message "Different Credential specified: $($Credential.UserName)"
					$DomainDN = New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $DomainDN, $Credential.UserName,$Credential.GetNetworkCredential().password -ErrorAction 'Stop' -ErrorVariable ErrProcessNewObjectCredALL
					$Searcher.SearchRoot = $DomainDN}#IF ($PSBoundParameters['Credential'])
				
				# Querying the Active Directory
                Write-Verbose -Message "Starting the ADSI Search..."
	            FOREACH ($Computer in $($Searcher.FindAll())){
					TRY{
	                    Write-Verbose -Message "$($Computer.properties.name)"
	                    New-Object -TypeName PSObject -ErrorAction 'Continue' -ErrorVariable ErrProcessNewObjectOutputALL -Property @{
	                        "Name" = $($Computer.properties.name)
	                        "DNShostName"    = $($Computer.properties.dnshostname)
	                        "Description" = $($Computer.properties.description)
	                        "OperatingSystem"=$($Computer.Properties.operatingsystem)
	                        "WhenCreated" = $($Computer.properties.whencreated)
	                        "DistinguishedName" = $($Computer.properties.distinguishedname)}#New-Object
					}#TRY
					CATCH{
						Write-Warning -Message ('{0}: {1}' -f $Computer, $_.Exception.Message)
						IF ($ErrProcessNewObjectOutputALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the output object"}
					}
                }#FOREACH $Computer

				Write-Verbose -Message "ADSI Search completed"
				
            }#TRY
			
            CATCH{
				Write-Warning -Message "Something Wrong happened"
				IF ($ErrProcessNewObjectSearcherALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the searcher object"}
				IF ($ErrProcessNewObjectCredALL){Write-Warning -Message "PROCESS BLOCK - Error during the creation of the alternate credential object"}
				
            }#CATCH
		}#ELSE
    }#PROCESS
    END{Write-Verbose -Message "Script Completed"}
}#function

$Myinfo = Get-Content "$env:LOGONSERVER\EQLOGON\ServerID.txt"
$Myinfo = $Myinfo.Split(':').Trim()
Write-Host 'Welcome to Domain Computer Search'
$siteou ="$($Myinfo[9])_$($Myinfo[11])"
$districtou = "$($Myinfo[5])_$($Myinfo[7])"
$regionou = $Myinfo[3]
Write-Host 'Please provide computer name as a search term. '
Write-Host 'Partial names may be provided with a wild card e.g WS9339*'
$input = Read-Host 'Please input computer name'
Get-DomainComputer -ComputerName $input
Pause

#Get-Domaincomputer
#Get-Domaincomputer -ComputerName "LAB1*" -SizeLimit 5
#Get-Domaincomputer -Verbose -DomainDN 'DC=FX,DC=LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\Administrator")
#Get-Domaincomputer -Verbose -DomainDN 'FX.LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\FXtest")
#Get-Domaincomputer -DomainDN 'FX.LAB' -ComputerName LAB1* -Credential (Get-Credential -Credential "FX.LAB\Administrator")
#Get-Domaincomputer -DomainDN 'FX.LAB' -ComputerName LAB1*
#Get-Domaincomputer -DomainDN 'LDAP://FX.LAB' -ComputerName LAB1*
#Get-Domaincomputer -DomainDN 'LDAP://DC=FX,DC=LAB' -ComputerName LAB1*
