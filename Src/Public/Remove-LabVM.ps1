function Remove-LabVM {
<#
    .SYNOPSIS
        Removes a bare-metal virtual machine and differencing VHD(X).
    .DESCRIPTION
        The Remove-LabVM cmdlet removes a virtual machine and it's VHD(X) file.
#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        ## Virtual machine name
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData
    )
    process {

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Remove-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.RemovingVM -f $vmName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                ## Create a skeleton config data if one wasn't supplied
                if (-not $PSBoundParameters.ContainsKey('ConfigurationData')) {

                    try {

                        <# If we don't have configuration document, we need to locate
                        the lab image id so that the VM's VHD/X can be removed #182 #>
                        $mediaId = (Resolve-LabVMImage -Name $vmName).Id;
                    }
                    catch {

                        throw ($localized.CannotResolveMediaIdError -f $vmName);
                    }

                    $configurationData = @{
                        AllNodes = @(
                            @{
                                NodeName = $vmName;
                                Media = $mediaId;
                            }
                        )
                    };
                }

                RemoveLabVM -Name $vmName -ConfigurationData $configurationData;
            } #end if should process
        } #end foreach VM

        if (-not [System.String]::IsNullOrEmpty($activity)) {

            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process
} #end function Remove-LabVM
