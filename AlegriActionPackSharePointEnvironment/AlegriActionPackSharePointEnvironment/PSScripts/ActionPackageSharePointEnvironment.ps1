#
# ActionPackageTemplate.ps1
#

# All Global Variable where use in this Package
$Global:ActionPackSPEnvironmentStandardPathUserCredential = "$env:USERPROFILE\Documents\ActionFlow\ActionPackSPEnvironment\UserCredential"
$Global:XmlConfigUserCredential = $null
$Global:XmlConfigEnvironment = $null
$Global:XmlCurrentEnvironment = $null
$Global:XmlCurrentUserCredential = $null
$Global:RootContext = $null
$Global:RootWeb = $null
$Global:RootSite = $null
$Global:Webs = $null

###########################################################################################################

# Allows you to bind all scripts into one function call of an action
# Hiermit binden Sie alle Scripte ein die jeweils eine Funktionsaufruf einer Aktion enthält
. "$PSScriptRoot\DependentFunction.ps1"
. "$PSScriptRoot\Environment.ps1"
. "$PSScriptRoot\UserCredential.ps1"

# You should register a new function in the two lower functions.
# Sie sollten eine neue Funktion in den beiden unteren Funktionen registrieren. 

<#.Synopsis
.DESCRIPTION
Here is checked if there is the action
Hier wird geprüft ob es die Aktion gibt
.PARAMETER actionName
The name of the action
Der Name der Aktion
#>
function Find-ActionInActionPackageSPEnvironment
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$actionName
	)
    Begin
    {
		Write-Verbose "Start Find-ActionInActionPackageSPEnvironment"     
    }
    Process
    {
          switch($actionName)
		  {
			"AP_SPEnvironment_Init" { $returnValue = $true }
			"AP_SPEnvironment_Connect" { $returnValue = $true }
			"AP_SPEnvironment_Disconnect" { $returnValue = $true }
			"AP_SPEnvironment_InitWeb" { $returnValue = $true }			
			default { $returnValue = $false }
		  }

		  return $returnValue
    }
    End
    {
		Write-Verbose "End Find-ActionInActionPackageSPEnvironment"
    }
}

<#
.Synopsis
Start the action
Start der Aktion
.DESCRIPTION
Here the corresponding action is initiated by calling the corresponding function
Hier wird die entsprechende Aktion angestossen in dem die dazugehörige Funktion aufgerufen wird
.PARAMETER xmlAction
An XML element <alg: ActionObject>
Ein XML Element <alg:ActionObject>
#>
function Start-ActionFromActionPackageSPEnvironment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlAction
	)
    Begin
    {
        Write-Verbose "Start Start-ActionFromActionPackageSPEnvironment"
    }
    Process
    {
		$actionName = $xmlAction.ActionObject.FirstChild.LocalName

		switch($actionName)
		{
			"AP_SPEnvironment_Init" { Start-AP_SPEnvironment_Init -xmlActionObject $xmlAction.ActionObject.AP_SPEnvironment_Init } #Environment.ps1
			"AP_SPEnvironment_Connect" { Start-AP_SPEnvironment_Connect -xmlActionObject $xmlAction.ActionObject.AP_SPEnvironment_Connect } #Environment.ps1
			"AP_SPEnvironment_Disconnect" { Start-AP_SPEnvironment_Disconnect -xmlActionObject $xmlAction.ActionObject.AP_SPEnvironment_Disconnect } #Environment.ps1
			"AP_SPEnvironment_InitWeb" { Start-AP_SPEnvironment_InitWeb -xmlActionObject $xmlAction.ActionObject.AP_SPEnvironment_InitWeb } #Environment.ps1		
		}

		Write-Host "Action : $($actionName) is ready" -ForegroundColor Green
		Write-Host ""
    }
    End
    {
		Write-Verbose "End Start-ActionFromActionPackageSPEnvironment"
    }
}

function Check-ExistStandardFolder
{
    <#
    .SYNOPSIS
    Check if the StandardFolder Exists
    .DESCRIPTION
    Beim Laden des Moduls wird überprüft ob die Standardordner vorhanden sind.
	Falls nicht werden die Ordner entsprechend angelegt.
    #>
    begin
    {
        Write-Verbose "Begin Check-ExistStandardFolder"
    }
    process
    {
        #Prüfe ob Standard-Pfade existieren
		$check7 = Test-Path $Global:ActionPackSPEnvironmentStandardPathUserCredential

        if (!$check7)
        {
            Write-Host "Standard-Folder from Action Pack SharePoint Environment must be created" -ForegroundColor Magenta

			if(!(Test-Path $Global:ActionPackSPEnvironmentStandardPathUserCredential)) #System
			{
                New-Item "$Global:ActionPackSPEnvironmentStandardPathUserCredential" -ItemType directory | Out-Null   #System
                Write-Host "$Global:ActionPackSPEnvironmentStandardPathUserCredential are created" -ForegroundColor Green
            }
        }
		else {
			Write-Host "Standard-Folder from Action Pack SharePoint Environment are exist" -ForegroundColor Green
		}
    }
    end
    {
        Write-Verbose "End Check-ExistStandardFolder"
    }    
}