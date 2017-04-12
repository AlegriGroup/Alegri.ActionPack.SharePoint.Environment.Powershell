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
		if($xmlActionObject.pathToProject)
		{
			$Global:AP_SPEnvironment_ProjectPath = $xmlActionObject.pathToProject;
		}

		$envxml = Check-AP_SPEnvironment_ReplaceEnvVariable -path $xmlActionObject.pathXMLEnvironment
		$credxml = Check-AP_SPEnvironment_ReplaceEnvVariable -path $xmlActionObject.pathXMLUserCredential

		Load-AP_SPEnvironment_EnvironmentsInSession -pfadToXML $envxml

		Load-AP_SPEnvironment_UserCredentialsInSession -pfadToXML $credxml			
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
			
		Set-AP_SPEnvironment_CurrentEnvFromEnvsInSession -nameFromEnvironment $envName

		if($xmlActionObject.UserCredentialName)	
		{	 
			Set-AP_SPEnvironment_CurrentUserFromCredentialsInSession -nameFromUserCredential $xmlActionObject.UserCredentialName 
		} else 
		{ 	
			Set-AP_SPEnvironment_CurrentUserFromCredentialsInSession -nameFromUserCredential $Global:AP_SPEnvironment_XmlCurrentEnvironment.Credential 
		}
				
		Watch-AP_SPEnvironment_UserPassword 
				
		#Hole Credential vom User
		$cred = Get-AP_SPEnvironment_CredentialFromUserCredential -XmlUserCredential $Global:AP_SPEnvironment_XmlCurrentUserCredential #UserCredential
				
		#Verbindung mit der Umgebung
		Connect-AP_SPEnvironment_CurrentEnv -siteUrl $Global:AP_SPEnvironment_XmlCurrentEnvironment.SiteUrl -siteCredentials $cred -siteConnectTyp $Global:AP_SPEnvironment_XmlCurrentEnvironment.ConnectTyp

		#Load the Webs
		$loadAllWebs = $false
		if($xmlActionObject.LoadAllWebs -eq "true") { $loadAllWebs = $true }
		
		Load-AP_SPEnvironment_WebsFromCurrentEnv -loadAllWebs $loadAllWebs

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
        Disconnect-AP_SPEnvironment_CurrentEnv
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
		$siteTitle = $null
		
		if($xmlActionObject.Destignation) {
			$env = Get-EnvironmentFromDestignation -destignation $xmlActionObject.Destignation
			$siteTitle = $env.Title
		}

		if($xmlActionObject.SiteTitle) {
			$siteTitle = $xmlActionObject.SiteTitle
		}

		if($siteTitle -ne $null) {
			Set-AP_SPEnvironment_CurrentWebFromGlobalWebs -SiteTitle $siteTitle
		}
    }
    End
    {
		Write-Verbose "End Start-AP_SPEnvironment_InitWeb"
    }
}

function Load-AP_SPEnvironment_EnvironmentsInSession
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
        Write-Verbose "Start Load-AP_SPEnvironment_EnvironmentsInSession"  
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
			$Global:AP_SPEnvironment_XmlConfigEnvironment = $env
			Write-Host "There are Found $($env.Count) Environments and was loaded successfully" -ForegroundColor Green
		}
		
    }
    End
    {
		Write-Verbose "End Load-AP_SPEnvironment_EnvironmentsInSession"  
    }
}

<#
.Synopsis
Set current environment
Aktuelle Umgebung einstellen
.DESCRIPTION
It is read from the environments known in the session, the given environment and placed on the current environment

Es wird aus den in der Session bekannten Umgebungen, die übergebene Umgebung ausgelesen und auf die aktuelle Umgebung gesetzt
.PARAMETER $nameFromEnvironment
The Name from Environment
Der Name der Umgebung
#>
function Set-AP_SPEnvironment_CurrentEnvFromEnvsInSession
{
    [CmdletBinding()]

    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
		[string]$nameFromEnvironment
	)
    Begin
    {
        Write-Verbose "Start Set-AP_SPEnvironment_CurrentEnvFromEnvsInSession"  
    }
    Process
    {
		$env = Get-EnvironmentFromDestignation -destignation $nameFromEnvironment
		
		if($env -eq $null)
		{
			Write-Error "The Environment was not found"
		} 
		else 
		{
			$Global:AP_SPEnvironment_XmlCurrentEnvironment = $env
			$Global:AP_SPEnvironment_SiteRelUrl = $env.SiteRelUrl
			$Global:AP_SPEnvironment_SiteUrl = $env.SiteUrl

			Write-Host "The Environment $($nameFromEnvironment) was now the Current Environemnt" -ForegroundColor Green
		}		
    }
    End
    {
		Write-Verbose "End Set-AP_SPEnvironment_CurrentEnvFromEnvsInSession"  
    }
}

