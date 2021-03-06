$source = Read-Host -Prompt 'What is your starting directory?'
$archivepath = "Z:\TEMP"
$archivedestination = Read-Host 'Where is the archive being saved?'
$days = Read-Host -Prompt 'How many days old?'
Add-Type -AssemblyName "system.io.compression.filesystem"

If ( -not (Test-Path -Path $archivepath)) {
    New-Item -Path $archivepath -ItemType directory
}
Get-Childitem -Path $source -recurse| Where-Object {`
  ($_.LastWriteTime -le (get-date).AddDays(-$days)) `
  -and ($_.LastAccessTime -le (Get-Date).AddDays(-$days))
  } |
ForEach-Object {$filename = $_.fullname
   Move-Item -Path $_.FullName -Destination $archivepath -Force -ErrorAction:Inquire
}
$archivedestination=$archivedestination + "\$(Get-Date -Format yyyyMMMMdd)-archive.zip"
Write-Host $archivedestination
if(Test-Path $archivedestination){
  Write-Host "Archive already exists"
}Else{
  [io.compression.zipfile]::CreateFromDirectory($archivepath, $archivedestination)
  Remove-Item -Path $archivepath -Force -Recurse
}
Pause