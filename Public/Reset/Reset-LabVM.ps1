function Reset-LabVM {

<#
    .SYNOPSIS
        Recreates a lab virtual machine.
    .DESCRIPTION
        The Reset-LabVM cmdlet deletes and recreates a lab virtual machine, reapplying the MOF.

        To revert a single VM to a previous state, use the Restore-VMSnapshot cmdlet. To revert an entire lab environment, use the Restore-Lab cmdlet.
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'PSCredential')]
    param (
        ## Specifies the lab virtual machine/node name.
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name,

        ## Specifies a PowerShell DSC configuration document (.psd1) containing the lab configuration.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [System.Collections.Hashtable]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformationAttribute()]
        $ConfigurationData,

        ## Local administrator password of the virtual machine. The username is NOT used.
        [Parameter(ParameterSetName = 'PSCredential', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential = (& $credentialCheckScriptBlock),

        ## Local administrator password of the virtual machine.
        [Parameter(Mandatory, ParameterSetName = 'Password', ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Password,

        ## Directory path containing the virtual machines' .mof file(s).
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (GetLabHostDSCConfigurationPath),

        ## Skip creation of the initial baseline snapshot.
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $NoSnapshot
    )
    begin {

        ## If we have only a secure string, create a PSCredential
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $Credential = New-Object -TypeName 'System.Management.Automation.PSCredential' -ArgumentList 'LocalAdministrator', $Password;
        }
        if (-not $Credential) { throw ($localized.CannotProcessCommandError -f 'Credential'); }
        elseif ($Credential.Password.Length -eq 0) { throw ($localized.CannotBindArgumentError -f 'Password'); }

    }
    process {

        $currentNodeCount = 0;
        foreach ($vmName in $Name) {

            $shouldProcessMessage = $localized.PerformingOperationOnTarget -f 'Reset-LabVM', $vmName;
            $verboseProcessMessage = GetFormattedMessage -Message ($localized.ResettingVM -f $vmName);
            if ($PSCmdlet.ShouldProcess($verboseProcessMessage, $shouldProcessMessage, $localized.ShouldProcessWarning)) {

                $currentNodeCount++;
                [System.Int32] $percentComplete = (($currentNodeCount / $Name.Count) * 100) - 1;
                $activity = $localized.ConfiguringNode -f $vmName;
                Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;

                RemoveLabVM -Name $vmName -ConfigurationData $ConfigurationData;
                NewLabVM -Name $vmName -ConfigurationData $ConfigurationData -Path $Path -NoSnapshot:$NoSnapshot -Credential $Credential;

            } #end if should process
        } #end foreach VMd

        if (-not [System.String]::IsNullOrEmpty($activity)) {

            Write-Progress -Id 42 -Activity $activity -PercentComplete $percentComplete;
        }

    } #end process

}

