$homedir = Read-Host "PLease enter fully qualified pathname to folder."
$acl = Get-Acl $homedir
if ($acl.AreAccessRulesProtected) { $acl.Access | % {$acl.purgeaccessrules($_.IdentityReference)} }
else {
		$isProtected = $true 
		$preserveInheritance = $false
		$acl.SetAccessRuleProtection($isProtected, $preserveInheritance) 
	 }

$account= Read-Host "Please enter domain qualified Username to grant control."
$rights=[System.Security.AccessControl.FileSystemRights]::FullControl
$inheritance=[System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$propagation=[System.Security.AccessControl.PropagationFlags]::None
$allowdeny=[System.Security.AccessControl.AccessControlType]::Allow

$dirACE=New-Object System.Security.AccessControl.FileSystemAccessRule ($account,$rights,$inheritance,$propagation,$allowdeny)
$ACL.AddAccessRule($dirACE)

Set-Acl -aclobject $ACL -Path $homedir
Write-Host $homedir Permissions added