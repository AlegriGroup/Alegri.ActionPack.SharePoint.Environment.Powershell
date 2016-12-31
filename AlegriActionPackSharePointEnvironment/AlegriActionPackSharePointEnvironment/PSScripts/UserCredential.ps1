#
# UserCredential.ps1
#

<#
.Synopsis
Loading UserCredential in currently session
Lade UserCredential in aktuelle Sitzung
.DESCRIPTION
It will read the file from the passed UserCredential XML which must be from the http://schemas.powershell.ActionFlow.UserCredential.alegri.eu schema.
Then all the UserCredential are assigned to the Global:XmlConfigUserCredential

Es wird die Datei aus der übergebene UserCredential XML die vom Schema http://schemas.powershell.ActionFlow.UserCredential.alegri.eu sein muss eingelesen.
Dann werden alle UserCredential in die Global:XmlConfigUserCredential zugewiesen 
.PARAMETER pfadToXML
The path where the UserCredential XML is located
Der Pfad wo sich die UserCredential XML befindet
#>
function Load-UserCredentialsInSession
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$pfadToXML
	)
    Begin
    {
        Write-Verbose "Start Load-UserCredentialsInSession"  
    }
    Process
    {
		Write-Host "Step => The UserCredential Config file is read" -ForegroundColor Blue -BackgroundColor Yellow
		[XML]$config = Get-Content -Path $pfadToXML #System
		$users = $config.UserCredentialConfiguration.UserCredential

		if($users -eq $null)
		{
			Write-Error "It was no UserCredential found in the Environment XML File $($pfadToXML)"
		} 
		else 
		{
			$Global:XmlConfigUserCredential = $users
			Write-Host "There are Found $($users.Count) UserCredential and was loaded successfully" -ForegroundColor Green
		}
		
    }
    End
    {
		Write-Verbose "End Load-UserCredentialsInSession"  
    }
}

<#
.Synopsis
Set Current UserCredential
.DESCRIPTION
From the user credentials known in the session, the passed user name is set to the current user credential	

Aus dem in der Sitzung bekannte User Anmeldeinformationen, wird der übergebene Usernamen, auf die aktuelle User Anmeldeinformation gesetzt
.PARAMETER nameFromUserCredential
The Name from the UserCredential 
#>
function Set-CurrentUserFromCredentialsInSession
{
    [CmdletBinding()]
    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
		[string]$nameFromUserCredential
	)
    Begin
    {
        Write-Verbose "Start Set-CurrentUserFromCredentialsInSession"  
    }
    Process
    {
		$user = $Global:XmlConfigUserCredential |  Where-Object { $_.CredentialName -eq $nameFromUserCredential }

		if($user -eq $null)
		{
			Write-Error "The UserCredential was not found"
		} 
		else 
		{
			$Global:XmlCurrentUserCredential = $user
			Write-Host "The UserCredential $($nameFromUserCredential) was now the Current UserCredential" -ForegroundColor Green
		}		
    }
    End
    {
		Write-Verbose "End Set-CurrentUserFromCredentialsInSession"  
    }
}

function Watch-UserPassword
{
	<# 
	.SYNOPSIS
    Initialisierung von Password
    .DESCRIPTION
    Hier wird überprüft ob für die Credential ein Password vorhanden ist, wenn nicht wird der User nach dem Password gefragt.    
	#>
	[CmdletBinding()]
	param()
	begin
	{
		Write-Verbose "Check-UserPassword start"
	}
	process
	{
		$fileName = Get-ALG_GetFileNameForCredential

		try 
		{
			$content = Get-Content $fileName -ErrorAction Stop #System
			$Global:XmlCurrentUserCredential.SetAttribute("SecurePassword", $content);
			Write-Host "Password successfully detected." -ForegroundColor Green
		}
		catch
		{
			read-host -assecurestring | convertfrom-securestring | out-file $fileName
			Watch-UserPassword
		}			
	}
	end
	{
		Write-Verbose "Check-UserPassword end"
	}
}

function Get-ALG_GetFileNameForCredential
{
	<# 
	.SYNOPSIS
    Filename Credential
    .DESCRIPTION
    Sie erhalten den Filename der Credentialdatei für die CurrentUserCredential
   	#>
	[CmdletBinding()]
	param(
	)
	begin
	{
		Write-Verbose "Get-ALG_GetFileNameForCredential begin"
	}
	process
	{
		return $Global:ActionPackSPEnvironmentStandardPathUserCredential + "\" + $Global:XmlCurrentUserCredential.CredentialName + "_" + $Global:XmlCurrentUserCredential.UserName + ".txt"
	}
	end
	{
		Write-Verbose "Get-ALG_GetFileNameForCredential end"
	}
}

function Get-ALG_CredentialFromUserCredential
{
    <#
    .SYNOPSIS
    Erzeugt ein Credential Objekt mit den Informationen aus der <alg:UserCredential>
    .DESCRIPTION
    Es werden aus der UserCredential der UserName und SecurePassword ausgelesen. Dass SecurePassword wird in ein SecureString umgewandelt.
    Nach erzeugung des Credential Objekt wird es zurückgegeben. 
    .PARAMETER SiteProperites 
    Den XML Knoten vom Typ <alg:UserCredential>
    .OUTPUTS  
    [System.Management.Automation.PsCredential]
    #>
    [CmdletBinding()]
    param
    ( 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
		[ValidateNotNull()]
        [System.Xml.XmlElement]$XmlUserCredential        
    )
    begin
    {
        Write-Verbose "Get-ALG_CredentialFromUserCredential begin"
    }
    process
    {
        $user = $XmlUserCredential.UserName
        $pass = $XmlUserCredential.SecurePassword | ConvertTo-SecureString

        $cred = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $user, $pass
        
        return $cred 
    }
    end
    {
        Write-Verbose "Get-ALG_CredentialFromUserCredential end"
    }    
}