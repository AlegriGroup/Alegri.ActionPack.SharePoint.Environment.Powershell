$Global:ActionPackageName = "SharePoint Environment"

. "$PSScriptRoot\PSScripts\AP_SPEnvironment.ps1"

Write-Host "Alegri Action Package $($Global:ActionPackageName) are ready" -ForegroundColor Green

#If you want to create default folders for your action package, please comment on the section
#Kommentieren Sie den Bereich ein, wenn Sie vor haben für Ihr Aktionspaket Standard Ordner anzulegen 
Check-ExistFolderInAP_SPEnvironment #AP_SPEnvironment