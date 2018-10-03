function Remove-LabSwitch {
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

        $networkSwitch = Resolve-LabSwitch @PSBoundParameters;
        if (($null -ne $networkSwitch.IsExisting) -and ($networkSwitch.IsExisting -eq $true)) {

            if ($PSCmdlet.ShouldProcess($Name)) {

                $networkSwitch['Ensure'] = 'Absent';
                [ref] $null = $networkSwitch.Remove('IsExisting');
                Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMSwitch -Prefix VMSwitch;
                [ref] $null = Invoke-LabDscResource -ResourceName VMSwitch -Parameters $networkSwitch;
            }
        }

    } #end process
} #end function
