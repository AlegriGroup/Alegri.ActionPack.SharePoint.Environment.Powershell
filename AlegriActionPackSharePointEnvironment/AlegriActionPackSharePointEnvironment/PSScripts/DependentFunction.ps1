#
# DependentFunction.ps1
#

function Use-AP_SPEnvironment_PnP_GetSPOContext
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "Use-AP_SPEnvironment_PnP_GetSPOContext Begin" 
    }
    Process
    {
        return Get-SPOContext #PNP  
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_GetSPOContext End"
    }
}

function Use-AP_SPEnvironment_PnP_Get-SPOWeb
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "Use-AP_SPEnvironment_PnP_Get-SPOWeb Begin" 
    }
    Process
    {
        return Get-SPOWeb #PNP 
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_Get-SPOWeb End"
    }
}

function Use-AP_SPEnvironment_PnP_Get-PnPSite
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "Use-AP_SPEnvironment_PnP_Get-PnPSite Begin" 
    }
    Process
    {
        return Get-PnPSite #PNP 
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_Get-PnPSite End"
    }
}

function Use-AP_SPEnvironment_PnP_Connect-SPOnline
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
		Write-Verbose "Use-AP_SPEnvironment_PnP_Connect-SPOnline Begin"
    }
    Process
    {
          Connect-SPOnline -Url $Url -Credentials $Credentials
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_Connect-SPOnline End"
    }
}

function Use-AP_SPEnvironment_PnP_Disconnect-SPOnline
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
         Write-Verbose "Use-AP_SPEnvironment_PnP_Disconnect-SPOnline Begin" 
    }
    Process
    {
        Disconnect-SPOnline #PNP 
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_Disconnect-SPOnline End"
    }
}

function Use-AP_SPEnvironment_PnP_Get-PnPSubWebs
{
    [CmdletBinding()]
    param
    (
		[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        $Web
	)
    Begin
    {
         Write-Verbose "Use-AP_SPEnvironment_PnP_Get-PnPSubWebs Begin" 
    }
    Process
    {
        return Get-PnPSubWebs -Web $Web #PNP  
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_PnP_Get-PnPSubWebs End"
    }
}

function Use-AP_SPEnvironment_AlegriModul_Connect-SPOnlineADFS
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
		Write-Verbose "Use-AP_SPEnvironment_AlegriModul_Connect-SPOnlineADFS Begin"
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
		Write-Verbose "Use-AP_SPEnvironment_AlegriModul_Connect-SPOnlineADFS End"
    }
}

function Use-AP_SPEnvironment_AlegriModul_Disconnect-SPOnlineADFS
{
    [CmdletBinding()]
    param
    ()
    Begin
    {
		Write-Verbose "Use-AP_SPEnvironment_AlegriModul_Disconnect-SPOnlineADFSBegin"
    }
    Process
    {
		Disconnect-SPOnlineADFS
    }
    End
    {
		Write-Verbose "Use-AP_SPEnvironment_AlegriModul_Disconnect-SPOnlineADFSEnd"
    }
}
