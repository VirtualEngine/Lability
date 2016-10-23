function RemoveLabSwitch {

<#
    .SYNOPSIS
        Removes a virtual network switch configuration.
    .DESCRIPTION
        Deletes a virtual network switch configuration using the xVMSwitch DSC resource.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        ## Switch Id/Name
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {
        $networkSwitch = ResolveLabSwitch @PSBoundParameters;
        if (($null -eq $networkSwitch.IsExisting) -or ($networkSwitch.IsExisting -eq $false)) {
            if ($PSCmdlet.ShouldProcess($Name)) {
                $networkSwitch['Ensure'] = 'Absent';
                ImportDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
                [ref] $null = InvokeDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
            }
        }
    } #end process

}

