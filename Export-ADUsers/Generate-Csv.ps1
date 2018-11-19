Import-Module -Path "$PSScriptRoot\Export-ADUsers.psm1"

Export-ADUsers -SearchLoc 'OU=9339_Users,OU=9339_Griffin SS,DC=sun,DC=eq,DC=edu,DC=au' -CSVReportPath "$PSScriptRoot" -ADServer 'eqsun1877001'