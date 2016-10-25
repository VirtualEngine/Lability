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

}

