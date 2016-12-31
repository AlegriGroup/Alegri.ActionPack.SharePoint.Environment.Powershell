#
# DependentFunction.ps1
#

function PnPFunc_GetSPOContext
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "PnPFunc_GetSPOContext Begin" 
    }
    Process
    {
        return Get-SPOContext #PNP  
    }
    End
    {
		Write-Verbose "PnPFunc_GetSPOContext End"
    }
}

function PnPFunc_Get-SPOWeb
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "PnPFunc_Get-SPOWeb Begin" 
    }
    Process
    {
        return Get-SPOWeb #PNP 
    }
    End
    {
		Write-Verbose "PnPFunc_Get-SPOWeb End"
    }
}

function PnPFunc_Get-PnPSite
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "PnPFunc_Get-PnPSite Begin" 
    }
    Process
    {
        return Get-PnPSite #PNP 
    }
    End
    {
		Write-Verbose "PnPFunc_Get-PnPSite End"
    }
}

function PnPFunc_Connect-SPOnline
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $Url,
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
        $Credentials
	)
    Begin
    {
		Write-Verbose "PnPFunc_Connect-SPOnline Begin"
    }
    Process
    {
          Connect-SPOnline -Url $Url -Credentials $Credentials
    }
    End
    {
		Write-Verbose "PnPFunc_Connect-SPOnline End"
    }
}

function PnPFunc_Disconnect-SPOnline
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "PnPFunc_Disconnect-SPOnline Begin" 
    }
    Process
    {
        Disconnect-SPOnline #PNP 
    }
    End
    {
		Write-Verbose "PnPFunc_Disconnect-SPOnline End"
    }
}

function PnPFunc_Get-PnPSubWebs
{
    [CmdletBinding()]
    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $Web
	)
    Begin
    {
         Write-Verbose "PnPFunc_Get-PnPSubWebs Begin" 
    }
    Process
    {
        return Get-PnPSubWebs -Web $Web #PNP  
    }
    End
    {
		Write-Verbose "PnPFunc_Get-PnPSubWebs End"
    }
}

function AlegriModulFunc_Connect-SPOnlineADFS
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $Url,
		$Use32BitMode
	)
    Begin
    {
		Write-Verbose "AlegriModulFunc_Connect-SPOnlineADFS Begin"
    }
    Process
    {
		if($Use32BitMode) {
			Connect-SPOnlineADFS -Url $Url -Use32BitMode
		} else {
			Connect-SPOnlineADFS -Url $Url
		}
    }
    End
    {
		Write-Verbose "AlegriModulFunc_Connect-SPOnlineADFS End"
    }
}

function AlegriModulFunc_Disconnect-SPOnlineADFS 
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
		Write-Verbose "AlegriModulFunc_Disconnect-SPOnlineADFS Begin"
    }
    Process
    {
		Disconnect-SPOnlineADFS
    }
    End
    {
		Write-Verbose "AlegriModulFunc_Disconnect-SPOnlineADFS End"
    }
}