function Connect-AP_SPEnvironment_CurrentEnv
{
    <#
    .SYNOPSIS
	Makes the connection to the side
    Stellt die Verbindung zur Seite her
    .DESCRIPTION
    Makes the connection to the side
    Stellt die Verbindung zur Seite her
    .PARAMETER siteUrl 
	The full URL to the page, e.g. Https: // pcampergue / sites / test / TestSubsite /
    Die vollständige URL zur Seite z.B. https://pcampergue/sites/test/TestSubsite/
    .PARAMETER siteCredentials
	Please enter the name of the System.Management.Automation.PsCredential
    Bitte geben Sie den Namen vom hinterlegten System.Management.Automation.PsCredential
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
        Write-Verbose "Connect-AP_SPEnvironment_CurrentEnv begin"
    }
    process
    {
        Write-Host "Connect To Site ($siteUrl) with ConnectTyp ($siteConnectTyp)" -ForegroundColor Magenta
        try
        {
            switch ($siteConnectTyp)
            {
                "Teamsite" { Use-AP_SPEnvironment_PnP_Connect-SPOnline -Url $siteUrl -Credentials $siteCredentials -ErrorAction Stop}
                "ADFS" { Use-AP_SPEnvironment_AlegriModul_Connect-SPOnlineADFS -Url $siteUrl -ErrorAction Stop}
                "ADFS-SecurePin" 
                { 
                    Use-AP_SPEnvironment_AlegriModul_Connect-SPOnlineADFS -Url $siteUrl -Use32BitMode -ErrorAction Stop
                    $ctx = Get-SPOContext
                    $ctx.RequestTimeout = 18000000
                }
                default { Write-Error " Unknow ConnectTyp "}
            }
            
            Write-Host "Connect To Site ($siteUrl) successfully" -ForegroundColor Green

            $Global:AP_SPEnvironment_RootContext = Use-AP_SPEnvironment_PnP_GetSPOContext
			$Global:AP_SPEnvironment_RootWeb = Use-AP_SPEnvironment_PnP_Get-SPOWeb 
			$Global:AP_SPEnvironment_RootSite = Use-AP_SPEnvironment_PnP_Get-PnPSite 
			$Global:AP_SPEnvironment_RootSiteRelUrl = $Global:AP_SPEnvironment_RootWeb.ServerRelativeUrl
			$Global:AP_SPEnvironment_RootSiteUrl = $Global:AP_SPEnvironment_RootWeb.Url
        }
        catch
        {
           throw "$_.Exception"
        }       
    }
    end
    {
        Write-Verbose "Connect-AP_SPEnvironment_CurrentEnv end"
    }    
}

function Disconnect-AP_SPEnvironment_CurrentEnv
{
	<# 
	.SYNOPSIS
	Closes the connection to SharePoint
	Schliesst die Verbindung zu SharePoint
    .DESCRIPTION
	It is checked how the connection type is, afterwards we call the connection type specific connection function.
    Es wird geprüft wie die Verbindungsart ist, danach wir die Verbindungsart spezifische Funktion zum Verbindungsschliessen aufgerufen. 
	#>
	[CmdletBinding()]
	param()
	begin
	{
		Write-Verbose "Begin Disconnect-AP_SPEnvironment_CurrentEnv"
	}
	process
	{
		Write-Host "Disconnecting site collection $($Global:AP_SPEnvironment_XmlCurrentEnvironment.SiteUrl)" 

		if($Global:AP_SPEnvironment_XmlCurrentEnvironment.connectTyp -eq "Teamsite")
		{
			Use-AP_SPEnvironment_PnP_Disconnect-SPOnline 
		}
		elseif($Global:AP_SPEnvironment_XmlCurrentEnvironment.connectTyp -eq "ADFS" -or $Global:AP_SPEnvironment_XmlCurrentEnvironment.connectTyp -eq "ADFS-SecurePin")
		{
			Use-AP_SPEnvironment_AlegriModul_Disconnect-SPOnlineADFS
		}
		else 
		{
			Write-Error "Unknow CurrentTyp"
		}

		$Global:AP_SPEnvironment_RootContext = $null
		$Global:AP_SPEnvironment_RootWeb = $null
		$Global:AP_SPEnvironment_RootSite = $null
	}
	end
	{
		Write-Verbose "End Disconnect-AP_SPEnvironment_CurrentEnv"
	}
}

