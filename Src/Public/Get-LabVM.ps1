function Get-LabVM {
<#
    .SYNOPSIS
        Retrieves the current configuration of a VM.
    .DESCRIPTION
        Gets a virtual machine's configuration using the xVMHyperV DSC resource.
#>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        if (-not $Name) {

            # Return all nodes defined in the configuration
            $Name = $ConfigurationData.AllNodes | Where-Object NodeName -ne '*' | ForEach-Object { $_.NodeName; }
        }

        foreach ($nodeName in $Name) {

            $node = Resolve-NodePropertyValue -NodeName $nodeName -ConfigurationData $ConfigurationData;
            $xVMParams = @{
                Name = $node.NodeDisplayName;
                VhdPath = Resolve-LabVMDiskPath -Name $node.NodeDisplayName;;
            }

            try {

                Import-LabDscResource -ModuleName xHyper-V -ResourceName MSFT_xVMHyperV -Prefix VM;
                $vm = Get-LabDscResource -ResourceName VM -Parameters $xVMParams;
                Write-Output -InputObject ([PSCustomObject] $vm);
            }
            catch {

                Write-Error -Message ($localized.CannotLocateNodeError -f $nodeName);
            }

        } #end foreach node

    } #end process
} #end function Get-LabVM
