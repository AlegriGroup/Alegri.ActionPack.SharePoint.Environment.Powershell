#
# ActionPackageTemplate.ps1
#

# Standard Folder
$Global:AP_SPEnvironment_Folder_UserCredential = "$env:USERPROFILE\Documents\ActionFlow\AP_SPEnvironment\UserCredential"

# All Global Variable where use in this Package and is released from the outside for use
$Global:AP_SPEnvironment_XmlConfigUserCredential = $null
$Global:AP_SPEnvironment_XmlConfigEnvironment = $null
$Global:AP_SPEnvironment_XmlCurrentEnvironment = $null
$Global:AP_SPEnvironment_XmlCurrentUserCredential = $null
$Global:AP_SPEnvironment_RootContext = $null
$Global:AP_SPEnvironment_RootWeb = $null
$Global:AP_SPEnvironment_RootSite = $null
$Global:AP_SPEnvironment_RootSiteRelUrl = $null
$Global:AP_SPEnvironment_RootSiteUrl = $null
$Global:AP_SPEnvironment_Webs = $null
$Global:AP_SPEnvironment_CurrentWeb = $null
$Global:AP_SPEnvironment_ProjectPath = $null
$Global:AP_SPEnvironment_SiteRelUrl = $null
$Global:AP_SPEnvironment_SiteUrl = $null

###########################################################################################################

# Allows you to bind all scripts into one function call of an action
# Hiermit binden Sie alle Scripte ein die jeweils eine Funktionsaufruf einer Aktion enthält
. "$PSScriptRoot\DependentFunction.ps1"
. "$PSScriptRoot\Environment.ps1"
. "$PSScriptRoot\UserCredential.ps1"

# You should register a new function in the two Lower functions.
# Sie sollten eine neue Funktion in den beiden unteren Funktionen registrieren. 

<#.Synopsis
.DESCRIPTION
Here is checked if there is the action
Hier wird geprüft ob es die Aktion gibt
.PARAMETER actionName
The name of the action
Der Name der Aktion
#>
function Find-ActionInAP_SPEnvironment
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
		Write-Verbose "Start Find-ActionInAP_SPEnvironment"     
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
		Write-Verbose "End Find-ActionInAP_SPEnvironment"
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
function Start-ActionFromAP_SPEnvironment
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlAction
	)
    Begin
    {
        Write-Verbose "Start Start-ActionFromAP_SPEnvironment"
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
		Write-Verbose "End Start-ActionFromAP_SPEnvironment"
    }
}

function Check-ExistFolderInAP_SPEnvironment
{
    <#
    .SYNOPSIS
    Check if the StandardFolder Exists
	Prüft ob die Standard Ordner vorhanden sind.
    .DESCRIPTION
	When the module is loaded, it is checked whether the default folders are available. If not, the folders are created accordingly.
    Beim Laden des Moduls wird überprüft ob die Standardordner vorhanden sind. Falls nicht werden die Ordner entsprechend angelegt.
    #>
    begin
    {
        Write-Verbose "Begin Check-ExistFolderInAP_SPEnvironment"
    }
    process
    {
        #Check if Standard folders exist / Prüfe ob Standard Ordner existieren
		$folder1 = $Global:AP_SPEnvironment_Folder_UserCredential
		$checkFolder1 = Test-Path $folder1

        if (!$checkFolder1)
        {
            Write-Host "Standard-Folder from Action Pack $($Global:ActionPackageName) must be created" -ForegroundColor Magenta

			if(!(Test-Path $folder1)) #System
			{
                New-Item "$folder1" -ItemType directory | Out-Null   #System
                Write-Host "$folder1 are created" -ForegroundColor Green
            }
        }
		else {
			Write-Host "Standard-Folder from Action Pack $($Global:ActionPackageName) are exist" -ForegroundColor Green
		}
    }
    end
    {
        Write-Verbose "End Check-ExistFolderInAP_SPEnvironment"
    }    
}