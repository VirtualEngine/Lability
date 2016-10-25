function GetLabHostDSCConfigurationPath {

<#
    .SYNOPSIS
        Shortcut function to resolve the host's default ConfigurationPath property
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ( )
    process {

        $labHostDefaults = GetConfigurationData -Configuration Host;
        return $labHostDefaults.ConfigurationPath;

    } #end process

}

