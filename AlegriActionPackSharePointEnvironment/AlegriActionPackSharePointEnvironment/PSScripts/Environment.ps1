#
# Environment.ps1
#

function Start-AP_SPEnvironment_Init
{
	<#
	.Synopsis
	Start AP_SPEnvironment_Init
	.DESCRIPTION
	The Start for the Action AP_SPEnvironment_Init
	.PARAMETER xmlActionObject
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlActionObject
	)
    Begin
    {
		Write-Verbose "Start Start-AP_SPEnvironment_Init"
    }
    Process
    {	
		#Load Environments		
		if($xmlActionObject.pathXMLEnvironment)	{ 
			Load-EnvironmentsInSession -pfadToXML $xmlActionObject.pathXMLEnvironment 
		}else{ 
			Load-EnvironmentsInSession -pfadToXML $Global:EnvironmentXMLFile
		}

		#Load UserCredential
		if($xmlActionObject.pathXMLUserCredential) { 
			Load-UserCredentialsInSession -pfadToXML $xmlActionObject.pathXMLUserCredential
		}else{	
			Load-UserCredentialsInSession -pfadToXML $Global:UserCredentialXMLFile 
		}		
    }
    End
    {
		Write-Verbose "End Start-AP_SPEnvironment_Init"
    }
}

function Start-AP_SPEnvironment_Connect
{
	<#
	.Synopsis
	Start AP_SPEnvironment_Connect
	.DESCRIPTION
	The Start for the Action AP_SPEnvironment_Connect
	.PARAMETER xmlActionObject
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlActionObject
	)
    Begin
    {
		Write-Verbose "Start Start-AP_SPEnvironment_Connect"
    }
    Process
    {
		$envName = $xmlActionObject.EnvironmentName
			
		#Set Current Environment
		Set-CurrentEnvironmentFromEnvironmentsInSession -nameFromEnvironment $envName

		#Set Current User
		if($xmlActionObject.UserCredentialName)	{ 
			Set-CurrentUserFromCredentialsInSession -nameFromUserCredential $xmlActionObject.UserCredentialName 
		}else{ 
			Set-CurrentUserFromCredentialsInSession -nameFromUserCredential $Global:XmlCurrentEnvironment.Credential 
		}
				
		Watch-UserPassword 
				
		#Hole Credential vom User
		$cred = Get-ALG_CredentialFromUserCredential -XmlUserCredential $Global:XmlCurrentUserCredential #UserCredential
				
		#Verbindung mit der Umgebung
		Connect-CurrentEnvironment -siteUrl $Global:XmlCurrentEnvironment.SiteUrl -siteCredentials $cred -siteConnectTyp $Global:XmlCurrentEnvironment.ConnectTyp

		#Load the Webs
		$loadAllWebs = $false
		if($xmlActionObject.LoadAllWebs -eq "true") { $loadAllWebs = $true }
		
		Load-WebsFromCurrentEnvironment -loadAllWebs $loadAllWebs

    }
    End
    {
		Write-Verbose "End Start-AP_SPEnvironment_Connect"
    }
}

function Start-AP_SPEnvironment_Disconnect
{
	<#
	.Synopsis
	Start AP_SPEnvironment_Disconnect
	.DESCRIPTION
	The Start for the Action AP_SPEnvironment_Disconnect
	.PARAMETER xmlActionObject
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlActionObject
	)
    Begin
    {
		Write-Verbose "Start Start-AP_SPEnvironment_Disconnect"
    }
    Process
    {
        Disconnect-CurrentEnvironment
    }
    End
    {
		Write-Verbose "End Start-AP_SPEnvironment_Disconnect"
    }
}

function Start-AP_SPEnvironment_InitWeb
{
	<#
	.Synopsis
	Start AP_SPEnvironment_InitWeb
	.DESCRIPTION
	The Start for the Action AP_SPEnvironment_InitWeb
	.PARAMETER xmlActionObject
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [System.Xml.XmlLinkedNode]$xmlActionObject
	)
    Begin
    {
		Write-Verbose "Start Start-AP_SPEnvironment_InitWeb"
    }
    Process
    {
        $siteTitle = $xmlActionObject.SiteTitle
		Set-CurrentWebFromGlobalWebs -SiteTitle $siteTitle
    }
    End
    {
		Write-Verbose "End Start-AP_SPEnvironment_InitWeb"
    }
}

