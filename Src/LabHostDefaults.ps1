function Get-LabHostDefaults {
<#
	.SYNOPSIS
		Gets the current Hyper-V host default settings.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
	param ( )
    process {
        GetConfigurationData -Configuration Host;
    }
} #end function Get-LabHostDefaults

function GetLabHostDSCConfigurationPath {
<#
	.SYNOPSIS
		Shortcut function to resolve the $labHostDefaults.ConfigurationPath property
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    process {
        $labHostDefaults = GetConfigurationData -Configuration Host;
        return $labHostDefaults.ConfigurationPath;
    }
} #end function GetLabHostDSCConfigurationPath

function Set-LabHostDefaults {
<#
	.SYNOPSIS
		Sets the current Hyper-V host default settings.
#>
	[CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
	param (
        ## Lab host default configuration document path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $ConfigurationPath,
		## Lab host Media/ISO path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $IsoPath,
        ## Lab host parent/master VHD(X) path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $ParentVhdPath,
        ## Lab host virtual machine differencing VHD(X) path.		
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $DifferencingVhdPath,
        ## Lab host DSC resource path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $ResourcePath,
        ## Lab host DSC resource share name (for SMB Pull Server).
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $ResourceShareName,
        ## Lab host Windows media update/hotfix path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $HotfixPath,
        ## Lab host Windows additional update/offline WSUS path.
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $UpdatePath
	)
	process {
		$hostDefaults = GetConfigurationData -Configuration Host;

		foreach ($path in @('IsoPath','ParentVhdPath','DifferencingVhdPath','ResourcePath','HotfixPath','UpdatePath','ConfigurationPath')) {
			if ($PSBoundParameters.ContainsKey($path)) {
				if (-not (Test-Path -Path $path -IsValid -PathType Container)) {
					throw ($localized.InvalidPathError -f $path, $PSBoundParameters[$path]);
				}
				else {
					$hostDefaults.$path = $PSBoundParameters[$path].Trim('\');
				}
			}	
		}
		if ($PSBoundParameters.ContainsKey('ResourceShareName')) {
				$hostDefaults.ResourceShareName = $ResourceShareName;
		}
		
		SetConfigurationData -Configuration Host -InputObject $hostDefaults;
		return $hostDefaults;
	}
} #end function Set-LabHostDefaults
