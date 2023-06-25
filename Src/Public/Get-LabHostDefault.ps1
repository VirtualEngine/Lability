function Get-LabHostDefault {
<#
    .SYNOPSIS
        Gets the lab host's default settings.
    .DESCRIPTION
        The Get-LabHostDefault cmdlet returns the lab host's current settings.
    .LINK
        Set-LabHostDefault
        Reset-LabHostDefault
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ( )
    process {

        $hostDefaults = Get-ConfigurationData -Configuration Host;

        ## Create/update Lability environment variables
        $env:LabilityConfigurationPath = $hostDefaults.ConfigurationPath;
        $env:LabilityDifferencingVhdPath = $hostDefaults.DifferencingVhdPath;
        $env:LabilityHotfixPath = $hostDefaults.HotfixPath;
        $env:LabilityIsoPath = $hostDefaults.IsoPath;
        $env:LabilityModuleCachePath = $hostDefaults.ModuleCachePath;
        $env:LabilityResourcePath = $hostDefaults.ResourcePath;
        $env:LabilityDismPath = $hostDefaults.DismPath;
        $env:LabilityRepositoryUri = $hostDefaults.RepositoryUri;
        $env:LabilityParentVhdPath = $hostDefaults.ParentVhdPath;

        return $hostDefaults;

    } #end process
} #end function
