function Resolve-LabEnvironmentName {
<#
    .SYNOPSIS
        Resolves a name with an environment prefix and suffix.
#>
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## PowerShell DSC configuration document (.psd1) containing lab metadata.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        ## Add a prefix if defined
        if ($ConfigurationData.NonNodeData.($labDefaults.ModuleName).EnvironmentPrefix) {

            $Name = '{1}{0}' -f $Name, $ConfigurationData.NonNodeData.($labDefaults.ModuleName).EnvironmentPrefix;
        }
        if ($ConfigurationData.NonNodeData.($labDefaults.ModuleName).EnvironmentSuffix) {

            $Name = '{0}{1}' -f $Name, $ConfigurationData.NonNodeData.($labDefaults.ModuleName).EnvironmentSuffix;
        }

        return $Name;

    } #end process
} #end function
