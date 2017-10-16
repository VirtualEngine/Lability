function Test-LabNode {
<#
    .SYNOPSIS
        Tests whether the node name is defined in a configuration document.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## PowerShell module hashtable
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $node = Resolve-NodePropertyValue -NodeName $Name -ConfigurationData $ConfigurationData -NoEnumerateWildcardNode;
        return ($null -ne $node.NodeName);

    } #end process
} #end function