function Create-AP_SPEnvironment_CustomWebObject
{
    <# 
	.SYNOPSIS
	Creates a System.Object
    Erstellt ein System.Object 	
    .DESCRIPTION
	Creates a Weboject with four parameters. Title, ParentTitle, Web, IsRoot, and returns the object
    Erstellt ein Weboject mit vier Parametern. Title, ParentTitle, Web, IsRoot und gibt das Object zurück
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
	The object filled with the properties
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
		Write-Verbose "Create-AP_SPEnvironment_CustomWebObject begin"
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
		Write-Verbose "Create-AP_SPEnvironment_CustomWebObject end"
	}
}

function Load-AP_SPEnvironment_WebsFromCurrentEnv
{
	<# 
	.SYNOPSIS
	Initialize the SiteCollection
    Initialisieren der SiteCollection	
    .DESCRIPTION
	First, a CustomWebObject is created for the root Web and assigned to the global variable $ Global: AP_SPEnvironment_Webs. If desired, the loading of the other webs is then initiated.
    Als erstes wird für das Root Web ein CustomWebObject erzeugt und der Globalen Variable $Global:AP_SPEnvironment_Webs zugewiesen.
	Anschließend falls gewünscht wird das Laden der anderen Webs angestossen.   
    .PARAMETER loadAllWebs 
    If you set the value to True, all Webs will be loaded by the complete SiteCollection.
	Wenn Sie den Wert auf True setzen, werden alle Webs von der ganzen SiteCollection geladen.
	#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
		[ValidateNotNullOrEmpty()]
        [bool]$loadAllWebs
	)
	begin
	{
		Write-Verbose "Load-AP_SPEnvironment_WebsFromCurrentEnv begin"
	}
	process
	{
		Write-Host "START Load-AP_SPEnvironment_WebsFromCurrentEnv..."

		$Global:AP_SPEnvironment_Webs = @();

		#Start with Root
		$webTitle = $Global:AP_SPEnvironment_RootWeb.Title
		$customWebOject = Create-AP_SPEnvironment_CustomWebObject -Title $webTitle -ParentTitle "" -Web $Global:AP_SPEnvironment_RootWeb -IsRoot $true
		$Global:AP_SPEnvironment_Webs += $customWebOject
		
		Write-Host "Loaded $($webTitle) are successful"
        
		if($loadAllWebs)
		{
			$webs = Use-AP_SPEnvironment_PnP_Get-PnPSubWebs -Web $Global:AP_SPEnvironment_RootWeb

			if($webs -ne $null) 
			{
				Load-AP_SPEnvironment_ChildWebs -parentWeb $Global:AP_SPEnvironment_RootWeb -children $webs
			}
		}
		    
		Write-Host "END Load-AP_SPEnvironment_WebsFromCurrentEnv..." 
		Write-Host
	}
	end
	{
		Write-Verbose "Load-AP_SPEnvironment_WebsFromCurrentEnv end"
	}	
}

function Load-AP_SPEnvironment_ChildWebs
{
	<# 
	.SYNOPSIS
	Initialize the subsites
    Initialisieren der Subsiten	
    .DESCRIPTION
	It is interacted through the whole SiteCollection, and a CustomWebObject is generated for each found Web and assigned to the Global Veriable $ Global: AP_SPEnvironment_Webs.
    Es wird durch die ganze SiteCollection interiert und für jedes gefunde Web wird ein CustomWebObject erzeugt und der Globalen Veriable $Global:AP_SPEnvironment_Webs zugewiesen.
    .PARAMETER parentWeb 
	The SharePoint Web Object from the parent element
    Das SharePoint Web Object vom Vater Element
    .PARAMETER $children
	The Children Element
	Die Kinder Elemente
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
		Write-Verbose "Load-AP_SPEnvironment_ChildWebs begin"
	}
    process
    {
        $parentTitle = $parentWeb.Title

        foreach($subSite in $children)
        {   
			$Global:AP_SPEnvironment_Webs += Create-AP_SPEnvironment_CustomWebObject -Title $subSite.Title -ParentTitle $parentTitle -Web $subSite -IsRoot $false 
                
			Write-Host -Message "Load Web '$($subSite.Title)' are success" -Type success
                
			$webs = Use-AP_SPEnvironment_PnP_Get-PnPSubWebs -Web $subSite

			if($webs -ne $null) 
			{
				Load-AP_SPEnvironment_ChildWebs -parentWeb $subSite -children $webs
			}           
        }
    } 
	end
	{
		Write-Verbose "Load-AP_SPEnvironment_ChildWebs end"
	}
}

