#Recursively searches through a directory and removes empty folders

Write-Host 'Please input Root directory for search'
[string]$tdc = Read-Host
do {
  $dirs = gci $tdc -directory -recurse | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName
  $dirs | Foreach-Object { Remove-Item $_ }
} while ($dirs.count -gt 0)
