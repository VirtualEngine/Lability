function Set-LabHostDefault {
<#
    .SYNOPSIS
        Sets the lab host's default settings.
    .DESCRIPTION
        The Set-LabHostDefault cmdlet sets one or more lab host default settings.
    .LINK
        Get-LabHostDefault
        Reset-LabHostDefault
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        ## Lab host .mof configuration document search path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConfigurationPath,

        ## Lab host Media/ISO storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $IsoPath,

        ## Lab host parent/master VHD(X) storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ParentVhdPath,

        ## Lab host virtual machine differencing VHD(X) storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DifferencingVhdPath,

        ## Lab module storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('ModulePath')]
        [System.String] $ModuleCachePath,

        ## Lab custom resource storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourcePath,

        ## Lab host DSC resource share name (for SMB Pull Server).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceShareName,

        ## Lab host media hotfix storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $HotfixPath,

        ## Disable local caching of file-based ISO and WIM files.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $DisableLocalFileCaching,

        ## Enable call stack logging in verbose output
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $EnableCallStackLogging,

        ## Custom DISM/ADK path
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DismPath,

        ## Custom/internal PS repository Uri.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $RepositoryUri
    )
    process {

        $hostDefaults = Get-ConfigurationData -Configuration Host;

        $resolvablePaths = @(
            'IsoPath',
            'ParentVhdPath',
            'DifferencingVhdPath',
            'ResourcePath',
            'HotfixPath',
            'UpdatePath',
            'ConfigurationPath',
            'ModuleCachePath'
        )
        foreach ($path in $resolvablePaths) {

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
        if ($PSBoundParameters.ContainsKey('EnableCallStackLogging')) {

            ## Set the global script variable read by WriteVerbose
            $script:labDefaults.CallStackLogging = $EnableCallStackLogging;
            $hostDefaults.EnableCallStackLogging = $EnableCallStackLogging.ToBool();
        }
        if ($PSBoundParameters.ContainsKey('DismPath')) {

            $hostDefaults.DismPath = ResolveDismPath -Path $DismPath;
            WriteWarning -Message ($localized.DismSessionRestartWarning);
        }
        if ($PSBoundParameters.ContainsKey('RepositoryUri')) {

            $hostDefaults.RepositoryUri = $RepositoryUri.TrimEnd('/');
        }

        Set-ConfigurationData -Configuration Host -InputObject $hostDefaults;
        ImportDismModule;

        return $hostDefaults;

    } #end process
} #end function Set-LabHostDefault

function Set-LabHostDefaults {
<#
    .SYNOPSIS
        Sets the lab host's default settings.
    .DESCRIPTION
        The Set-LabHostDefault cmdlet sets one or more lab host default settings.
    .NOTES
        Proxy function replacing alias to enable warning output.
    .LINK
        Get-LabHostDefault
        Reset-LabHostDefault
#>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess','')]
    param (
        ## Lab host .mof configuration document search path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ConfigurationPath,

        ## Lab host Media/ISO storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $IsoPath,

        ## Lab host parent/master VHD(X) storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ParentVhdPath,

        ## Lab host virtual machine differencing VHD(X) storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DifferencingVhdPath,

        ## Lab module storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ModuleCachePath,

        ## Lab custom resource storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourcePath,

        ## Lab host DSC resource share name (for SMB Pull Server).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceShareName,

        ## Lab host media hotfix storage location/path.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $HotfixPath,

        ## Disable local caching of file-based ISO and WIM files.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $DisableLocalFileCaching,

        ## Enable call stack logging in verbose output
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $EnableCallStackLogging,

        ## Custom DISM/ADK path
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.String] $DismPath
    )
    process {

        Write-Warning -Message ($localized.DeprecatedCommandWarning -f 'Set-LabHostDefaults','Set-LabHostDefault');
        Set-LabHostDefault @PSBoundParameters;

    }
} #end function Set-LabHostDefaults
