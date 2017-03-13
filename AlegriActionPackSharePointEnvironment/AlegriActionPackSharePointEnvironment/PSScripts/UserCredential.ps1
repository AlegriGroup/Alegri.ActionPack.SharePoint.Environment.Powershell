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
function Load-AP_SPEnvironment_UserCredentialsInSession
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [string]$pfadToXML
	)
    Begin
    {
        Write-Verbose "Start Load-AP_SPEnvironment_UserCredentialsInSession"  
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
			$Global:AP_SPEnvironment_XmlConfigUserCredential = $users
			Write-Host "There are Found $($users.Count) UserCredential and was loaded successfully" -ForegroundColor Green
		}
		
    }
    End
    {
		Write-Verbose "End Load-AP_SPEnvironment_UserCredentialsInSession"  
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
function Set-AP_SPEnvironment_CurrentUserFromCredentialsInSession
{
    [CmdletBinding()]
    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
		[string]$nameFromUserCredential
	)
    Begin
    {
        Write-Verbose "Start Set-AP_SPEnvironment_CurrentUserFromCredentialsInSession"  
    }
    Process
    {
		$user = $Global:AP_SPEnvironment_XmlConfigUserCredential |  Where-Object { $_.CredentialName -eq $nameFromUserCredential }

		if($user -eq $null)
		{
			Write-Error "The UserCredential was not found"
		} 
		else 
		{
			$Global:AP_SPEnvironment_XmlCurrentUserCredential = $user
			Write-Host "The UserCredential $($nameFromUserCredential) was now the Current UserCredential" -ForegroundColor Green
		}		
    }
    End
    {
		Write-Verbose "End Set-AP_SPEnvironment_CurrentUserFromCredentialsInSession"  
    }
}

function Watch-AP_SPEnvironment_UserPassword
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
		Write-Verbose "Watch-AP_SPEnvironment_UserPassword start"
	}
	process
	{
		$fileName = Get-AP_SPEnvironment_GetFileNameForCredential

		try 
		{
			$content = Get-Content $fileName -ErrorAction Stop #System
			$Global:AP_SPEnvironment_XmlCurrentUserCredential.SetAttribute("SecurePassword", $content);
			Write-Host "Password successfully detected." -ForegroundColor Green
		}
		catch
		{
			read-host -assecurestring | convertfrom-securestring | out-file $fileName
			Watch-AP_SPEnvironment_UserPassword
		}			
	}
	end
	{
		Write-Verbose "Watch-AP_SPEnvironment_UserPassword end"
	}
}

function Get-AP_SPEnvironment_GetFileNameForCredential
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
		Write-Verbose "Get-AP_SPEnvironment_GetFileNameForCredential begin"
	}
	process
	{
        $userName = $Global:AP_SPEnvironment_XmlCurrentUserCredential.UserName.Replace("\","_");

		return $Global:AP_SPEnvironment_Folder_UserCredential + "\" + $Global:AP_SPEnvironment_XmlCurrentUserCredential.CredentialName + "_" + $userName + ".txt"
	}
	end
	{
		Write-Verbose "Get-AP_SPEnvironment_GetFileNameForCredential end"
	}
}

function Get-AP_SPEnvironment_CredentialFromUserCredential
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
        Write-Verbose "Get-AP_SPEnvironment_CredentialFromUserCredential begin"
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
        Write-Verbose "Get-AP_SPEnvironment_CredentialFromUserCredential end"
    }    
}