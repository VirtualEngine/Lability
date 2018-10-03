function Resolve-LabResource {
<#
    .SYNOPSIS
        Resolves a lab resource by its ID
#>
    param (
        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Lab resource ID
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourceId
    )
    process {

        $resource = $ConfigurationData.NonNodeData.($labDefaults.ModuleName).Resource | Where-Object Id -eq $ResourceId;
        if ($resource) {

            return $resource;
        }
        else {

            throw ($localized.CannotResolveResourceIdError -f $resourceId);
        }

    } #end process
} #end function