function Load-EnvironmentsInSession
{
	<#
	.Synopsis
	Loading environments in currently session
	Lade Umgebungen in aktuell Sitzung
	.DESCRIPTION
	It will read the file from the passed Environment XML which must be from the http://schemas.powershell.ActionFlow.Environment.alegri.eu schema.
	Then all the environments are assigned to the Global:XmlConfigEnvironment

	Es wird die Datei aus der übergebene Environment XML die vom Schema http://schemas.powershell.ActionFlow.Environment.alegri.eu sein muss eingelesen.
	Dann werden alle Environments in die Global:XmlConfigEnvironment zugewiesen 
	.PARAMETER pfadToXML
	The path where the Environment XML is located
	Der Pfad wo sich die Environment XML befindet
	#>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$pfadToXML
	)
    Begin
    {
        Write-Verbose "Start Load-EnvironmentsInSession"  
    }
    Process
    {
		Write-Host "Step => The Environment Config file is read" -ForegroundColor Blue -BackgroundColor Yellow
		[XML]$config = Get-Content -Path $pfadToXML
		$env = $config.EnvironmentConfiguration.Environment

		if($env -eq $null)
		{
			Write-Error "It was no Environment found in the Environment XML File $($pfadToXML)"
		}else{
			$Global:XmlConfigEnvironment = $env
			Write-Host "There are Found $($env.Count) Environments and was loaded successfully" -ForegroundColor Green
		}
		
    }
    End
    {
		Write-Verbose "End Load-EnvironmentsInSession"  
    }
}

<#
.Synopsis
Set current environment
.DESCRIPTION
It is read from the environments known in the session, the given environment and placed on the current environment

Es wird aus den in der Session bekannten Umgebungen, die übergebene Umgebung ausgelesen und auf die aktuelle Umgebung gesetzt
.PARAMETER $nameFromEnvironment
The Name from Environment
Der Name der Umgebung
#>
function Set-CurrentEnvironmentFromEnvironmentsInSession
{
    [CmdletBinding()]

    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
		[string]$nameFromEnvironment
	)
    Begin
    {
        Write-Verbose "Start Set-CurrentEnvironmentFromEnvironmentsInSession"  
    }
    Process
    {
		$env = $Global:XmlConfigEnvironment |  Where-Object {$_.Designation -eq $nameFromEnvironment }
		if($env -eq $null)
		{
			Write-Error "The Environment was not found"
		} 
		else 
		{
			$Global:XmlCurrentEnvironment = $env
			Write-Host "The Environment $($nameFromEnvironment) was now the Current Environemnt" -ForegroundColor Green
		}		
    }
    End
    {
		Write-Verbose "End Set-CurrentEnvironmentFromEnvironmentsInSession"  
    }
}