function Set-AP_SPEnvironment_CurrentWebFromGlobalWebs
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
		Write-Verbose "Set-AP_SPEnvironment_CurrentWebFromGlobalWebs begin"
	}
	process
	{
		$curWeb = Get-WebFromTitle -title $SiteTitle
        
        if($curWeb -ne $null)
        {
            $Global:AP_SPEnvironment_CurrentWeb = $curWeb

		    Write-Host "Setting Current Web $($curWeb.Title) are succesful" -ForegroundColor Green
        }
        else 
        {
            throw "The Web with Title [$($SiteTitle)] are not founded [Set-AP_SPEnvironment_CurrentWebFromGlobalWebs]"
        }
		
	}
	end
	{
		Write-Verbose "Set-AP_SPEnvironment_CurrentWebFromGlobalWebs end"
	}
    
}

<#.Synopsis
<!<SnippetShortDescription>!>
.DESCRIPTION
<!<SnippetLongDescription>!>
.EXAMPLE
<!<SnippetExample>!>
.EXAMPLE
<!<SnippetAnotherExample>!>
#>
function Check-AP_SPEnvironment_ReplaceEnvVariable
{
    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $path
	)
    Begin
    {
          Write-Verbose "Check-AP_SPEnvironment_ReplaceEnvVariable BEGIN"
    }
    Process
    {
        if($Global:AP_SPEnvironment_ProjectPath -ne $null)
		{
			$path = $path.Replace("{PathToProject}", $Global:AP_SPEnvironment_ProjectPath);
		}
		$path = $path.Replace("{SiteRelUrl}", $Global:AP_SPEnvironment_SiteRelUrl );
		$path = $path.Replace("{SiteUrl}", $Global:AP_SPEnvironment_SiteUrl);
		$path = $path.Replace("{RootSiteRelUrl}", $Global:AP_SPEnvironment_RootSiteRelUrl );
		$path = $path.Replace("{RootSiteUrl}", $Global:AP_SPEnvironment_RootSiteUrl);

		return $path
    }
    End
    {
		Write-Verbose "Check-AP_SPEnvironment_ReplaceEnvVariable END"
    }
}

function Get-AP_SPEnvironment_ProjectPath
{
	return $Global:AP_SPEnvironment_ProjectPath;
}

function Get-EnvironmentFromDestignation
{
	[CmdletBinding()]
    [OutputType([int])]
    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $destignation
	)
    Begin
    {
          Write-Verbose "Get-EnvironmentFromDestignation BEGIN"
    }
    Process
    {
        $env = $Global:AP_SPEnvironment_XmlConfigEnvironment |  Where-Object {$_.Designation -eq $destignation }
		
		if($env){ return $env } 
		else
		{
			throw "Destignation $($destignation) are unkown [Get-EnvironmentFromDestignation]"
		}

    }
    End
    {
		Write-Verbose "Get-EnvironmentFromDestignation END"
    }
}

function Get-WebFromTitle 
{
[CmdletBinding()]
    [OutputType([int])]
    param
    (
        $title
	)
    Begin
    {
          Write-Verbose "Get-WebFromTitle BEGIN"
    }
    Process
    {
        $curWeb = $Global:AP_SPEnvironment_Webs | Where-Object { $_.Title -eq $title }
		
		if($curWeb){ return $curWeb } 
		else
		{
			throw "The Web with Title [$($title)] are not founded [Get-WebFromTitle]"
		}

    }
    End
    {
		Write-Verbose "Get-WebFromTitle END"
    }
}