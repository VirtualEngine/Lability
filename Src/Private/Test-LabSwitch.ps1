function Test-LabSwitch {
<#
    .SYNOPSIS
        Tests the current configuration a virtual network switch.
    .DESCRIPTION
        Tests a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
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

        $networkSwitch = Resolve-LabSwitch @PSBoundParameters;
        if (($null -ne $networkSwitch.IsExisting) -and ($networkSwitch.IsExisting -eq $true)) {

            ## The existing virtual switch may be of a type not supported by the DSC resource.
            return $true;
        }
        ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
        return TestDscResource -ResourceName VMSwitch -Parameters $networkSwitch;

    } #end process
} #end function