function Connect-CurrentEnvironment
{
    <#
    .SYNOPSIS
    Stellt die Verbindung zur Seite her
    .DESCRIPTION
    eine ausführlichere Erläuterung der Aufgabe eines Skripts bzw. einer Funktion.
    .PARAMETER siteUrl 
    Der vollständige Pfad zur Seite z.B. https://daimler/sites/03999/TestSubsite/
    .PARAMETER siteCredentials
    Bitte geben Sie den Namen vom hinterlegten Windows Creditial
    .PARAMETER siteConnectTyp
    Bei einer normal Windows Authentifizierung => Teamsite
    Bei einer ADFS Verbindung => ADFS
    Bei einer ADFS Verbindung mit Secure Pin => ADFS-SecurePin   
    #>
    [CmdletBinding()]
    param
    ( 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
        [string]$siteUrl,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
		[ValidateNotNullOrEmpty()]
        [System.Management.Automation.PsCredential]$siteCredentials,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=2)]
		[ValidateNotNullOrEmpty()]
        [string]$siteConnectTyp = "Teamsite"
    )
    begin
    {
        Write-Verbose "Connect-CurrentEnvironment begin"
    }
    process
    {
        Write-Host "Connect To Site ($siteUrl) with ConnectTyp ($siteConnectTyp)" -ForegroundColor Magenta
        try
        {
            switch ($siteConnectTyp)
            {
                "Teamsite" { PnPFunc_Connect-SPOnline -Url $siteUrl -Credentials $siteCredentials -ErrorAction Stop}
                "ADFS" { AlegriModulFunc_Connect-SPOnlineADFS -Url $siteUrl -ErrorAction Stop}
                "ADFS-SecurePin" 
                { 
                    AlegriModulFunc_Connect-SPOnlineADFS -Url $siteUrl -Use32BitMode -ErrorAction Stop
                    $ctx = Get-SPOContext
                    $ctx.RequestTimeout = 18000000
                }
                default { Write-Error " Unknow ConnectTyp "}
            }
            
            Write-Host "Connect To Site ($siteUrl) successfully" -ForegroundColor Green

            $Global:RootContext = PnPFunc_GetSPOContext
			$Global:RootWeb = PnPFunc_Get-SPOWeb 
			$Global:RootSite = PnPFunc_Get-PnPSite 
        }
        catch
        {
           throw "$_.Exception"
        }       
    }
    end
    {
        Write-Verbose "Connect-CurrentEnvironment end"
    }    
}

function Disconnect-CurrentEnvironment
{
	<# 
	.SYNOPSIS
    Schliesst die Verbindung zu SharePoint
    .DESCRIPTION
    Es wird geprüft wie die Verbindungsart ist, danach wir die Verbindungsart spezifische Funktion
	zum Verbindungsschliessen aufgerufen. 
	#>
	[CmdletBinding()]
	param()
	begin
	{
		Write-Verbose "Begin Disconnect-CurrentEnvironment"
	}
	process
	{
		Write-Host "Disconnecting site collection $($Global:XmlCurrentEnvironment.SiteUrl)" 

		if($Global:XmlCurrentEnvironment.connectTyp -eq "Teamsite")
		{
			PnPFunc_Disconnect-SPOnline 
		}
		elseif($Global:XmlCurrentEnvironment.connectTyp -eq "ADFS" -or $Global:XmlCurrentEnvironment.connectTyp -eq "ADFS-SecurePin")
		{
			AlegriModulFunc_Disconnect-SPOnlineADFS 
		}
		else 
		{
			Write-Error "Unknow CurrentTyp"
		}

		$Global:RootContext = $null
		$Global:RootWeb = $null
		$Global:RootSite = $null
	}
	end
	{
		Write-Verbose "End Disconnect-CurrentEnvironment"
	}
}

function Create-CustomWebObject
{
    <# 
	.SYNOPSIS
    Erstellt ein System.Object 	
    .DESCRIPTION
    Erstellt ein Weboject mit drei Parametern. SiteId, XMLWeb, Web und gibt das Object zurück
    .PARAMETER Title 
	The title of the page
    Den Title der Seite
	.PARAMETER ParentTitle
	If the web is a subweb, he wears the title of the parent's web
	Wenn das Web eine SubWeb ist, trägt er den Seiten Title des Elternteils
	.PARAMETER Web
	The Web Object
	Das Web Object 
	.PARAMETER IsRoot
	Specifies whether the web is RootWeb
	Gibt an ob es sich um das Root Web handelt
	.OUTPUT
	Das Objekt mit den Eigeneschaften gefüllt   
	#>
	[CmdletBinding()]
    param(
        [string]
        $Title, 
        [string]
        $ParentTitle,
        [Microsoft.SharePoint.Client.Web] 
        $Web,
		[bool]
		$IsRoot
    )
	begin
	{
		Write-Verbose "Create-CustomWebObject begin"
	}
    Process
    {
        $objAverage = New-Object System.Object
        $objAverage | Add-Member -type NoteProperty -name Title -value $Title
        $objAverage | Add-Member -type NoteProperty -name ParentTitle -value $ParentTitle
        $objAverage | Add-Member -type NoteProperty -name Web -value $Web
		$objAverage | Add-Member -type NoteProperty -name IsRoot -value $IsRoot
        return $objAverage
    }
	end
	{
		Write-Verbose "Create-CustomWebObject end"
	}
}

