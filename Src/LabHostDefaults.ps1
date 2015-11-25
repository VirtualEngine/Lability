function Reset-LabHostDefaults {
<#
	.SYNOPSIS
		Reset the current Hyper-V host default settings back to defaults.
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
	param ( )
    process {
        RemoveConfigurationData -Configuration Host;
        Get-LabHostDefaults;
    }
} #end function Reset-LabHostDefaults

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
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()] [System.String] $UpdatePath,
        ## Disable local caching of file-based ISO and WIM files.
        [Parameter(ValueFromPipelineByPropertyName)] [System.Management.Automation.SwitchParameter] $DisableLocalFileCaching
	)
	process {
		$hostDefaults = GetConfigurationData -Configuration Host;
        
        ## This property may not be present in the original machine configuration file
        if ($hostDefaults.PSObject.Properties.Name -notcontains 'DisableLocalFileCaching') {
            [ref] $null = Add-Member -InputObject $hostDefaults -MemberType NoteProperty -Name 'DisableLocalFileCaching' -Value $DisableLocalFileCaching;
        }

		foreach ($path in @('IsoPath','ParentVhdPath','DifferencingVhdPath','ResourcePath','HotfixPath','UpdatePath','ConfigurationPath')) {
			if ($PSBoundParameters.ContainsKey($path)) {
                $resolvedPath = ResolvePathEx -Path $PSBoundParameters[$path];
                if (-not ((Test-Path -Path $resolvedPath -PathType Container -IsValid) -and (Test-Path -Path (Split-Path -Path $resolvedPath -Qualifier))) ) {
                    throw ($localized.InvalidPathError -f $resolvedPath, $PSBoundParameters[$path]);
                }
                else {
                    $hostDefaults.$path = $resolvedPath.Trim('\');
                }
			}	
		}
		if ($PSBoundParameters.ContainsKey('ResourceShareName')) {
			$hostDefaults.ResourceShareName = $ResourceShareName;
		}
		if ($PSBoundParameters.ContainsKey('DisableLocalFileCaching')) {
			$hostDefaults.DisableLocalFileCaching = $DisableLocalFileCaching.ToBool();
		}
		
		SetConfigurationData -Configuration Host -InputObject $hostDefaults;
		return $hostDefaults;
	}
} #end function Set-LabHostDefaults