function Load-WebsFromCurrentEnvironment
{
	<# 
	.SYNOPSIS
    Initialisieren der SiteCollection	
    .DESCRIPTION
    tbd...  
    .PARAMETER loadAllWebs 
    If you set the value to True, all Webs will be loaded by the complete SiteCollection.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
        [bool]$loadAllWebs
	)
	begin
	{
		Write-Verbose "Load-WebsFromCurrentEnvironment begin"
	}
	process
	{
		Write-Host "START Load-WebsFromCurrentEnvironment..."

		$Global:Webs = @();

		#Start with Root
		$webTitle = $Global:RootWeb.Title
		$customWebOject = Create-CustomWebObject -Title $webTitle -ParentTitle "" -Web $Global:RootWeb -IsRoot $true
		$Global:Webs += $customWebOject
		
		Write-Host "Loaded $($webTitle) are successful"
        
		if($loadAllWebs)
		{
			$webs = PnPFunc_Get-PnPSubWebs -Web $Global:RootWeb

			if($webs -ne $null) 
			{
				Load-ChildWebs -parentWeb $Global:RootWeb -children $webs
			}
		}
		    
		Write-Host "END Load-WebsFromCurrentEnvironment..." 
		Write-Host
	}
	end
	{
		Write-Verbose "Load-WebsFromCurrentEnvironment end"
	}	
}

function Load-ChildWebs
{
	<# 
	.SYNOPSIS
    Initialisieren der Subsiten	
    .DESCRIPTION
    Es wird versucht die Subsiten aus der XML Datei, aus dem SharePoint zu laden. 
	Falls die Subsiten vorhanden sind wird ein WebObject erzeugt und 
	global im Global:Webs zur Verfügung gestellt.
    .PARAMETER parentWeb 
    Das SharePoint Web Object vom Vater Element
    .PARAMETER XMLWebs
	Die Subsiten die in der Provisiong Konfigurationsdatei vorhanden sind.  
	#>
	[CmdletBinding()]
	Param(
        [Microsoft.SharePoint.Client.Web]
        $parentWeb,
        [System.Array]
        $children
    )
	begin
	{
		Write-Verbose "Load-ChildWebs begin"
	}
    process
    {
        $parentTitle = $parentWeb.Title

        foreach($subSite in $children)
        {   
			$Global:Webs += Create-CustomWebObject -Title $subSite.Title -ParentTitle $parentTitle -Web $subSite -IsRoot $false 
                
			Write-Host -Message "Load Web '$($subSite.Title)' are success" -Type success
                
			$webs = PnPFunc_Get-PnPSubWebs -Web $subSite

			if($webs -ne $null) 
			{
				Load-ChildWebs -parentWeb $subSite -children $webs
			}           
        }
    } 
	end
	{
		Write-Verbose "Load-ChildWebs end"
	}
}

function Set-CurrentWebFromGlobalWebs
{
	<# 
	.SYNOPSIS
	Current Subsite data is set
    Aktuelle Subsite Daten werden gesetzt	
    .DESCRIPTION
	The associated Web is loaded with the SiteID. This sets the CurrentSideId, CurrentWebXML, CurrentWeb.
    Es wird mit der SiteID das dazugehörige Web geladen. Damit werden die CurrentSideId, CurrentWebXML, CurrentWeb gesetzt.
    .PARAMETER SiteId
	The SiteId from the SubSite of the Provisioning Script
    Die SiteId aus der SubSite des Provisioning Skript   
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
		[ValidateNotNullOrEmpty()]
        [string]$SiteTitle 
	)
	begin
	{
		Write-Verbose "Set-CurrentWebFromGlobalWebs begin"
	}
	process
	{
		$curWeb = $Global:Webs | Where-Object { $_.Title -eq $SiteTitle }

		$Global:CurrentWeb = $curWeb

		Write-Host "Setting Current Web $($curWeb.Title) are succesful"
	}
	end
	{
		Write-Verbose "Set-CurrentWebFromGlobalWebs end"
	}
    
}

